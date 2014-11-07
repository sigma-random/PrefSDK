local oop = require("oop")
local Instruction = require("sdk.disassembler.instruction")
local InstructionType = require("processors.mips.instruction.type")

local InvalidInstruction = oop.class(Instruction)

function InvalidInstruction:__ctor(address)
  self:__super(address, "???", InstructionType.Invalid)
  self.size = 4
end

return InvalidInstruction
 
