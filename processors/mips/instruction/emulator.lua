local oop = require("oop")
local pref = require("pref")

local DataType = pref.datatype

local InstructionEmulator = oop.class()

function InstructionEmulator:__ctor()
  self.gpr = { [0]  = 0, [1]  = 0, [2]  = 0, [3]  = 0, [4]  = 0, [5]  = 0, [6]  = 0, [7]  = 0, 
               [8]  = 0, [9]  = 0, [10] = 0, [11] = 0, [12] = 0, [13] = 0, [14] = 0, [15] = 0, 
               [16] = 0, [17] = 0, [18] = 0, [19] = 0, [20] = 0, [21] = 0, [22] = 0, [23] = 0, 
               [24] = 0, [25] = 0, [26] = 0, [27] = 0, [28] = 0, [29] = 0, [30] = 0, [31] = 0 }
  
  self.dispatcher = { ADD   = InstructionEmulator.emulateAdd,
                      ADDU  = InstructionEmulator.emulateAdd,
                      ADDI  = InstructionEmulator.emulateAddi,
                      ADDIU = InstructionEmulator.emulateAddi,
                      AND   = InstructionEmulator.emulateAnd,
                      ANDI  = InstructionEmulator.emulateAndi,
                      LW    = InstructionEmulator.emulateLw,
                      ORI   = InstructionEmulator.emulateOri,
                      SLL   = InstructionEmulator.emulateSll,
                      XORI  = InstructionEmulator.emulateXori,
                      
                      -- Macro Instructions
                      LI    = InstructionEmulator.emulateLi,
                      MOVE  = InstructionEmulator.emulateMove }
end

function InstructionEmulator:emulateAdd(instruction)
  self.gpr[instruction.operands[1].value] = self.gpr[instruction.operands[2].value] + self.gpr[instruction.operands[3].value]
end

function InstructionEmulator:emulateAddi(instruction)
  self.gpr[instruction.operands[1].value] = self.gpr[instruction.operands[2].value] + instruction.operands[3].value
end

function InstructionEmulator:emulateAnd(instruction)
  self.gpr[instruction.operands[1].value] = bit.band(self.gpr[instruction.operands[2].value], self.gpr[instruction.operands[3].value])
end

function InstructionEmulator:emulateAndi(instruction)
  self.gpr[instruction.operands[1].value] = bit.band(self.gpr[instruction.operands[2].value], instruction.operands[3].value)
end

function InstructionEmulator:emulateLi(instruction)
  self.gpr[instruction.operands[1].value] = instruction.operands[2].value
end

function InstructionEmulator:emulateLw(instruction, memorybuffer)
  if instruction.ismacro then
    self.gpr[instruction.operands[1].value] = memorybuffer:read(instruction.operands[2].value, DataType.UInt32)
  else
    self.gpr[instruction.operands[1].value] = memorybuffer:read(self.gpr[instruction.operands[2].base] + instruction.operands[2].disp, DataType.UInt32)
  end
end

function InstructionEmulator:emulateMove(instruction)
  self.gpr[instruction.operands[1].value] = instruction.operands[2].value
end

function InstructionEmulator:emulateOri(instruction)
  self.gpr[instruction.operands[1].value] = bit.bor(self.gpr[instruction.operands[2].value], instruction.operands[3].value)
end

function InstructionEmulator:emulateSll(instruction)
  self.gpr[instruction.operands[1].value] = bit.lshift(self.gpr[instruction.operands[2].value], instruction.operands[3].value)
end

function InstructionEmulator:execute(instruction, memorybuffer)
  local d = self.dispatcher[instruction.mnemonic]
  self.gpr[0] = 0 -- $zero register is always 0
  
  if d then
    d(self, instruction, memorybuffer)
  end
end

function InstructionEmulator:emulateXori(instruction)
  self.gpr[instruction.operands[1].value] = bit.bxor(self.gpr[instruction.operands[2].value], instruction.operands[3].value)
end

return InstructionEmulator