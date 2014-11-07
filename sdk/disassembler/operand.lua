local oop = require("oop")

local Operand = oop.class()

function Operand:__ctor(datatype, type, value)
  self.datatype = datatype
  self.type = type
  self.value = value
end

return Operand