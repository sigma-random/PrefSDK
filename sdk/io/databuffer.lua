local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local ByteOrder = require("sdk.types.byteorder")
local DataType = require("sdk.types.datatype")

local C = ffi.C
local DataBuffer = oop.class()

function DataBuffer:__ctor(cthis)
  self.cthis = cthis
end

function DataBuffer:copyTo(databuffer)
  C.QHexEditData_copyTo(self.cthis, databuffer._cthis)
end

function DataBuffer:length()
  return tonumber(C.QHexEditData_length(self.cthis))
end

function DataBuffer:indexOf(s, pos)
  return tonumber(C.QHexEditData_indexOf(self.cthis, pos or 0, s))
end

function DataBuffer:indexOfEol(pos)
  local cr = self:indexOf("\r", pos)
  local lf = self:indexOf("\n", pos)
      
  if cr ~= -1 and lf ~= -1 then
    return math.min(cr, lf)
  elseif cr == -1 and lf ~= -1 then
    return lf
  elseif cr ~= -1 and lf == -1 then
    return cr
  end
  
  return -1
end

function DataBuffer:readChar(pos)
  if pos >= self:length() then
    return '\0'
  end
  
  local s = tostring(C.QHexEditData_readAsciiChar(self.cthis, pos))
  return string.char(s)
end

function DataBuffer:readString(pos, len)
  return ffi.string(C.QHexEditData_readString(self.cthis, pos, len or -1))
end

function DataBuffer:readLine(pos)
  return ffi.string(C.QHexEditData_readLine(self.cthis, pos))
end

function DataBuffer:readUInt8(pos)
  return C.QHexEditData_readUInt8(self.cthis, pos)
end

function DataBuffer:readUInt16(pos, endian)
  return C.QHexEditData_readUInt16(self.cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readUInt32(pos, endian)
  return C.QHexEditData_readUInt32(self.cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readUInt64(pos, endian)
  return C.QHexEditData_readUInt64(self.cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt8(pos)
  return C.QHexEditData_readInt8(self.cthis, pos)
end

function DataBuffer:readInt16(pos, endian)
  return C.QHexEditData_readInt16(self.cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt32(pos, endian)
  return C.QHexEditData_readInt32(self.cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt64(pos, endian)
  return C.QHexEditData_readInt64(self.cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readType(pos, datatype)
  if DataType.isInteger(datatype) then
    if DataType.isSigned(datatype) then
      if DataType.bitWidth(datatype) == 8 then
        return self:readInt8(pos)
      elseif DataType.bitWidth(datatype) == 16 then
        return self:readInt16(pos, DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        return self:readInt32(pos, DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        return self:readInt64(pos, DataType.byteOrder(datatype))
      end
    else
      if DataType.bitWidth(datatype) == 8 then
        return self:readUInt8(pos)
      elseif DataType.bitWidth(datatype) == 16 then
        return self:readUInt16(pos, DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        return self:readUInt32(pos, DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        return self:readUInt64(pos, DataType.byteOrder(datatype))
      end
    end
  elseif datatype == DataType.Character then
    return tostring(ffi.cast("char", self:readUInt8(self._databuffer, pos)))
  end
  
  error("DataBuffer:readType(): Unsupported DataType")
end

return DataBuffer