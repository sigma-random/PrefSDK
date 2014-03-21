require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FormatElement = require("sdk.format.element.formatelement")

FieldElement = class(FormatElement)

function FieldElement:__ctor(datatype, offset, name, parent, tree, buffer)
  FormatElement.__ctor(self, offset, name, parent, tree, buffer)
  
  self._datatype = datatype
end

function FieldElement:dataType()
  return self._datatype
end

function FieldElement:size()
  return DataType.sizeOf(self._datatype)
end

function FieldElement:displayType()
  return DataType.stringValue(self._datatype)
end

function FieldElement:displayValue()
  if self._datatype == DataType.Char then
    return self._buffer:readString(self._offset, 1)
  end
  
  return self._buffer:stringValue(self._offset, self._base, seld._datatype)
end

function FieldElement:isSigned()
  return DataType.isSigned(self._datatype)
end

function FieldElement:isInteger()
  return DataType.isInteger(self._datatype)
end

function FieldElement:isOverflowed()
  return self._buffer:willOverflow(self._offset, self._datatype)
end