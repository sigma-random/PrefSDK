local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local ElementType = require("sdk.format.element.elementtype")
local Structure = require("sdk.format.element.structure")

ffi.cdef
[[  
  void* FormatTree_addStructure(void* __this, const char* name);
  void* FormatTree_addStructureAtOffset(void* __this, const char* name, uint64_t offset);
  void* FormatTree_getStructure(void* __this, uint64_t i);
  uint64_t FormatTree_getStructureCount(void* __this);
]]

local C = ffi.C
local FormatTree = oop.class()

function FormatTree:__ctor(cthis, databuffer)
  self._cthis = cthis
  self._databuffer = databuffer
end

function FormatTree:structureCount()
  return C.FormatTree_getStructureCount(self._cthis)
end

function FormatTree:structure(i)  
  local cstruct = C.FormatTree_getStructure(self._cthis, i)
  return Structure(cstruct)
end

function FormatTree:addStructure(name, offset)
  local cstruct = nil
  
  if offset then
    cstruct = C.FormatTree_addStructureAtOffset(self._cthis, name, offset)
  else
    cstruct = C.FormatTree_addStructure(self._cthis, name)
  end
  
  local s = Structure(cstruct, self._databuffer)
  self[name] = s
  return s
end

return FormatTree