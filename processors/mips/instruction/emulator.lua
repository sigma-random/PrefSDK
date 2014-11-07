local oop = require("oop")
local pref = require("pref")

local DataType = pref.datatype

local InstructionEmulator = oop.class()

function InstructionEmulator:__ctor(processor)
  self.processor = processor
  
  self.dispatcher = { ADD  = InstructionEmulator.emulateAdd,
                      ADDU = InstructionEmulator.emulateAdd,
                      LI   = InstructionEmulator.emulateLi,
                      LW   = InstructionEmulator.emulateLw,
                      MOVE = InstructionEmulator.emulateMove,
                      SLL  = InstructionEmulator.emulateSll }
end

function InstructionEmulator:emulateAdd(instruction)
  self.processor.gpr[instruction.operands[1].value] = self.processor.gpr[instruction.operands[2].value] + self.processor.gpr[instruction.operands[3].value]
end

function InstructionEmulator:emulateLi(instruction)
  self.processor.gpr[instruction.operands[1].value] = instruction.operands[2].value
end

function InstructionEmulator:emulateLw(instruction, memorybuffer)
  if instruction.ismacro then
    self.processor.gpr[instruction.operands[1].value] = memorybuffer:read(instruction.operands[2].value, DataType.UInt32)
  else
    self.processor.gpr[instruction.operands[1].value] = memorybuffer:read(self.processor.gpr[instruction.operands[2].base] + instruction.operands[2].disp, DataType.UInt32)
  end
end

function InstructionEmulator:emulateMove(instruction)
  self.processor.gpr[instruction.operands[1].value] = instruction.operands[2].value
end

function InstructionEmulator:emulateSll(instruction)
  self.processor.gpr[instruction.operands[1].value] = bit.lshift(self.processor.gpr[instruction.operands[2].value], instruction.operands[3].value)
end

function InstructionEmulator:execute(instruction, memorybuffer)
  local d = self.dispatcher[instruction.mnemonic]
  self.processor.gpr[0] = 0 -- $zero register is always 0
  
  if d then
    d(self, instruction, memorybuffer)
  end
end

return InstructionEmulator