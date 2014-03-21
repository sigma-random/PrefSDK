require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.formats.element.elementtype")
local FieldElement = require("sdk.format.element.fieldelement")
local BitField = require("sdk.format.element.bitfield")

FieldArray = class(FieldElement)

function FieldArray.__ctor(itemtype, itemcount, offset, name, parent, tree, buffer)
  FieldElement.__ctor(self, DataType.Array, offset, name, parent, tree, buffer)
  
  self._itemcount = itemcount
  self._itemtype = itemtype
  self._itemoffsets = { }
  self._items = { }
  
  if itemtype ~= DataType.Blob then
    local i = 1
    local itemoffset = offset
    local itemsize = DataType.sizeOf(itemtype)
    
    while i <= itemcount do
      local itemname = string.format("%s[%d]", name, i - 1)
      
      self._itemoffsets[i] = itemoffset
      self._items[itemoffset] = Field(itemtype, itemoffset, itemname, self, tree, buffer)
      i = i + 1
    end
  end
end

function FieldArray:elementType()
  return ElementType.FieldArray
end

function FieldArray:size()
  return DataType.sizeOf(self._datatype) * self._itemcount
end

function FieldArray:value()
  error("Cannot Read a Value from FieldArray")
end

function FieldArray:setBase(b)
  self._base = b
  
  for k,v in pairs(self._items) do
    v:setBase(b)
  end
end

function FieldArray:itemType()
  return self._itemtype
end

function FieldArray:itemCount()
  return self._itemcount
end

function FieldArray:item(i)
  return self._items[self._itemoffsets[i]]
end

function FieldArray:indexOf(item)
  for i,v in ipairs(self._itemoffsets) do
    if v == item:offset()
      return i - 1
    end
  end
  
  return -1
end

function FieldArray:displayType()
  return string.format("%s[]", DataType.stringValue(eself._itemtype))
end

function FieldArray:displayName()
  return string.format("%s[%d]", DataType.stringValue(eself._itemtype), self._itemcount)
end

function FieldArray:displayValue()
  return ""
end