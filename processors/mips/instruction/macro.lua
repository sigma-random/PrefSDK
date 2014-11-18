-- http://www.ric.edu/faculty/emcdowell/cs312/mars.txt

local oop = require("oop")
local pref = require("pref")
local MacroInstruction = require("sdk.disassembler.macroinstruction")
local Operand = require("sdk.disassembler.operand")
local InstructionType = require("processors.mips.instruction.type")
local OperandType = require("processors.mips.operand.type")

local DataType = pref.datatype

local MacroAnalyzer = oop.class()

function MacroAnalyzer:__ctor(processor)  
  self.processor = processor
  self.branchskipped = false
  self.branchaddress = 0
  self.dispatcher = { LUI   = MacroAnalyzer.analyzeLui,
                      SLT   = MacroAnalyzer.analyzeSlt,
                      SLTU  = MacroAnalyzer.analyzeSlt,
                      SLTIU = MacroAnalyzer.analyzeSlt,
                      ADDU  = MacroAnalyzer.analyzeAddu,
                      ADDIU = MacroAnalyzer.analyzeAddu,
                      NOR   = MacroAnalyzer.analyzeNor,
                      -- ORI   = MacroAnalyzer.analyzeOri,
                      SLL   = MacroAnalyzer.analyzeSll,
                      SUB   = MacroAnalyzer.analyzeSub }
end

function MacroAnalyzer:nextInstruction(instruction, memorybuffer, skipcontrolflow)
  local instruction = self.processor:decode(instruction.address + instruction.size, memorybuffer)
  
  if skipcontrolflow and (instruction.isjump or instruction.iscall) then -- Check Delay Slot
    self.branchskipped = true
    self.branchaddress = instruction.address
    instruction = self.processor:decode(instruction.address + instruction.size, memorybuffer)
  end
  
  return instruction
end

function MacroAnalyzer:checkMacro(instruction, memorybuffer)
  self.branchskipped = false
  local d = self.dispatcher[instruction.mnemonic]
  
  if d then
    return d(self, instruction, memorybuffer)
  end
  
  return instruction
end

function MacroAnalyzer:analyzeLui(instruction, memorybuffer)
  local nextinstruction = self:nextInstruction(instruction, memorybuffer, true)
  
  if ((nextinstruction.mnemonic == "ADDIU") or (nextinstruction.mnemonic == "ORI")) and (instruction.operands[1].value == nextinstruction.operands[2].value) then    
    local macroinstruction = MacroInstruction(instruction.address, "LI", InstructionType.Load)
    macroinstruction.size = 8
    macroinstruction.operands = { nextinstruction.operands[1], Operand:create(DataType.UInt32, OperandType.Immediate, bit.lshift(instruction.operands[2].value, 16) + nextinstruction.operands[3].value) }
    return macroinstruction
  elseif ((nextinstruction.mnemonic == "LW") or (nextinstruction.mnemonic == "SW")) and (instruction.operands[1].value == nextinstruction.operands[2].base) then    
    local macroinstruction = MacroInstruction(instruction.address, nextinstruction.mnemonic, nextinstruction.type)
    macroinstruction.size = 8
    macroinstruction.operands = { nextinstruction.operands[1], Operand:create(DataType.UInt32, OperandType.Immediate, bit.lshift(instruction.operands[2].value, 16) + nextinstruction.operands[2].disp) }
    return macroinstruction
  else
    instruction.ismacro = true
    instruction.mnemonic = "LI"
    instruction.operands[2].datatype = DataType.UInt32
    instruction.operands[2].value = bit.lshift(instruction.operands[2].value, 16)
  end
  
  self.branchskipped = false -- It's a standalone LUI, disassemble it normally
  return instruction
end

function MacroAnalyzer:analyzeSlt(instruction, memorybuffer)
  local nextinstruction = self:nextInstruction(instruction, memorybuffer)
  
  if (nextinstruction.mnemonic == "BNE") and (instruction.operands[1].value == nextinstruction.operands[1].value) and (nextinstruction.operands[2].value == 0) then
    local macroinstruction = MacroInstruction(instruction.address, "BGT", InstructionType.ConditionalJump, true)
    macroinstruction.size = 8
    macroinstruction.operands = { instruction.operands[3], instruction.operands[2], nextinstruction.operands[3]  }
    macroinstruction.isdestinationvalid = true
    macroinstruction.destination = nextinstruction.operands[3].value
    return macroinstruction
  end
  
  if (nextinstruction.mnemonic == "BEQ")  and (instruction.operands[1].value == nextinstruction.operands[1].value) and (nextinstruction.operands[2].value == 0) then
    local macroinstruction = MacroInstruction(instruction.address, "BGE", InstructionType.ConditionalJump, true)
    macroinstruction.size = 8
    macroinstruction.operands = { instruction.operands[2], instruction.operands[3], nextinstruction.operands[3]  }
    macroinstruction.isdestinationvalid = true
    macroinstruction.destination = nextinstruction.operands[3].value
    return macroinstruction
  end
  
  self.branchskipped = false -- It's a standalone SLT/SLTIU, disassemble it normally
  return instruction
end

function MacroAnalyzer:analyzeAddu(instruction, memorybuffer)
  local nextinstruction = self:nextInstruction(instruction, memorybuffer, true)
  
  if (instruction.mnemonic == "ADDIU") and (nextinstruction.mnemonic == "LUI") and (instruction.operands[2].value == nextinstruction.operands[1].value) then
    local macroinstruction = MacroInstruction(instruction.address, "LI", InstructionType.Load)
    macroinstruction.size = 8
    macroinstruction.operands = { instruction.operands[1], Operand:create(DataType.UInt32, OperandType.Immediate, bit.lshift(nextinstruction.operands[2].value, 16) + instruction.operands[3].value) }
    return macroinstruction
  end
  
  self.branchskipped = false -- It's a standalone ADDU/ADDIU, disassemble it normally
  
  if instruction.operands[2].value == 0 then
    instruction.mnemonic = "MOVE"
    instruction.ismacro = true
    instruction.type = InstructionType.Load
    table.remove(instruction.operands, 2)
  end
  
  return instruction
end

function MacroAnalyzer:analyzeNor(instruction)
  if instruction.operands[3].value == 0 then
    instruction.mnemonic = "NOT"
    instruction.ismacro = true
    instruction.type = InstructionType.Not
    table.remove(instruction.operands, 3)
  end
  
  return instruction
end

function MacroAnalyzer:analyzeSub(instruction)
  if instruction.operands[2].value == 0 then
    instruction.mnemonic = "NEG"
    instruction.ismacro = true
    instruction.type = InstructionType.Negate
    table.remove(instruction.operands, 2)
  end
  
  return instruction
end

function MacroAnalyzer:analyzeSll(instruction)
  for _, op in pairs(instruction.operands) do
    if op.value ~= 0 then
      return instruction
    end
  end
  
  instruction.mnemonic = "NOP"
  instruction.operands = { }
  instruction.type = InstructionType.Nop
  return instruction
end

return MacroAnalyzer
