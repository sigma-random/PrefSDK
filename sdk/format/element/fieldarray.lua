require("sdk.lua.class")
-- require("sdk.types.datatype")
require("sdk.format.element.elementtype")
local FieldElement = require("sdk.format.element.fieldelement")
local Field = require("sdk.format.element.field")
local BitField = require("sdk.format.element.bitfield")

local FieldArray = class(FieldElement)

function FieldArray:__ctor(itemtype, itemcount, offset, name, parent, tree, buffer)
  FieldElement.__ctor(self, DataType.Array, offset, name, parent, tree, buffer)
  
  local isblob = (itemtype == DataType.Blob)
  
  self._itemcount = itemcount
  self._itemtype = itemtype
  self._itemoffsets = { }
  self._itemids = { }
  self._dynamicparser = { completed = false, haschildren = not isblob }
  
  if not isblob then
    function self._dynamicparser.parseprocedure(fa)
      local itemoffset = fa._offset
      local itemsize = DataType.sizeOf(fa._itemtype)
      
      for i = 1, fa._itemcount do
        local itemname = string.format("%s[%d]", fa:name(), i - 1)
        local f = Field(fa._itemtype, itemoffset, itemname, fa, fa._tree, fa._buffer)
        
        fa[i - 1] = f
        fa._itemoffsets[i] = itemoffset
        fa._itemids[itemoffset] = f:elementId()
        itemoffset = itemoffset + itemsize
      end
    end
  end
end

function FieldArray:hasChildren()
  if not FieldElement.isDynamic(self) then
    return (self._itemtype ~= DataType.Blob) and (self._itemcount > 0)
  end
  
  return FieldElement.hasChildren(self)
end

function FieldArray:dynamicParser(condition, func)
  error("FieldArray:dynamicParser() cannot be called, because it's dynamic by definition")
end

function FieldArray:elementType()
  return ElementType.FieldArray
end

function FieldArray:size()
  return DataType.sizeOf(self._itemtype) * self._itemcount
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
  return string.format("%s[%d]", self:name(), self._itemcount)
end

function FieldArray:displayValue()
  return ""
end

return FieldArray