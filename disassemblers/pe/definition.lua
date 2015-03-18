-- https://sourceware.org/binutils/docs/as/i386_002dMemory.html

local ffi = require("ffi")
local pref = require("pref")
local PeFormat = require("formats.pe.definition")
local CapstoneContext = require("sdk.modules.capstone.context")
local InstructionHighlighter = require("disassemblers.pe.instructionhighlighter")

local DataType = pref.datatype
local SegmentType = pref.disassembler.segmenttype
local SymbolType = pref.disassembler.symboltype

local PeDisassembler = pref.disassembler.create("Portable Executable (32-Bit)", "Dax", "1.0", DataType.UInt32_LE, PeFormat)
local capstone = CapstoneContext()

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
    self.listing:createSegment(section.Name.value, SegmentType.Code, imagebase + section.VirtualAddress.value, section.VirtualSize.value, section.PointerToRawData.value)
  end
  
  self.listing:createEntryPoint(imagebase + ntheaders.OptionalHeader.AddressOfEntryPoint.value, "start")
  
  if(capstone:open(capstone.lib.CS_ARCH_X86, capstone.lib.CS_MODE_32) == capstone.lib.CS_ERR_OK) then
    capstone:option(capstone.lib.CS_OPT_DETAIL, capstone.lib.CS_OPT_ON)
  end
end

function PeDisassembler:disassemble(address)
  local instruction = capstone:decode(address, self.memorybuffer)
  self.listing:addInstruction(instruction)
  
  if instruction.mnemonic == "LEAVE" then
    return nil
  end
  
  return self:next(instruction)
end

function PeDisassembler:output(printer, instruction)
  local i = 0
  local x86 = instruction.detail.x86
  printer:outword(instruction.mnemonic, InstructionHighlighter.highlight(capstone, instruction))
   
  while i < x86.op_count do
    local op = x86.operands[i]
    
    if op.type == capstone.lib.X86_OP_REG then
      printer:outregister(capstone:registerName(op.reg))
    elseif op.type == capstone.lib.X86_OP_IMM then
      printer:outvalue(tonumber(op.imm), DataType.besttype(tonumber(op.size)))
    elseif op.type == capstone.lib.X86_OP_MEM then
      local mem = op.mem
      
      if mem.segment ~= capstone.lib.X86_REG_INVALID then
        printer:out(capstone:registerName(mem.segment)):out(":")
      end
      
      printer:out("[")
      
      if mem.base ~= capstone.lib.X86_REG_INVALID then
        printer:outregister(capstone:registerName(mem.base)):out(" + ")
      end
      
      if mem.index ~= capstone.lib.X86_REG_INVALID then
        printer:outregister(capstone:registerBase(mem.index))
        
        if mem.scale > 1 then
          printer:out(" * "):outvalue(scale, DataType.UInt8)
        end
        
        printer:out(" + ")
      end
      
      printer:outvalue(tonumber(mem.disp), DataType.besttype(tonumber(op.size)))
      printer:out("]")
    else
      pref.warning("Invalid operand detected")
    end
    
    if i < (x86.op_count - 1) then
      printer:out(", ")
    end
    
    i = i + 1
  end
  
  printer:outcomment(ffi.string(instruction.__csinsn.op_str)) -- NOTE: Debugging 
end

return PeDisassembler 
