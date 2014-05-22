local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local ByteOrder = require("sdk.types.byteorder")
local DataType = require("sdk.types.datatype")

local C = ffi.C
local DataBuffer = oop.class()

function DataBuffer:__ctor(cthis, baseoffset)
  self.cthis = cthis
  self.creader = C.QHexEditData_createReader(cthis)
  self.cwriter = C.QHexEditData_createWriter(cthis)
  self.baseoffset = baseoffset
end

function DataBuffer:copyTo(databuffer, startoffset, endoffset)
  C.QHexEditData_copyTo(self.cthis, databuffer.cthis, startoffset or 0, endoffset or self:length())
end

function DataBuffer:length()
  return tonumber(C.QHexEditData_length(self.cthis) - self.baseoffset)
end

function DataBuffer:indexOf(s, pos)
  return tonumber(C.QHexEditDataReader_indexOf(self.creader, (pos and self.baseoffset + pos or 0), s))
end

function DataBuffer:indexOfEol(pos)
  local cr = self:indexOf("\r", self.baseoffset + pos)
  local lf = self:indexOf("\n", self.baseoffset + pos)
      
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
  if (self.baseoffset + pos) >= self:length() then
    return '\0'
  end
  
  local s = tostring(C.QHexEditDataReader_readAsciiChar(self.creader, self.baseoffset + pos))
  return string.char(s)
end

function DataBuffer:readString(pos, len)
  return ffi.string(C.QHexEditDataReader_readString(self.creader, self.baseoffset + pos, len or -1))
end

function DataBuffer:readLine(pos)
  return ffi.string(C.QHexEditDataReader_readLine(self.creader, self.baseoffset + pos))
end

function DataBuffer:readUInt8(pos)
  return C.QHexEditDataReader_readUInt8(self.creader, self.baseoffset + pos)
end

function DataBuffer:readUInt16(pos, endian)
  return C.QHexEditDataReader_readUInt16(self.creader, self.baseoffset + pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readUInt32(pos, endian)
  return C.QHexEditDataReader_readUInt32(self.creader, self.baseoffset + pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readUInt64(pos, endian)
  return C.QHexEditDataReader_readUInt64(self.creader, self.baseoffset + pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt8(pos)
  return C.QHexEditDataReader_readInt8(self.creader, self.baseoffset + pos)
end

function DataBuffer:readInt16(pos, endian)
  return C.QHexEditDataReader_readInt16(self.creader, self.baseoffset + pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt32(pos, endian)
  return C.QHexEditDataReader_readInt32(self.creader, self.baseoffset + pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readInt64(pos, endian)
  return C.QHexEditDataReader_readInt64(self.creader, self.baseoffset + pos, endian or ByteOrder.PlatformEndian)
end

function DataBuffer:readType(pos, datatype, endian)
  if DataType.isInteger(datatype) then
    if DataType.isSigned(datatype) then
      if DataType.bitWidth(datatype) == 8 then
        return self:readInt8(pos)
      elseif DataType.bitWidth(datatype) == 16 then
        return self:readInt16(pos, endian or DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        return self:readInt32(pos, endian or DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        return self:readInt64(pos, endian or DataType.byteOrder(datatype))
      end
    else
      if DataType.bitWidth(datatype) == 8 then
        return self:readUInt8(pos)
      elseif DataType.bitWidth(datatype) == 16 then
        return self:readUInt16(pos, endian or DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 32 then
        return self:readUInt32(pos, endian or DataType.byteOrder(datatype))
      elseif DataType.bitWidth(datatype) == 64 then
        return self:readUInt64(pos, endian or DataType.byteOrder(datatype))
      end
    end
  elseif datatype == DataType.Character then
    return tostring(ffi.cast("char", self:readUInt8(self._databuffer, self.baseoffset + pos)))
  end
  
  error("DataBuffer:readType(): Unsupported DataType")
end

return DataBuffer