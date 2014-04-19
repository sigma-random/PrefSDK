local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local FieldElement = require("sdk.format.element.fieldelement")
local BitField = require("sdk.format.element.bitfield")

ffi.cdef
[[  
  int FieldArray_getItemType(void* __this);
  int FieldArray_getItemCount(void* __this);
]]

local C = ffi.C
local FieldArray = oop.class(FieldElement)

function FieldArray:__ctor(cthis, databuffer, parentelement)
  FieldElement.__ctor(self, cthis, databuffer, parentelement)
end

function FieldArray:itemType()
  return C.FieldArray_getItemType(self._cthis)
end

function FieldArray:itemCount()
return C.FieldArray_getItemCount(self._cthis)
end

return FieldArray