local oop = require("oop")

local Instruction = oop.class()

function Instruction:__ctor(address, mnemonic, type, isjump, iscall, isconditional)
  self.address = address
  self.mnemonic = mnemonic
  self.type = type
  self.size = 0
  self.destination = 0
  self.isdestinationvalid = false
  self.ismacro = false
  self.isconditional = isconditional or false
  self.isjump = isjump or false
  self.iscall = iscall or false
  self.operands = { }
end

return Instruction
  