TypeCategories = { Undefined    = 0x00000000,
                   Unsigned     = 0x10000000,
                   Vector       = 0x20000000,

                   Integer      = 0x00010000,
                   Characters   = 0x00020000,

                   Ascii        = 0x00100000,
                   Unicode      = 0x00200000 }
                    
DataType = { Invalid       = TypeCategories.Undefined,
             UInt8         = bit.bor(TypeCategories.Unsigned, TypeCategories.Integer, 0x00000001),
             UInt16        = bit.bor(TypeCategories.Unsigned, TypeCategories.Integer, 0x00000002),
             UInt32        = bit.bor(TypeCategories.Unsigned, TypeCategories.Integer, 0x00000004),
             UInt64        = bit.bor(TypeCategories.Unsigned, TypeCategories.Integer, 0x00000008),

             Int8          = bit.bor(TypeCategories.Integer, 0x00000001),
             Int16         = bit.bor(TypeCategories.Integer, 0x00000002),
             Int32         = bit.bor(TypeCategories.Integer, 0x00000004),
             Int64         = bit.bor(TypeCategories.Integer, 0x00000008),

             AsciiChar     = bit.bor(TypeCategories.Characters, TypeCategories.Ascii),
             UnicodeChar   = bit.bor(TypeCategories.Characters, TypeCategories.Unicode),
             Char          = bit.bor(TypeCategories.AsciiChar),

             Array         = TypeCategories.Vector,
             AsciiString   = bit.bor(TypeCategories.Vector, TypeCategories.Characters, TypeCategories.Ascii),
             UnicodeString = bit.bor(TypeCategories.Vector, TypeCategories.Characters, TypeCategories.Unicode),

             Blob          = TypeCategories.Undefined }
             
function DataType.isInteger(datatype)
  return bit.band(datatype, DataType.Integer) ~= 0
end

function DataType.isSigned(datatype)
  return bit.band(datatype, DataType.Unsigned) == 0
end

function DataType.isString(datatype)
  return bit.band(datatype, bit.bor(DataType.Vector, DataType.Caracters)) ~= 0
end

function DataType.isUnicode(datatype)
  return bit.band(datatype, bit.bor(DataType.Caracters, DataType.Unicode)) ~= 0
end

function DataType.isArray(datatype)
  return bit.band(datatype, DataType.Vector) ~= 0
end

function DataType.sizeOf(datatype)
  if bit.band(datatype, DataType.Vector) then
    return 0
  end
  
  -- NOTE: Blob requires 1 byte (used as array element only)
  if (bit.band(datatype, DataType.Ascii) ~= 0) or (datatype == DataType.UInt8) or (datatype == DataType.Int8) or (datatype == DataType.Blob) then
    return 1
  end
  
  if (bit.band(datatype, DataType.Unicode) ~= 0) or (datatype == DataType.UInt16) or (datatype == DataType.Int16) then
    return 2
  end

  if (datatype == DataType.UInt32) or (datatype == DataType.Int32) then
    return 4
  end

  if (datatype == DataType.UInt64) or (datatype == DataType.Int64) then
    return 8
  end
            
  return 0
end

function DataType.byteWidth(datatype)
  if (datatype == DataType.Blob) or (datatype == DataType.AsciiChar) or (datatype == DataType.UInt8) or (datatype == DataType.Int8) then
    return 1
  end
  
  if (datatype == DataType.UnicodeChar) or (datatype == DataType.UInt16) or (datatype == DataType.Int16) then
    return 2
  end
  
  if (datatype == DataType.UInt32) or (datatype == DataType.Int32) then
    return 4
  end
  
  if (datatype == DataType.UInt64) or (datatype == DataType.Int64) then
    return 8
  end
  
  return 0
end

function DataType.stringValue(datatype)
  if datatype == DataType.AsciiChar then
    return "AsciiChar"
  end
  
  if datatype == DataType.UnicodeChar then
    return "UnicodeChar"
  end
  
  if datatype == DataType.UInt8 then
    return "UInt8"
  end
  
  if datatype == DataType.UInt16 then
    return "UInt16"
  end
  
  if datatype == DataType.UInt32 then
    return "UInt32"
  end
  
  if datatype == DataType.UInt64 then
    return "UInt64"
  end
  
  if datatype == DataType.Int8 then
    return "Int8"
  end
  
  if datatype == DataType.Int16 then
    return "Int16"
  end
  
  if datatype == DataType.Int32 then
    return "Int32"
  end
  
  if datatype == DataType.Int64 then
    return "Int64"
  end
  
  if datatype == DataType.Array then
    return "Array"
  end
  
  if datatype == DataType.AsciiString then
    return "AsciiString"
  end
  
  if datatype == DataType.UnicodeString then
    return "UnicodeString"
  end
  
  if datatype == DataType.Blob then
    return "Blob"
  end
  
  error("DataType.stringValue(): Unknown Type")
end