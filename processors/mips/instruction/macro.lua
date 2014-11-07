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
  
  self.dispatcher = { LUI   = MacroAnalyzer.analyzeLui,
                      SLT   = MacroAnalyzer.analyzeSlt,
                      SLTU  = MacroAnalyzer.analyzeSlt,
                      SLTIU = MacroAnalyzer.analyzeSlt,
                      ADDU  = MacroAnalyzer.analyzeAddu,
                      ADDIU = MacroAnalyzer.analyzeAddu,
                      NOR   = MacroAnalyzer.analyzeNor,
                      SUB   = MacroAnalyzer.analyzeSub }
end

function MacroAnalyzer:nextInstruction(instruction, memorybuffer, decodedelayslot)
  local instruction = self.processor:decode(instruction.address + instruction.size, memorybuffer)
  
  if decodedelayslot and (instruction.isjump or instruction.iscall) then -- Check Delay Slot
    instruction = self.processor:decode(instruction.address + instruction.size, memorybuffer)
  end
  
  return instruction
end

function MacroAnalyzer:analyze(instruction, memorybuffer)
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
    macroinstruction.operands = { nextinstruction.operands[1], Operand(DataType.UInt32, OperandType.Immediate, bit.lshift(instruction.operands[2].value, 16) + nextinstruction.operands[3].value) }
    return macroinstruction
  elseif ((nextinstruction.mnemonic == "LW") or (nextinstruction.mnemonic == "SW")) and (instruction.operands[1].value == nextinstruction.operands[2].base) then    
    local macroinstruction = MacroInstruction(instruction.address, nextinstruction.mnemonic, nextinstruction.type)
    macroinstruction.size = 8
    macroinstruction.operands = { nextinstruction.operands[1], Operand(DataType.UInt32, OperandType.Immediate, bit.lshift(instruction.operands[2].value, 16) + nextinstruction.operands[2].disp) }
    return macroinstruction
  end
  
  return instruction
end

function MacroAnalyzer:analyzeSlt(instruction, memorybuffer)
  local nextinstruction = self:nextInstruction(instruction, memorybuffer, false)
  
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
  
  return instruction
end

function MacroAnalyzer:analyzeAddu(instruction)
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

return MacroAnalyzer
