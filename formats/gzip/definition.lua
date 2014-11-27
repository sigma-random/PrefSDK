local pref = require("pref")
local GZipOS = require("formats.gzip.gzipos")

local DataType = pref.datatype
local GZipFormat = pref.format.create("GZip Format", "Compression", "Karl", "1.1")

function GZipFormat:validate(validator)
  validator:checkType(0, 0x8B1F, DataType.UInt16_LE)
  validator:checkType(2, 0x08, DataType.UInt8)
end
    
function GZipFormat:parse(formattree)  
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
  
  if flags.FEXTRA.value == 1 then
    gzipheader:addField(DataType.UInt8, "XLEN")
    gzipheader:addField(DataType.UInt8, "hdExtraField", gzipheader.XLEN.value)
  end
  
  if flags.FNAME.value == 1 then
    gzipheader:addField(DataType.AsciiString, "Filename")
  end
  
  if flags.FCOMMENT.value == 1 then
    gzipheader:addField(DataType.AsciiString, "Comment")
  end
  
  if flags.FHCRC.value == 1 then
    gzipheader:addField(DataType.UInt16_LE, "CRC-16")
  end
end

function GZipFormat:defineData(formattree)
  local gzipdata = formattree:addStructure("GZipData")
  gzipdata:addField(DataType.Blob, "Data", formattree.buffer.length - formattree.GZipHeader.size - 8)
end

function GZipFormat:defineTrailer(formattree)
  local gziptrailer = formattree:addStructure("GZipTrailer")
  gziptrailer:addField(DataType.UInt32_LE, "CRC-32")
  gziptrailer:addField(DataType.UInt32_LE, "InputSize")
end 

function GZipFormat.getCompressionMethod(comprmethodfield, formattree)
  local value = comprmethodfield.value
  
  if value == 0x08 then
    return "Deflate"
  elseif value ~= 0x00 then
    return "Unknown"
  end
  
  return ""
end

function GZipFormat.getExtraFlags(extraflagsfield, formattree)
  local value = extraflagsfield.value
  
  if value == 0x02 then
    return "Compressor used maximum compression, slowest algorithm"
  elseif value == 0x04 then
    return "Compressor used fastest algorithm"
  elseif value ~= 0 then
    return "Unknown"
  end
  
  return ""
end

function GZipFormat.getModificationTime(modtimefield, formattree)
  local value = modtimefield.value
  
  if value ~= 0x00 then
    return os.date("%Y-%m-%d %H:%M", 10800 + value)
  end
  
  return "Invalid"
end

function GZipFormat.getOperatingSystem(osfield, formattree)
  return GZipOS[osfield.value]
end

return GZipFormat