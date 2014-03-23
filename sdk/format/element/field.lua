require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FieldElement = require("sdk.format.element.fieldelement")
local BitField = require("sdk.format.element.bitfield")

local Field = class(FieldElement)

function Field:__ctor(datatype, offset, name, parent, tree, buffer)
  FieldElement.__ctor(self, datatype, offset, name, parent, tree, buffer)
  
  self._bitfieldnames = { }
  self._bitfieldids = { }
end

function Field:hasChildren()
  if not FieldElement.isDynamic(self) then
    return #self._bitfieldnames > 0
  end
  
  return FieldElement.hasChildren(self)
end

function Field:elementType()
  return ElementType.Field
end

function Field:value()
  return self._buffer:readType(self._offset, self._datatype)
end

function Field:indexOf(bf)
  for i,v in ipairs(self._bitfieldnames) do
    if v == bf:name() then
      return i
    end
  end
  
  return -1
end

function Field:setBitField(name, bitstart, bitend)
  local realbitend = bitend and bitend or bitstart
  local bf = BitField(bitstart, realbitend, self._offset, name, self, self._tree, self._buffer)
  
  table.insert(self._bitfieldnames, name)
  self[name] = bf
  self._bitfieldids[name] = bf:elementId()
  return bf
end

function Field:bitFieldCount()
  return #self._bitfieldnames
end

function Field:bitFieldId(i)
  local name = self._bitfieldnames[i]
  return self._bitfieldids[name]
end

function Field:bitField(i)
  local id = self:bitFieldId(i)
  return self._tree.pool[id]
end

return Field