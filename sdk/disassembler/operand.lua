local oop = require("oop")
local pref = require("pref")

local Operand = oop.class()
Operand.datatype = pref.datatype.Invalid
Operand.size = 0

function Operand:setDataType(datatype)
  self.datatype = datatype
  self.size = pref.datatype.sizeof(datatype)
end

function Operand:create(datatype, type, value)
  local op = Operand()
  op.datatype = datatype
  op.type = type
  op.value = value
  
  return op
end

function Operand:define(type, datatype, value)
  local opclass = oop.class(Operand)
  opclass.type = type
  
  if datatype then
    opclass:setDataType(datatype)
  end
  
  if value then
    opclass.value = value
  end
  
  return opclass
end

return Operand