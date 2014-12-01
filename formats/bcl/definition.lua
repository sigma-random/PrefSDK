-- Library's Website: http://bcl.comli.eu/

local pref = require("pref")
local CompressionAlgorithm = require("formats.bcl.compressionalgorithm")

local DataType = pref.datatype
local BclFormat = pref.format.create("Basic Compression Library", "Compression", "Dax", "1.0")

function BclFormat:validate(validator)
  validator:checkAscii(0, "BCL1")
end

function BclFormat:parse(formattree)  
  local bclheader = formattree:addStructure("BclHeader")
  bclheader:addField(DataType.Character, "Signature", 4)
  bclheader:addField(DataType.UInt32_BE, "Algorithm"):dynamicInfo(BclFormat.displayCompressionAlgorithm)
  bclheader:addField(DataType.UInt32_BE, "FileSize")
  bclheader:addField(DataType.UInt32_BE, "CompressedSize")
  
  local bcldata = formattree:addStructure("BclData")
  bcldata:addField(DataType.Blob, "CompressedData", bclheader.CompressedSize.value)
end

function BclFormat.displayCompressionAlgorithm(algorithm)
  return CompressionAlgorithm[algorithm.value] or "Invalid"
end

return BclFormat 
