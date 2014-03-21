local Structure = require("sdk.format.element.structure")

FormatTree = { _structureoffsets = { },
               _structures = { },
               _buffer = nil }
               
FormatTree.__index = FormatTree

function FormatTree:new(buffer)
  local o = setmetatable({ }, FormatTree)
  
  o._buffer = buffer
end

function FormatTree:structureCount()
  return #self._structureoffsets
end

function FormatTree:structure(i)
  return self._structures[self._structureoffsets[i]]
end

function FormatTree:indexOf(s)
  for i,v in ipairs(self._structureoffsets) do
    if v == s:offset()
      return i - 1
    end
  end
  
  return -1
end

function FormatTree:addStructure(name, offset)
  local newoffset = offset and offset or self._structureoffsets[table.maxn(self._structureoffsets)]
  local s = Structure(newoffset, name, { }, self, self._buffer)
  
  table.insert(self._structureoffsets, newoffset)
  table.sort(self._structureoffsets)
  
  self._structures[newoffset] = s
  return s
end