require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FieldElement = require("sdk.format.element.fieldelement")
local BitField = require("sdk.format.element.bitfield")

local Field = class(FieldElement)

function Field:__ctor(fieldtype, offset, name, parent, tree, buffer)
  FieldElement.__ctor(self, offset, name, parent, tree, buffer)
  
  self._bitfieldnames = { }
  self._bitfields = { }
end

function Field:elementType()
  return ElementType.Field
end

function Field:value()
  return self._buffer:readType(self._offset, self._datatype)
end

function Field:setBitField(name, bitstart, bitend)
  local realbitend = bitend and bitend or bitstart
  local bf = BitField(bitstart, realbitend, self._offset, name, self, self._tree, self._buffer)
  
  table.insert(self._bitfieldnames, name)
  self._bitfields[name] = bf
  return bf
end

function Field:bitFieldCount()
  return #self._bitfieldnames
end

function Field:bitField(i)
  return self._bitfields[self._bitfieldnames[i]]
end

return Field