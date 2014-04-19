local ffi = require("ffi")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  const char* FormatElement_getId(void* __this);
  uint64_t FormatElement_getOffset(void* __this);
  uint64_t FormatElement_getEndOffset(void* __this);
  uint64_t FormatElement_getSize(void* __this);
  int FormatElement_getBase(void* __this);
  void FormatElement_setBase(void* __this, int b);
  void FormatElement_setDynamic(void* __this, bool b);
]]

local C = ffi.C
local FormatElement = oop.class()

function FormatElement:__ctor(cthis, databuffer, parentelement)
 self._cthis = cthis
 self._databuffer = databuffer
 self._parentelement = parentelement
 self.id = ffi.string(C.FormatElement_getId(cthis))
end

function FormatElement:offset()
  return C.FormatElement_getOffset(self._cthis)
end

function FormatElement:endOffset()
  return C.FormatElement_getEndOffset(self._cthis)
end

function FormatElement:size()
  return C.FormatElement_getSize(self._cthis)
end

function FormatElement:base()
  return C.FormatElement_getBase(self._cthis)
end

function FormatElement:value()
  return nil
end

function FormatElement:hasParent()
  return (self._parentelement ~= nil)
end

function FormatElement:parentElement()
  return self._parentelement
end

function FormatElement:dynamicParser(condition, fn)
  if condition == true then
    local f = Sdk.loadedformats[self._databuffer]
    f.dynamicelements[self.id] = { element = self, parseprocedure = fn }
  end
  
  C.FormatElement_setDynamic(self._cthis, condition)
  return self
end

function FormatElement:dynamicInfo(fn)
  local f = Sdk.loadedformats[self._databuffer]
  f.elementsinfo[self.id] = { element = self, infoprocedure = fn }
  return self
end

function FormatElement:staticInfo(infostring)  
  local fn = function(element) 
               return infostring
             end
  
  return self:dynamicInfo(fn)
end

function FormatElement:setBase(b)
  C.FormatElement_setBase(self._cthis, b)
end

return FormatElement