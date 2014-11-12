local pref = require("pref")
local PsxExeFormat = require("formats.psxexe.definition")
local MipsProcessor = require("processors.mips.definition")
local MipsRegisters = require("processors.mips.registers")
local MacroAnalyzer = require("processors.mips.instruction.macro")
local InstructionEmulator = require("processors.mips.instruction.emulator")
local OperandType = require("processors.mips.operand.type")
local InstructionType = require("processors.mips.instruction.type")
local GTERegisters = require("disassemblers.psxexe.gte.registers")
local GTEFunctions = require("disassemblers.psxexe.gte.functions")
local PsyQ = require("disassemblers.psxexe.psyq")

local ByteOrder = pref.byteorder
local DataType = pref.datatype
local SegmentType = pref.disassembler.segmenttype
local SymbolType = pref.disassembler.symboltype

local PsxExeDisassembler = pref.disassembler.create("Sony Playstation 1 PS-EXE", "Dax", "1.0", DataType.UInt32_LE, PsxExeFormat)
local processor = MipsProcessor()
local macroanalyzer = MacroAnalyzer(processor)
local emulator = InstructionEmulator()
local psyq = PsyQ()

function PsxExeDisassembler:baseAddress()
  return 0x80000000
end

function PsxExeDisassembler:map()
  local taddrfield = self.formattree.ExeHeader.t_addr
  local tsizefield = self.formattree.ExeHeader.t_size
  local pc0field = self.formattree.ExeHeader.pc0
  
  self.listing:createSegment("TEXT", SegmentType.Code, taddrfield.value, tsizefield.value, 0x800)
  self.listing:createEntryPoint(pc0field.value, "start")
end

function PsxExeDisassembler:analyzeInstruction(instruction)
  local symboltable = self.listing.symboltable
  
  if instruction.type == InstructionType.Invalid then
      self:warning(string.format("Got an Invalid Instruction at %08Xh", address))
  elseif instruction.iscall and instruction.isdestinationvalid then
    self.listing:createFunction(instruction.destination, instruction.address)
    self:enqueue(instruction.destination)
  elseif instruction.isjump and instruction.isdestinationvalid then
    local destination = ((instruction.mnemonic == "JR") and emulator.gpr[instruction.operands[1].value] or instruction.destination)
  
    if self.listing:isAddress(destination) then
      self.listing:createLabel(destination, instruction.address, string.format("j_%08X", destination))
      self:enqueue(destination)  -- Try to follow jump destination
    end
  elseif instruction.ismacro and (instruction.operands[2].type == OperandType.Immediate) and self.listing:isAddress(instruction.operands[2].value) then
    local len = self.memorybuffer:pointsToString(instruction.operands[2].value)
  
    if len > 3 then
      symboltable:set(instruction.operands[2].value, len, instruction.address, SymbolType.String)
    else
      symboltable:set(instruction.operands[2].value, instruction.address, SymbolType.Address)
    end
  end
end

function PsxExeDisassembler:disassemble(address)
  local instruction = macroanalyzer:checkMacro(processor:decode(address, self.memorybuffer), self.memorybuffer)
  emulator:execute(instruction, self.memorybuffer)
  
  self:analyzeInstruction(instruction)
  self.listing:addInstruction(instruction)
  psyq:analyze(self.listing, instruction)
  
  if macroanalyzer.branchskipped then
    local branchinstruction = macroanalyzer:checkMacro(processor:decode(macroanalyzer.branchaddress, self.memorybuffer), self.memorybuffer)
    emulator:execute(branchinstruction, self.memorybuffer)
    self:analyzeInstruction(branchinstruction)
    self.listing:addInstruction(branchinstruction)
    psyq:analyze(self.listing, branchinstruction)
       
    if (branchinstruction.type == InstructionType.Stop) or (branchinstruction.type == InstructionType.Jump) then
      return 0
    end

    return instruction.address + 8 -- Skip delay slot
  elseif instruction.isjump or instruction.iscall then
    local nextaddress = self:disassemble(self:next(instruction)) -- Decode Delay Slot
    
    if (instruction.type == InstructionType.Stop) or (instruction.type == InstructionType.Jump) then
      return 0
    end
    
    return nextaddress
  end
  
  return self:next(instruction)
end

function PsxExeDisassembler:output(printer, instruction)
  local symboltable = self.listing.symboltable
  
  if instruction.type == InstructionType.Invalid then
    printer:out(string.format("db %s", self:hexdump(instruction)))
    return
  end
  
  printer:outword(instruction.mnemonic, InstructionType.color(instruction.type))
  
  for i, op in ipairs(instruction.operands) do
    if op.type == OperandType.Register then
      printer:outregister(MipsRegisters.gpr[op.value])
    elseif op.type == OperandType.COP0Register then
      printer:outregister(MipsRegisters.cop0[op.value])
    elseif op.type == OperandType.COP2DataRegister then
      printer:outregister(GTERegisters.data[op.value])
    elseif op.type == OperandType.COP2ControlRegister then
      printer:outregister(GTERegisters.control[op.value])
    elseif op.type == OperandType.Memory then
      printer:out("["):outregister(MipsRegisters.gpr[op.base]):out(" + "):outvalue(op.disp, op.datatype):out("]")
    elseif (op.type == OperandType.Immediate) and (instruction.mnemonic == "COP2") and GTEFunctions[op.value] then      
      printer:out(GTEFunctions[op.value], 0x0000FF)
    elseif (op.type == OperandType.Immediate) and symboltable:contains(op.value) then
      printer:out(symboltable:name(op.value), 0x0000FF)
    elseif (op.type == OperandType.Address) and symboltable:contains(op.value) then
      printer:out(symboltable:name(op.value), 0x800080)
    elseif (op.type == OperandType.Offset) and symboltable:contains(op.value) then
      printer:out(symboltable:name(op.value), 0x4B0082)
    else
      printer:outvalue(op.value, op.datatype)
    end
    
    if i < #instruction.operands then
      printer:out(", ")
    end
  end
  
  if instruction.ismacro and (instruction.type == InstructionType.Load) and (symboltable:type(instruction.operands[2].value) == SymbolType.String) then
    printer:outcomment("'" .. self.memorybuffer:readDisplayString(instruction.operands[2].value) .. "'")
  end
end

return PsxExeDisassembler