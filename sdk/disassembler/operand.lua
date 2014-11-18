local oop = require("oop")
local pref = require("pref")

local Operand = oop.class()

function Operand:__ctor(datatype, value)
  self.datatype = datatype
  self.size = pref.datatype.sizeof(datatype)
  self.value = value
end

function Operand:create(datatype, type, value)
  local op = Operand(datatype, value)
  op.type = type
  
  return op
end

return Operand