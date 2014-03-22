require("sdk.lua.class")
local Structure = require("sdk.format.element.structure")

FormatTree = { pool = { },
               _structureoffsets = { },
               _structureids = { },
               _buffer = nil }
               
FormatTree.__index = FormatTree

function FormatTree:new(buffer)
  local o = setmetatable({ }, FormatTree)
  
  o._buffer = buffer
  return o
end

function FormatTree:structureCount()
  return #self._structureoffsets
end

function FormatTree:structureId(i)
  local offset = self._structureoffsets[i]
  return self._structureids[offset]
end

function FormatTree:structure(i)  
  local id = self:structureId(i)
  return self.pool[id]
end

function FormatTree:indexOf(s)
  for i,v in ipairs(self._structureoffsets) do
    if v == s:offset() then
      return i
    end
  end
  
  return -1
end

function FormatTree:addStructure(name, offset)
  local newoffset = self._buffer:baseOffset()
  
  if offset then
    newoffset = offset
  elseif #self._structureoffsets > 0 then
    local id = self:structureId(#self._structureoffsets)
    newoffset = newoffset + self.pool[id]:endOffset()
  end
    
  local s = Structure(newoffset, name, { }, self, self._buffer)
  
  table.insert(self._structureoffsets, newoffset)
  table.sort(self._structureoffsets)
  self._structureids[newoffset] = s:id()
  return s
end