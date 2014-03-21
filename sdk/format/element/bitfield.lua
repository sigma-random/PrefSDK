require("sdk.lua.class")
require("sdk.types.datatype")
require("sdk.formats.element.elementtype")
local FieldElement = require("sdk.format.element.field")

BitField = class(FieldElement)

function BitField:__ctor(bitstart, bitend, offset, name, parent, tree, buffer)
  FieldElement.__ctor(self, offset, name, parent, tree, buffer)
  
  self._bitstart = bitstart
  self._bitend = bitend
  self._mask = self:createMask(bitstart, bitend)
end

function BitField:elementType()
  return ElementType.BitField
end

function BitField:displayType()
  if self._bitstart == self._bitend then
    return "bit"
  end
  
  return "bit[]"
end

function BitField:displayName()
  if self._bitstart == self._bitend then
    return string.format("%1[%2]", self._name, self._bitstart)
  end
  
  return string.format("%1[%2..%3]", self._name, self._bitstart, self._bitend)
end

function BitField:bitStart()
  return self._bitstart
end

function BitField:bitEnd()
  return self._bitend
end

function BitField:value()
  local v = self._parent:value()
  return bit.rshift(bit.band(v, self._mask), self._bitstart)
end

function BitField:size()
  return 0 -- No Size for BitFields
end

function BitField:createMask(bitstart, bitend)
  local i = 0
  local mask = 0x00000000
  
  while i < 32 do
    
    if (i >= bitstart) and (i <= bitend) then
        mask = bit.bor(mask, bit.lshift(1, i))
    else
        mask = bit.bor(mask, bit.lshift(0, i))
    end
    
    i = i + 1
  end
end