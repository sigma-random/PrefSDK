local oop = require("sdk.lua.oop") 
local DataType = require("sdk.types.datatype")
local OperandType = require("sdk.disassembler.operandtype")

local Operand = oop.class()

function Operand:__ctor()
  self.type = OperandType.Void
  self.datatype = DataType.Invalid
  self.value = -1
  self.address = -1
  self.reg = -1
  self.phrase = { }
end

return Operand