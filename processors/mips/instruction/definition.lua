local oop = require("oop")
local InstructionType = require("processors.mips.instruction.type")

local InstructionDefinition = oop.class()

function InstructionDefinition:__ctor(mnemonic, type, operands)
  self.mnemonic = mnemonic
  self.type = type
  self.operands = operands or { }
  
  self.isconditional = (type == InstructionType.ConditionalJump) or (type == InstructionType.ConditionalCall)
  self.isjump = (type == InstructionType.Jump) or (type == InstructionType.ConditionalJump)
  self.iscall = (type == InstructionType.Call) or (type == InstructionType.ConditionalCall)
end

return InstructionDefinition
  