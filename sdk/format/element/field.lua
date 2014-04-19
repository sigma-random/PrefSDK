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
  local datatype = self:dataType()
  
  if DataType.isInteger(datatype) then
    if DataType.isSigned(datatype) then
      if DataType.bitWidth(datatype) == 8 then
        return C.QHexEditData_readInt8(self._databuffer, self:offset())
      elseif DataType.bitWidth(datatype) == 16 then
        return C.QHexEditData_readInt16(self._databuffer, self:offset(), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        return C.QHexEditData_readInt32(self._databuffer, self:offset(), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        return C.QHexEditData_readInt64(self._databuffer, self:offset(), DataType.byteOrder(datatype))
      end
    else
      if DataType.bitWidth(datatype) == 8 then
        return C.QHexEditData_readUInt8(self._databuffer, self:offset())
      elseif DataType.bitWidth(datatype) == 16 then
        return C.QHexEditData_readUInt16(self._databuffer, self:offset(), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        return C.QHexEditData_readUInt32(self._databuffer, self:offset(), DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        return C.QHexEditData_readUInt64(self._databuffer, self:offset(), DataType.byteOrder(datatype))
      end
    end
  elseif datatype == DataType.Character then
    return tostring(ffi.cast("char", C.QHexEditData_readUInt8(self._databuffer, self:offset())))
  end
  
  return FieldElement:value()
end

return Field