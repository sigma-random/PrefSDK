require("sdk.lua.class")
require("sdk.format.element.elementtype")
local FormatElement = require("sdk.format.element.formatelement")
local FieldArray = require("sdk.format.element.fieldarray")
local StringField = require("sdk.format.element.stringfield")
local Field = require("sdk.format.element.field")

local Structure = class(FormatElement)

function Structure:__ctor(offset, name, parent, tree, buffer, pool)
  FormatElement.__ctor(self, offset, name, parent, tree, buffer, pool)
  
  self._fieldoffsets = { }
  self._fieldids = { }
end

function Structure:elementType()
  return ElementType.Structure
end

function Structure:displayType()
  return "Struct"
end

function Structure:hasChildren()
  if not FormatElement.isDynamic(self) then
    return #self._fieldoffsets > 0
  end
  
  return FormatElement.hasChildren(self)
end

function Structure:addStructure(name)
  local newoffset = self._offset + self:size()
  local s = Structure(newoffset, name, self, self._tree, self._buffer)
  
  table.insert(self._fieldoffsets, newoffset)
  table.sort(self._fieldoffsets)
  
  self[name] = s
  self._fieldids[newoffset] = s:elementId()
  return s
end

function Structure:addField(fieldtype, name, count)
  local newoffset = self._offset + self:size()
  local f = nil
    
  if count then
    if not DataType.isString(fieldtype) and not count then
      error("Structure:addField(): Array size expected")
    elseif DataType.isString(fieldtype) then
      local len = count and count or #self._buffer:readString(self._offset)
      f = StringField(len, newoffset, name, self, self._tree, self._buffer)
    else
      f = FieldArray(fieldtype, count, newoffset, name, self, self._tree, self._buffer)
    end
  else
    f = Field(fieldtype, newoffset, name, self, self._tree, self._buffer)
  end

  table.insert(self._fieldoffsets, newoffset)
  table.sort(self._fieldoffsets)
  
  self[name] = f
  self._fieldids[newoffset] = f:elementId()
  return f
end

function Structure:fieldCount()
  return #self._fieldoffsets
end

function Structure:fieldId(i)
  local offset = self._fieldoffsets[i]
  return self._fieldids[offset]
end

function Structure:field(i)
  local id = self:fieldId(i)
  return self._tree.pool[id]
end

function Structure:setBase(b)
  self._base = b
  
  for k,v in pairs(self._fieldids) do
    self._tree.pool[v]:setBase(b)
  end
end

function Structure:indexOf(f)
  for i,v in ipairs(self._fieldoffsets) do
    if v == f:offset() then
      return i
    end
  end
  
  return -1
end

function Structure:size()
  local s = 0
  
  for k,v in pairs(self._fieldids) do
    s = s + self._tree.pool[v]:size()
  end
  
  return s
end

return Structure