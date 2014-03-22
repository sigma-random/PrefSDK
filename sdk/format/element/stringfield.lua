require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FieldArray = require("sdk.format.element.fieldarray")

local StringField = class(FieldArray)

function StringField:__ctor(itemcount, offset, name, parent, tree, buffer)
  FieldArray.__ctor(self, DataType.Char, itemcount, offset, name, parent, tree, buffer)
end

function StringField:displayValue()
  local s = self._buffer.readString(self._offset, self._itemcount)
  return string.format("'%s'", s)
end

return StringField