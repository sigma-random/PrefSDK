local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local FormatElement = require("sdk.format.element.formatelement")

ffi.cdef
[[  
  int FieldElement_getDataType(void* __this);
  bool FieldElement_isSigned(void* __this);
  bool FieldElement_isInteger(void* __this);
  bool FieldElement_isOverflowed(void* __this);
]]

local C = ffi.C
local FieldElement = oop.class(FormatElement)

function FieldElement:__ctor(cthis, databuffer, parentelement)
  FormatElement.__ctor(self, cthis, databuffer, parentelement)
end

function FieldElement:dataType()
  return C.FieldElement_getDataType(self._cthis)
end

function FieldElement:isSigned()
  return C.FieldElement_isSigned(self._cthis)
end

function FieldElement:isInteger()
  return C.FieldElement_isInteger(self._cthis)
end

function FieldElement:isOverflowed()
  return C.FieldElement_isOverflowed(self._cthis)
end

return FieldElement