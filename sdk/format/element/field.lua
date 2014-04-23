local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local FieldElement = require("sdk.format.element.fieldelement")
local BitField = require("sdk.format.element.bitfield")

ffi.cdef
[[
  void* Field_setBitField(void* __this, const char* name, int bitstart, int bitend);
  int Field_getBitFieldCount(void* __this);
]]

local C = ffi.C
local Field = oop.class(FieldElement)

function Field:__ctor(cthis, databuffer, parentelement)
  FieldElement.__ctor(self, cthis, databuffer, parentelement)
end

function Field:setBitField(name, bitstart, bitend)
  local bf = BitField(C.Field_setBitField(self._cthis, name, bitstart, bitend or bitstart), self._databuffer, self)
  
  self[name] = bf
  return bf
end

function Field:bitFieldCount()
  return C.Field_getBitFieldCount(self._cthis)
end

function Field:value()
  return self._databuffer:readType(self:offset(), self:dataType())
end

return Field