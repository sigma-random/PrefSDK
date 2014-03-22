require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FieldElement = require("sdk.format.element.fieldelement")
local BitField = require("sdk.format.element.bitfield")

local FieldArray = class(FieldElement)

function FieldArray.__ctor(itemtype, itemcount, offset, name, parent, tree, buffer)
  FieldElement.__ctor(self, DataType.Array, offset, name, parent, tree, buffer)
  
  self._itemcount = itemcount
  self._itemtype = itemtype
  self._itemoffsets = { }
  self._itemids = { }
  
  if itemtype ~= DataType.Blob then
    local i = 1
    local itemoffset = offset
    local itemsize = DataType.sizeOf(itemtype)
    
    while i <= itemcount do
      local itemname = string.format("%s[%d]", name, i - 1)
      local f = Field(itemtype, itemoffset, itemname, self, tree, buffer)
      
      self._itemoffsets[i] = itemoffset
      self._itemids[itemoffset] = f:id()
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
  
  for k,v in pairs(self._itemids) do
    self._tree.pool[v]:setBase(b)
  end
end

function FieldArray:itemType()
  return self._itemtype
end

function FieldArray:itemCount()
  return self._itemcount
end

function FieldArray:itemId(i)
  local offset = self._itemoffsets[i]
  return self._itemids[offset]
end

function FieldArray:item(i)
  local id = self:itemId(i)
  return self._tree.pool[id]
end

function FieldArray:indexOf(item)
  for i,v in ipairs(self._itemoffsets) do
    if v == item:offset() then
      return i
    end
  end
  
  return -1
end

function FieldArray:displayType()
  return string.format("%s[]", DataType.stringValue(self._itemtype))
end

function FieldArray:displayName()
  return string.format("%s[%d]", DataType.stringValue(self._itemtype), self._itemcount)
end

function FieldArray:displayValue()
  return ""
end

return FieldArray