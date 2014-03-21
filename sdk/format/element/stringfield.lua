require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FieldArray = require("sdk.format.element.fieldarray")

local StringField = class(FieldArray)

function StringField.__ctor(itemcount, offset, name, parent, tree, buffer)
  FieldArray.__ctor(DataType.Char, itemcount, offset, name, parent, tree, buffer)
end

function StringField:displayValue()
  local len = self._elementcount
  local s = self._buffer.readString(self._offset, len)
  return string.format("'%s'", s)
end

return StringField