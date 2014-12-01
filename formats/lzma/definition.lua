local pref = require("pref")
local MathFunctions = require("sdk.math.functions")
local LZma = require("sdk.compression.lzma")

local DataType = pref.datatype
local LZmaFormat = pref.format.create("LZma Stream", "Compression", "Dax", "1.0")

function LZmaFormat:validate(validator)  
  validator:checkType(0, 0x5D, DataType.UInt8)
  
  local buffer = validator.buffer
  local props = buffer:readType(0, DataType.UInt8)
  local dictsize = buffer:readType(1, DataType.UInt32_LE)
  local uncompressedsize = buffer:readType(5,DataType.Int64_LE)
  local dictcount = MathFunctions.logb(dictsize, 2)
  local lc, lp, pb = LZma.getProperties(props)
  
  -- LZma format Extended Checks
  if (props >= (9 * 5 * 5)) or ((lc + lp) > 4) then 
    validator:error("Invalid ZLMA Properties")
  elseif (dictcount < 16) or (dictcount > 25) then
    validator:error("Invalid Dictonary Size")
  elseif (uncompressedsize == 0) or (uncompressedsize >= 0x100000000) or (uncompressedsize < -1) then  -- Skip more than 4GB files 
    validator:error("Compressed file's size cannot be greater than 4GB")
  end
end
    
function LZmaFormat:parse(formattree)
  local lzmaheader = formattree:addStructure("LZmaHeader")
  lzmaheader:addField(DataType.UInt8, "Properties"):dynamicInfo(LZmaFormat.analyzeProperties)
  lzmaheader:addField(DataType.UInt32_LE, "DictionarySize"):dynamicInfo(LZmaFormat.getDictionarySize)
  lzmaheader:addField(DataType.Int64_LE, "UncompressedSize"):dynamicInfo(LZmaFormat.checkUncompressedSize)
end 

function LZmaFormat.analyzeProperties(propfield, formattree)
  local lc, lp, pb = LZma.getProperties(propfield.value)
  return string.format("lc: %d, lp %d, pb: %d", lc, lp, pb)
end

function LZmaFormat.getDictionarySize(dictsizefield, formattree)
  local val = MathFunctions.logb(dictsizefield.value, 2)
  return string.format("2^%d bytes", val)
end

function LZmaFormat.checkUncompressedSize(uncomprsizefield, formattree)
  if uncomprsizefield.value == -1 then
    return "Unknown Size"
  end
  
  return ""
end

return LZmaFormat