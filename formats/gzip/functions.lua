local pref = require("pref")
local OperatingSystems = require("formats.gzip.gziptypes")

local GZipFunctions = { }

function GZipFunctions.defineHeader(formattree) -- 0x8B1F
  local gzipheader = formattree:addStructure("GZipHeader")
  gzipheader:addField(pref.datatype.UInt16_LE, "Id")
  gzipheader:addField(pref.datatype.UInt8, "CompressionMethod"):dynamicInfo(GZipFunctions.getCompressionMethod)
  
  local flags = gzipheader:addField(pref.datatype.UInt8, "Flags")
  flags:setBitField("FTEXT", 0)
  flags:setBitField("FHCRC", 1)
  flags:setBitField("FEXTRA", 2)
  flags:setBitField("FNAME", 3)
  flags:setBitField("FCOMMENT", 4)
  flags:setBitField("Reserved", 5)
  flags:setBitField("Reserved", 6)
  flags:setBitField("Reserved", 7)
  
  gzipheader:addField(pref.datatype.UInt32_LE, "ModificationTime"):dynamicInfo(GZipFunctions.getModificationTime)
  gzipheader:addField(pref.datatype.UInt8, "ExtraFlags"):dynamicInfo(GZipFunctions.getExtraFlags)
  gzipheader:addField(pref.datatype.UInt8, "OperatingSystem"):dynamicInfo(GZipFunctions.getOperatingSystem)
  
  if flags.FEXTRA.value == 1 then
    gzipheader:addField(pref.datatype.UInt8, "XLEN")
    gzipheader:addField(pref.datatype.UInt8, "hdExtraField", gzipheader.XLEN.value)
  end
  
  if flags.FNAME.value == 1 then
    gzipheader:addField(pref.datatype.AsciiString, "Filename")
  end
  
  if flags.FCOMMENT.value == 1 then
    gzipheader:addField(pref.datatype.AsciiString, "Comment")
  end
  
  if flags.FHCRC.value == 1 then
    gzipheader:addField(pref.datatype.UInt16_LE, "CRC-16")
  end
end

function GZipFunctions.defineData(formattree)
  -- FIXME: local gzipdata = formattree:addStructure("GZipData")
  -- FIXME: local size = self.databuffer:length() - gzipdata:offset() - 8;
  
  -- FIXME: gzipdata:addField(pref.datatype.Blob, "Data", size)
end

function GZipFunctions.defineTrailer(formattree)
  local gziptrailer = formattree:addStructure("GZipTrailer")
  gziptrailer:addField(pref.datatype.UInt32_LE, "CRC-32")
  gziptrailer:addField(pref.datatype.UInt32_LE, "InputSize")
end 

function GZipFunctions.getCompressionMethod(comprmethodfield, formattree)
  local value = comprmethodfield.value
  
  if value == 0x08 then
    return "Deflate"
  elseif value ~= 0x00 then
    return "Unknown"
  end
  
  return ""
end

function GZipFunctions.getExtraFlags(extraflagsfield, formattree)
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

function GZipFunctions.getModificationTime(modtimefield, formattree)
  local value = modtimefield.value
  
  if value ~= 0x00 then
    return os.date("%Y-%m-%d %H:%M", 10800 + value)
  end
  
  return "Invalid"
end

function GZipFunctions.getOperatingSystem(osfield, formattree)
  return OperatingSystems[osfield.value]
end

return GZipFunctions