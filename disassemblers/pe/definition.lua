-- https://sourceware.org/binutils/docs/as/i386_002dMemory.html

local pref = require("pref")
local capstone = require("capstone")
local CapstoneInstruction = require("sdk.disassembler.capstone.instruction")
local PeFormat = require("formats.pe.definition")
local PeConstants = require("formats.pe.constants")
local InstructionAnalyzer = require("disassemblers.pe.instructionanalyzer")
local InstructionHighlighter = require("disassemblers.pe.instructionhighlighter")
local ImportResolver = require("disassemblers.pe.importresolver")

local DataType = pref.datatype
local SegmentType = pref.disassembler.segmenttype
local SymbolType = pref.disassembler.symboltype

local PeDisassembler = pref.disassembler.create("Portable Executable (32-Bit)", "Dax", "1.0", DataType.UInt32_LE, PeFormat)

function PeDisassembler:initialize()
  self.buffersize = 32
  
  local err, handle = capstone.open(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
  
  if err ~= capstone.CS_ERR_OK then
    error("Capstone open() failed")
  end
  
  capstone.option(handle, capstone.CS_OPT_DETAIL, capstone.CS_OPT_ON)
  self.cshandle = handle
  self.analyzer = InstructionAnalyzer(handle, self.formattree)
  self.importresolver = ImportResolver(self.formattree)
end

function PeDisassembler:finalize()
  if self.cshandle == nil then
    return
  end

  capstone.close(self.cshandle)
  self.cshandle = nil
end

function PeDisassembler:decode(address)
  local buffer = self.memorybuffer:readBuffer(address, self.buffersize)
  local it = capstone.createiterator(self.cshandle, buffer.pointer, self.buffersize, address)
  capstone.disasmiter(self.cshandle, it)
  
  return CapstoneInstruction(self.cshandle, it.insn)
end

function PeDisassembler:baseAddress()
  return self.formattree.NtHeaders.OptionalHeader.ImageBase.value
end

function PeDisassembler:map()
  local ntheaders = self.formattree.NtHeaders
  local numberofsections = ntheaders.FileHeader.NumberOfSections.value
  local imagebase = self.formattree.NtHeaders.OptionalHeader.ImageBase.value
  local sectiontable = self.formattree.SectionTable
  
  for i = 1, numberofsections do
    local section = sectiontable["Section" .. i]
    local segmenttype = SegmentType.Data
    
    if bit.band(section.Characteristics.value, PeConstants.Section.Code) ~= 0 then
      segmenttype = SegmentType.Code
    end
    
    self.listing:createSegment(section.Name.value, segmenttype, imagebase + section.VirtualAddress.value, section.VirtualSize.value, section.PointerToRawData.value)  
  end
  
  self.listing:createEntryPoint(imagebase + ntheaders.OptionalHeader.AddressOfEntryPoint.value, "start")
  self.importresolver:createImports(self.listing)
end

function PeDisassembler:disassemble(address)
  local symboltable = self.listing.symboltable
  local instruction = self:decode(address)
  
  self.listing:addInstruction(instruction)
  self.analyzer:analyze(instruction)
  
  if self.analyzer:isImportBranch(instruction) then
    if symboltable:contains(instruction.destination) then
      self.listing:setFunction(instruction.address, self.importresolver:callName(symboltable:name(instruction.destination)))
    end
    
    if instruction.isjump then
      return nil -- Stop Here
    end
  elseif self.listing:isAddress(address) and instruction.isdestinationvalid then
    if instruction.isjump then
      self.listing:createLabel(instruction.destination, instruction.address, string.format("j_%08X", instruction.destination))
    elseif instruction.iscall then
      self.listing:createFunction(instruction.destination, instruction.address)
    end
    
    self:enqueue(instruction.destination)
  end
  
  return self:next(instruction)
end

function PeDisassembler:output(printer, instruction)
  local symboltable = self.listing.symboltable
  local x86 = instruction.detail.x86
  printer:outword(instruction.mnemonic, InstructionHighlighter.highlight(self.cshandle, instruction))
   
  for i = 1, x86.op_count do
    local op = x86.operands[i]
    
    if op.type == capstone.X86_OP_REG then
      printer:outregister(capstone.registername(self.cshandle, op.reg))
    elseif op.type == capstone.X86_OP_IMM then
      if symboltable:contains(op.imm) then
        printer:out(symboltable:name(op.imm), 0x0000FF)
      else
        printer:outvalue(op.imm, DataType.besttype(op.size))
      end
    elseif op.type == capstone.X86_OP_MEM then
      local mem = op.mem
      
      if mem.segment ~= capstone.X86_REG_INVALID then
        printer:out(capstone.registername(self.cshandle, mem.segment)):out(":")
      end
      
      printer:out("[")
      
      if mem.base ~= capstone.X86_REG_INVALID then
        printer:outregister(capstone.registername(self.cshandle, mem.base)):out(" + ")
      end
      
      if mem.index ~= capstone.X86_REG_INVALID then
        printer:outregister(capstone.registername(self.cshandle, mem.index))
        
        if mem.scale > 1 then
          printer:out(" * "):outvalue(mem.scale, DataType.UInt8)
        end
        
        printer:out(" + ")
      end
      
      if symboltable:contains(mem.disp) then
        printer:out(symboltable:name(mem.disp), 0x0000FF)
      else
        printer:outvalue(mem.disp, DataType.besttype(op.size))
      end
        
      printer:out("]")
    else
      pref.warning("Invalid operand detected")
    end
    
    if i < x86.op_count then
      printer:out(", ")
    end
  end
  
  -- printer:outcomment(instruction.csinsn.op_str) -- NOTE: Debugging 
end

return PeDisassembler 
