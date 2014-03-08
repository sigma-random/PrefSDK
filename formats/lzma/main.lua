require("sdk.math.functions")
local FormatDefinition = require("sdk.format.formatdefinition")
local LZma = require("sdk.compression.lzma")

local LZmaFormat = FormatDefinition:new("LZMA Format", "Compression", "Dax", "1.0", Endian.LittleEndian)

function LZmaFormat.analyzeProperties(formatmodel, buffer)
  local lc, lp, pb = LZma.getProperties(formatmodel:value())
  return string.format("lc: %d, lp %d, pb: %d", lc, lp, pb)
end

function LZmaFormat.getDictionarySize(formatmodel, buffer)
  local val = logb(formatmodel:value(), 2)
  return string.format("2^%d bytes", val)
end

function LZmaFormat.checkUncompressedSize(formatmodel, buffer)
  local val = formatmodel:value()
  
  if val == -1 then
    return "Unknown Size"
  end
  
  return ""
end

function LZmaFormat:validateFormat(buffer)
  local props = buffer:readType(0, DataType.UInt8)
  local dictsize = buffer:readType(1, DataType.UInt32)
  local dictcount = logb(dictsize, 2)
  local uncompressedsize = buffer:readType(5, DataType.UInt64) -- Skip more than 4GB files 
  local lc, lp, pb = LZma.getProperties(props)
  
  if (props ~= 0x5D) or (props >= (9 * 5 * 5)) or ((dictcount % 2) ~= 0) or (dictcount < 16) or (dictcount > 25) or (lc + lp) > 4 or (uncompressedsize == 0) or (uncompressedsize >= 0x100000000) or (uncompressedsize < -1) then
    return false
  end
    
  return true
end
    
function LZmaFormat:parseFormat(formatmodel, buffer)
  local lzmaheader = formatmodel:addStructure("LzmaHeader")
  lzmaheader:addField(DataType.UInt8, "Properties"):dynamicInfo(LZmaFormat.analyzeProperties);
  lzmaheader:addField(DataType.UInt32, "DictionarySize"):dynamicInfo(LZmaFormat.getDictionarySize)
  lzmaheader:addField(DataType.UInt64, "UncompressedSize"):dynamicInfo(LZmaFormat.checkUncompressedSize)
end 
