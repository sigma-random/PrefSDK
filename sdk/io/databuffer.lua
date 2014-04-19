local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local ByteOrder = require("sdk.types.byteorder")

local C = ffi.C
local DataBuffer = oop.class()

function DataBuffer:__ctor(cthis)
  self._cthis = cthis
end

function DataBuffer:copyTo(databuffer)
  C.QHexEditData_copyTo(self._cthis, databuffer._cthis)
end

function DataBuffer:length()
  return tonumber(C.QHexEditData_length(self._cthis))
end

function DataBuffer:indexOf(s, pos)
  return tonumber(C.QHexEditData_indexOf(self._cthis, pos or 0, s))
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
  
  local s = tostring(C.QHexEditData_readAsciiChar(self._cthis, pos))
  return string.char(s)
end

function DataBuffer:readString(pos, len)
  return ffi.string(C.QHexEditData_readString(self._cthis, pos, len))
end

function DataBuffer:readLine(pos)
  return ffi.string(C.QHexEditData_readLine(self._cthis, pos))
end

function DataBuffer:readUInt8(pos)
  return C.QHexEditData_readUInt8(self._cthis, pos)
end

function DataBuffer:readUInt16(pos, endian)
  return C.QHexEditData_readUInt16(self._cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readUInt32(pos, endian)
  return C.QHexEditData_readUInt32(self._cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readUInt64(pos, endian)
  return C.QHexEditData_readUInt64(self._cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt8(pos)
  return C.QHexEditData_readInt8(self._cthis, pos)
end

function DataBuffer:readInt16(pos, endian)
  return C.QHexEditData_readInt16(self._cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt32(pos, endian)
  return C.QHexEditData_readInt32(self._cthis, pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt64(pos, endian)
  return C.QHexEditData_readInt64(self._cthis, pos, endian or ByteOrder.PlatformEndian)
end

return DataBuffer