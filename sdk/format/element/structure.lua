require("sdk.lua.class")
require("sdk.formats.element.elementtype")
local FormatElement = require("sdk.format.element.formatelement")
local FieldArray = require("sdk.format.element.fieldarray")
local StringField = require("sdk.format.element.stringfield")
local Field = require("sdk.format.element.field")

Structure = class(FormatElement)

function Structure:__ctor(offset, name, parent, tree, buffer)
  FormatTree.__ctor(self, offset, name, parent, tree, buffer)
  
  self._fieldoffsets = { }
  self._fields = { }
end

function Structure:elementType()
  return ElementType.Structure
end

function Structure:displayType()
  return "Struct"
end

function Structure:addStructure(name)
  local newoffset = self._offset + self:size()
  local s = Structure(newoffset, name, self, self._tree, self._buffer)
  
  table.insert(self._fieldoffsets, newoffset)
  table.sort(self._fieldoffsets)
  
  self._fields[newoffset] = s
  return s
end

function Structure:addField(fieldtype, name, count)
  local newoffset = self._offset + self:size()
  local f = nil
    
  if DataType.isArray(fieldtype) then
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
  
  self._fields[newoffset] = f
  return f
end

function Structure:setBase(b)
  self._base = b
  
  for k,v in pairs(self._fields) do
    v:setBase(b)
  end
end



function Structure:size()
  local s = 0
  
  for k,v in pairs(self._fields) do
    s = s + v:size()
  end
  
  return s
end