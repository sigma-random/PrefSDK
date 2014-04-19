local ffi = require("ffi")

ffi.cdef
[[
  /* DataType's Flags */
  const uint64_t DataType_Invalid;

  const uint64_t DataType_UInt8;
  const uint64_t DataType_UInt16;
  const uint64_t DataType_UInt32;
  const uint64_t DataType_UInt64;

  const uint64_t DataType_Int8;
  const uint64_t DataType_Int16;
  const uint64_t DataType_Int32;
  const uint64_t DataType_Int64;

  const uint64_t DataType_UInt16_LE;
  const uint64_t DataType_UInt32_LE;
  const uint64_t DataType_UInt64_LE;

  const uint64_t DataType_Int16_LE;
  const uint64_t DataType_Int32_LE;
  const uint64_t DataType_Int64_LE;
  
  const uint64_t DataType_UInt16_BE;
  const uint64_t DataType_UInt32_BE;
  const uint64_t DataType_UInt64_BE;

  const uint64_t DataType_Int16_BE;
  const uint64_t DataType_Int32_BE;
  const uint64_t DataType_Int64_BE;
  
  const uint64_t DataType_AsciiCharacter;
  const uint64_t DataType_UnicodeCharacter;
  const uint64_t DataType_Character;

  const uint64_t DataType_Array;
  const uint64_t DataType_AsciiString;
  const uint64_t DataType_UnicodeString;

  const uint64_t DataType_Blob;

  /* DataType's Functions */
  bool DataType_isInteger(uint64_t type);
  bool DataType_isSigned(uint64_t type);
  bool DataType_isString(uint64_t type);
  bool DataType_isAscii(uint64_t type);
  bool DataType_isUnicode(uint64_t type);
  bool DataType_isArray(uint64_t type);
  int DataType_sizeOf(uint64_t type);
  int DataType_byteOrder(uint64_t type);
  int DataType_byteWidth(uint64_t type);
  int DataType_bitWidth(uint64_t type);
  const char* DataType_stringValue(uint64_t type);
]]

local C = ffi.C
local DataType = { Invalid               = C.DataType_Invalid,
  
                   UInt8                 = C.DataType_UInt8,
                   UInt16                = C.DataType_UInt16,
                   UInt32                = C.DataType_UInt32,
                   UInt64                = C.DataType_UInt64,
                   
                   Int8                  = C.DataType_Int8,
                   Int16                 = C.DataType_Int16,
                   Int32                 = C.DataType_Int32,
                   Int64                 = C.DataType_Int64,
                   
                   UInt16_LE             = C.DataType_UInt16_LE,
                   UInt32_LE             = C.DataType_UInt32_LE,
                   UInt64_LE             = C.DataType_UInt64_LE,
                   
                   Int16_LE              = C.DataType_Int16_LE,
                   Int32_LE              = C.DataType_Int32_LE,
                   Int64_LE              = C.DataType_Int64_LE,
                   
                   UInt16_BE             = C.DataType_UInt16_BE,
                   UInt32_BE             = C.DataType_UInt32_BE,
                   UInt64_BE             = C.DataType_UInt64_BE,
                   
                   Int16_BE              = C.DataType_Int16_BE,
                   Int32_BE              = C.DataType_Int32_BE,
                   Int64_BE              = C.DataType_Int64_BE,
                   
                   AsciiCharacter        = C.DataType_AsciiCharacter,
                   UnicodeCharacter      = C.DataType_UnicodeCharacter,
                   Character             = C.DataType_Character,
                   
                   Array                 = C.DataType_Array,
                   AsciiString           = C.DataType_AsciiString,
                   UnicodeString         = C.DataType_UnicodeString,
                   
                   Blob                  = C.DataType_Blob }
             
function DataType.isInteger(datatype)
  return C.DataType_isInteger(datatype)
end

function DataType.isSigned(datatype)
  return C.DataType_isSigned(datatype)
end

function DataType.isString(datatype)
  return C.DataType_isString(datatype)
end

function DataType.isUnicode(datatype)
  return C.DataType_isUnicode(datatype)
end

function DataType.isArray(datatype)
  return C.DataType_isArray(datatype)
end

function DataType.sizeOf(datatype)
  return C.DataType_sizeOf(datatype)
end

function DataType.byteOrder(datatype)
  return C.DataType_byteOrder(datatype)
end

function DataType.byteWidth(datatype)
  return C.DataType_byteWidth(datatype)
end

function DataType.bitWidth(datatype)
  return C.DataType_bitWidth(datatype)
end

function DataType.stringValue(datatype)
  return C.DataType_stringValue(datatype)
end

return DataType