local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")
local OperatingSystems = require("formats.gzip.gziptypes")

local GZipFormat = FormatDefinition.register("GZip Format", "Compression", "Karl", "1.1")

function GZipFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function GZipFormat:getCompressionMethod(comprmethodfield)
  if comprmethodfield:value() == 0x08 then
    return "Deflate"
  end
  
  return "Unknown"
end

function GZipFormat:getExtraFlags(extraflagsfield)
  local value = extraflagsfield:value()
  
  if value == 0x02 then
    return "Compressor used maximum compression, slowest algorithm"
  elseif value == 0x04 then
    return "Compressor used fastest algorithm"
  end
  
  return "Unknown"
end

function GZipFormat:getModificationTime(modtimefield)  
  if modtimefield:value() ~= 0x00 then
    return os.date("%Y-%m-%d %H:%M", 10800 + value)
  end
  
  return "Invalid"
end

function GZipFormat:getOperatingSystem(osfield)
  return OperatingSystems[osfield:value()]
end

function GZipFormat:validateFormat()
  self:checkData(0, DataType.UInt16_LE, 0x8B1F)
  self:checkData(2, DataType.UInt8, 0x08)
end
    
function GZipFormat:parseFormat(formattree)  
  self:defineHeader(formattree)
  self:defineData(formattree)
  self:defineTrailer(formattree)
end 

function GZipFormat:defineHeader(formattree) -- 0x8B1F
  local gzipheader = formattree:addStructure("GZipHeader")
  gzipheader:addField(DataType.UInt16_LE, "Id")
  gzipheader:addField(DataType.UInt8, "CompressionMethod"):dynamicInfo(GZipFormat.getCompressionMethod)
  
  local flags = gzipheader:addField(DataType.UInt8, "Flags")
  flags:setBitField("FTEXT", 0)
  flags:setBitField("FHCRC", 1)
  flags:setBitField("FEXTRA", 2)
  flags:setBitField("FNAME", 3)
  flags:setBitField("FCOMMENT", 4)
  flags:setBitField("Reserved", 5)
  flags:setBitField("Reserved", 6)
  flags:setBitField("Reserved", 7)
  
  gzipheader:addField(DataType.UInt32_LE, "ModificationTime"):dynamicInfo(GZipFormat.getModificationTime)
  gzipheader:addField(DataType.UInt8, "ExtraFlags"):dynamicInfo(GZipFormat.getExtraFlags)
  gzipheader:addField(DataType.UInt8, "OperatingSystem"):dynamicInfo(GZipFormat.getOperatingSystem)
  
  if flags.FEXTRA:value() == 1 then
    gzipheader:addField(DataType.UInt8, "XLEN")
    gzipheader:addField(DataType.UInt8, "hdExtraField", gzipheader.XLEN:value())
  end
  
  if flags.FNAME:value() == 1 then
    gzipheader:addField(DataType.AsciiString, "Filename")
  end
  
  if flags.FCOMMENT:value() == 1 then
    gzipheader:addField(DataType.AsciiString, "Comment")
  end
  
  if flags.FHCRC:value() == 1 then
    gzipheader:addField(DataType.UInt16_LE, "CRC-16")
  end

  return gzipheader:size()
end

function GZipFormat:defineData(formattree)
  local gzipdata = formattree:addStructure("GZipData")
  local size = self.databuffer:length() - gzipdata:offset() - 8;
  
  gzipdata:addField(DataType.Blob, size, "Compression")
  return gzipdata:size()
end

function GZipFormat:defineTrailer(formattree)
  local gziptrailer = formattree:addStructure("GZipTrailer")
  gziptrailer:addField(DataType.UInt32_LE, "CRC-32")
  gziptrailer:addField(DataType.UInt32_LE, "InputSize")
  
  return gziptrailer:size()
end
