local pref = require("pref")
local PsxExeFormat = require("formats.psxexe.definition")
local MipsProcessor = require("processors.mips.definition")
local MipsRegisters = require("processors.mips.registers")
local OperandType = require("processors.mips.operand.type")
local InstructionType = require("processors.mips.instruction.type")
local GTERegisters = require("disassemblers.psxexe.gte.registers")
local GTEFunctions = require("disassemblers.psxexe.gte.functions")
local PsyQ = require("disassemblers.psxexe.psyq")

local ByteOrder = pref.byteorder
local DataType = pref.datatype
local Segment = pref.disassembler.segment
local SymbolType = pref.disassembler.symboltype

local processor = MipsProcessor()
local psyq = PsyQ()
local PsxExeDisassembler = pref.disassembler.create("Sony Playstation 1 PS-EXE", "Dax", "1.0", DataType.UInt32_LE, PsxExeFormat)

function PsxExeDisassembler:baseAddress()
  return 0x80000000
end

function PsxExeDisassembler:map()  
  local taddrfield = self.formattree.ExeHeader.t_addr
  local tsizefield = self.formattree.ExeHeader.t_size
  local pc0field = self.formattree.ExeHeader.pc0
  
  self:createSegment("TEXT", Segment.Code, taddrfield.value, tsizefield.value, 0x800)
  self:createEntryPoint(pc0field.value, "start")
end

function PsxExeDisassembler:disassemble(address)
  local instruction = processor:decode(address, self.memorybuffer)
  self:addInstruction(instruction)
  psyq:analyze(self, instruction)
    
  if instruction.type == InstructionType.Invalid then
    self:warning(string.format("Got an Invalid Instruction at %08Xh", address))
  elseif instruction.type == InstructionType.Stop then    
    return 0
  elseif instruction.iscall and instruction.isdestinationvalid then
    self:createFunction(instruction.destination, instruction.address)
    self:enqueue(instruction.destination)
  elseif instruction.isjump and instruction.isdestinationvalid then
    local destination = ((instruction.mnemonic == "JR") and processor.gpr[instruction.operands[1].value] or instruction.destination)
    
    if self:isAddress(destination) then
      self:createLabel(destination, instruction.address, string.format("j_%08X", destination))
      self:enqueue(destination)  -- Try to follow jump destination
    end
  elseif instruction.ismacro and (instruction.operands[2].type == OperandType.Immediate) and self:isAddress(instruction.operands[2].value) then
    self:setSymbol(instruction.operands[2].value, SymbolType.Address)
  end
  
  if instruction.isjump or instruction.iscall then
    local delayslot = processor:decode(address + instruction.size, self.memorybuffer) -- Decode Delay Slot      
    self:addInstruction(delayslot) -- Add Delay Slot
    psyq:analyze(self, delayslot)
    
    if instruction.type == InstructionType.Jump then
      return 0
    end
    
    return self:next(delayslot)
  end
    
  return self:next(instruction)
end

function PsxExeDisassembler:output(printer, instruction)
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
    elseif ((op.type == OperandType.Immediate) and self:isSymbol(op.value)) then
      printer:out(self:symbolName(op.value), 0x0000FF)
    elseif (op.type == OperandType.Address) and self:isSymbol(op.value) then
      printer:out(self:symbolName(op.value), 0x800080)
    elseif (op.type == OperandType.Offset) and self:isSymbol(op.value) then
      printer:out(self:symbolName(op.value), 0x4B0082)
    else
      printer:outvalue(op.value, op.datatype)
    end
    
    if i < #instruction.operands then
      printer:out(", ")
    end
  end
  
  if instruction.ismacro and (instruction.type == InstructionType.Load) and self:isStringSymbol(instruction.operands[2].value) then
    printer:outcomment("'" .. self.memorybuffer:readDisplayString(instruction.operands[2].value) .. "'")
  end
end

return PsxExeDisassembler