local FormatDefinition = require("sdk.format.formatdefinition")
local OperatingSystems = require("formats.gzip.gziptypes")

local GZipFormat = FormatDefinition:new("GZip Format", "Compression", "Karl", "1.0", Endian.LittleEndian)

function GZipFormat.getCompressionMethod(formatobject, buffer)
  local value = formatobject:value()
  if value == 0x08 then
	return "deflate"
  end
end

function GZipFormat.getExtraFlagsMethod(formatobject, buffer)
  local value = formatobject:value()
  
  if value == 0x02 then
    return "compressor used maximum compression, slowest algorithm"
  elseif value == 0x04 then
    return "compressor used fastest algorithm"
  end
end

function GZipFormat.getModificationTimeMethod(formatobject, buffer)
  local value = formatobject:value()
  
  if value ~= 0x00 then
    return os.date("%Y-%m-%d %H:%M", 10800 + value)
  end
end

function GZipFormat.getOperatingSystemMethod(formatobject, buffer)
  local value = formatobject:value()
  return OperatingSystems[value]
end

function GZipFormat:validateFormat(buffer)
  local sign = buffer:readType(0, DataType.UInt16)
  
  if sign ~= 0x8B1F then
    return false
  end
  
  local compression = buffer:readType(2, DataType.UInt8)
  
  if compression ~= 0x08 then
    return false
  end
  
  return true
end
    
function GZipFormat:parseFormat(formatmodel, buffer)
  local tag = buffer:readType(0, DataType.UInt16)
  
  if tag == 0x8B1F then
    GZipFormat:defineHeader(formatmodel, buffer)
    GZipFormat:defineData(formatmodel, buffer)
    GZipFormat:defineTrailer(formatmodel, buffer)
  else
    print("Unknown Tag")
  end
end 

function GZipFormat:defineHeader(formatmodel, buffer) -- 0x8B1F
  local sect = formatmodel:addStructure("GZipHeader")
  
  sect:addField(DataType.UInt16, "Signature")
  local field = sect:addField(DataType.UInt8, "CompressionMethod")
  field:dynamicInfo(GZipFormat.getCompressionMethod)
  
  field = sect:addField(DataType.UInt8, "FLAGS")
  local ftext = field:setBitField(0, "FTEXT")
  local fhcrc = field:setBitField(1, "FHCRC")
  local fextra = field:setBitField(2, "FEXTRA")
  local fname = field:setBitField(3, "FNAME")
  local fcomment = field:setBitField(4, "FCOMMENT")
  field:setBitField(5, "reserved")
  field:setBitField(6, "reserved")
  field:setBitField(7, "reserved")
  
  field = sect:addField(DataType.UInt32, "ModificationTime")
  field:dynamicInfo(GZipFormat.getModificationTimeMethod)
  field = sect:addField(DataType.UInt8, "ExtraFlags")
  field:dynamicInfo(GZipFormat.getExtraFlagsMethod)
  field = sect:addField(DataType.UInt8, "OperatingSystem")
  field:dynamicInfo(GZipFormat.getOperatingSystemMethod)
  
  if fextra:value() == 1 then
    field = sect:addField(DataType.UInt8, "XLEN")
    field = sect:addField(DataType.UInt8, "hdExtraField", field:value())
  end
  
  if fname:value() == 1 then
    sect:addField(DataType.AsciiString, "Filename")
  end
  
  if fcomment:value() == 1 then
    sect:addField(DataType.AsciiString, "Comment")
  end
  
  if fhcrc:value() == 1 then
    sect:addField(DataType.UInt16, "CRC-16")
  end

  return sect:size()
end

function GZipFormat:defineData(formatmodel, buffer)
  local sect = formatmodel:addStructure("GZIP_FILE")
  local size = buffer:size() - sect:offset() - 8;
  
  sect:addField(DataType.Blob, size, "compressed")
  
  return sect:size()
end

function GZipFormat:defineTrailer(formatmodel, buffer)
  local sect = formatmodel:addStructure("GZIP_TRAILER")
  
  sect:addField(DataType.UInt32, "CRC-32")
  sect:addField(DataType.UInt32, "InputSize")
  
  return sect:size()
end
