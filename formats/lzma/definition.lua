local pref = require("pref")
local MathFunctions = require("sdk.math.functions")
local LZma = require("sdk.compression.lzma")
local LZmaFunctions = require("formats.lzma.functions")

local LZmaFormat = pref.format.create("LZMA Format", "Compression", "Dax", "1.0")

function LZmaFormat:validate(validator)  
  validator:checkType(0, 0x5D, pref.datatype.UInt8)
  
  local buffer = validator.buffer
  local props = buffer:readType(0, pref.datatype.UInt8)
  local dictsize = buffer:readType(1, pref.datatype.UInt32_LE)
  local uncompressedsize = buffer:readType(5,pref.datatype.Int64_LE)
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
  lzmaheader:addField(pref.datatype.UInt8, "Properties"):dynamicInfo(LZmaFunctions.analyzeProperties)
  lzmaheader:addField(pref.datatype.UInt32_LE, "DictionarySize"):dynamicInfo(LZmaFunctions.getDictionarySize)
  lzmaheader:addField(pref.datatype.Int64_LE, "UncompressedSize"):dynamicInfo(LZmaFunctions.checkUncompressedSize)
end 

return LZmaFormat