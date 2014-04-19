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

function BitField:__ctor(cthis, databuffer)
  FieldElement.__ctor(self, cthis, databuffer)
end

function BitField:bitStart()
  return C.BitField_getBitStart(self._cthis)
end

function BitField:bitEnd()
  return C.BitField_getBitEnd(self._cthis)
end

return BitField