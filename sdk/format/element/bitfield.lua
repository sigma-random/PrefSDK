local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local FieldElement = require("sdk.format.element.fieldelement")

ffi.cdef
[[  
  uint64_t BitField_getMask(void* __this);
  int BitField_getBitStart(void* __this);
  int BitField_getBitEnd(void* __this);
]]

local C = ffi.C
local BitField = oop.class(FieldElement)

function BitField:__ctor(cthis, databuffer, parentelement)
  FieldElement.__ctor(self, cthis, databuffer, parentelement)
end

function BitField:bitStart()
  return C.BitField_getBitStart(self._cthis)
end

function BitField:bitEnd()
  return C.BitField_getBitEnd(self._cthis)
end

function BitField:value()
  local mask = C.BitField_getMask(self._cthis)
  local fieldvalue = self._parentelement:value()
  
  return bit.rshift(bit.band(fieldvalue, tonumber(mask)), self:bitStart())
end

return BitField