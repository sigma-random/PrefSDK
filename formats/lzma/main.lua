local MathFunctions = require("sdk.math.functions")
local FormatDefinition = require("sdk.format.formatdefinition")
local ByteOrder = require("sdk.types.byteorder")
local DataType = require("sdk.types.datatype")
local LZma = require("sdk.compression.lzma")

local LZmaFormat = FormatDefinition.register("LZMA Format", "Compression", "Dax", "1.0")

function LZmaFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function LZmaFormat:analyzeProperties(propfield)
  local lc, lp, pb = LZma.getProperties(propfield:value())
  return string.format("lc: %d, lp %d, pb: %d", lc, lp, pb)
end

function LZmaFormat:getDictionarySize(dictsizefield)
  local val = MathFunctions.logb(dictsizefield:value(), 2)
  return string.format("2^%d bytes", val)
end

function LZmaFormat:checkUncompressedSize(uncomprsizefield)  
  if uncomprsizefield:value() == -1 then
    return "Unknown Size"
  end
  
  return ""
end

function LZmaFormat:validateFormat()  
  self:checkData(0, DataType.UInt8, 0x5D)
  
  local databuffer = self.databuffer
  local props = databuffer:readUInt8(0)
  local dictsize = databuffer:readUInt32(1, ByteOrder.LittleEndian)
  local dictcount = MathFunctions.logb(dictsize, 2)
  local uncompressedsize = self.databuffer:readInt64(5, ByteOrder.LittleEndian)
  local lc, lp, pb = LZma.getProperties(props)
  
  -- LZma format Extended Checks
  if (props >= (9 * 5 * 5)) or ((lc + lp) > 4) then 
    error("Invalid ZLMA Properties")
  elseif (dictcount < 16) or (dictcount > 25) then
    error("Invalid Dictonary Size")
  elseif (uncompressedsize == 0) or (uncompressedsize >= 0x100000000) or (uncompressedsize < -1) then  -- Skip more than 4GB files 
    error("Compressed file's size cannot be greater than 4GB")
  end
end
    
function LZmaFormat:parseFormat(formattree)
  local lzmaheader = formattree:addStructure("LZmaHeader")
  lzmaheader:addField(DataType.UInt8, "Properties"):dynamicInfo(LZmaFormat.analyzeProperties)
  lzmaheader:addField(DataType.UInt32_LE, "DictionarySize"):dynamicInfo(LZmaFormat.getDictionarySize)
  lzmaheader:addField(DataType.Int64_LE, "UncompressedSize"):dynamicInfo(LZmaFormat.checkUncompressedSize)
end 
