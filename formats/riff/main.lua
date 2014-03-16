local FormatDefinition = require("sdk.format.formatdefinition")
local WaveCompressionType = require("formats.riff.wavcompressiontypes")

local RiffFormat = FormatDefinition:new("Resource Interchange Format", "Media", "Dax", "1.0", Endian.LittleEndian)

function RiffFormat.getWaveCompressionType(formatobject, buffer)
  local compressiontype = WaveCompressionType[formatobject:value()]
  
  if compressiontype ~= nil then
    return compressiontype
  end
  
  return "Unknown"
end

function RiffFormat:validateFormat(buffer)
  local sign = buffer:readString(0, 4)
  
  if sign == "RIFF" then
    return true
  end
  
  return false
end

function RiffFormat:parseFormat(formatmodel, buffer)
  local riffheader = formatmodel:addStructure("RiffHeader")
  riffheader:addField(DataType.Char, 4, "ChunkID")
  riffheader:addField(DataType.UInt32, "ChunkDataSize")
  riffheader:addField(DataType.Char, 4, "RiffType")
  
  local pos = riffheader:endOffset()
  
  while pos < buffer:size() do
    local chunksize = RiffFormat:verifyChunkType(buffer:readString(pos, 4), formatmodel, buffer)
    
    if chunksize == 0 then
      break
    end
    
    pos = pos + chunksize
  end
end

function RiffFormat:verifyChunkType(chunktype, formatmodel, buffer)
  if chunktype == "fmt " then
    return RiffFormat:defineFmtChunk(formatmodel, buffer)
  elseif chunktype == "data" then
    return RiffFormat:defineDataChunk(formatmodel, buffer)
  elseif chunktype == "fact" then
    return RiffFormat:defineFactChunk(formatmodel, buffer)
  end
  
  return 0
end

function RiffFormat:defineFmtChunk(formatmodel, buffer)
  local formatchunk = formatmodel:addStructure("FormatChunk")
  formatchunk:addField(DataType.Char, 4, "ChunkID")
  formatchunk:addField(DataType.UInt32, "ChunkDataSize")
  formatchunk:addField(DataType.UInt16, "CompressionCode"):dynamicInfo(RiffFormat.getWaveCompressionType)
  formatchunk:addField(DataType.UInt16, "NumberOfChannels")
  formatchunk:addField(DataType.UInt32, "SampleRate")
  formatchunk:addField(DataType.UInt32, "AvgBytesPerSecond")
  formatchunk:addField(DataType.UInt16, "BlockAlign")
  formatchunk:addField(DataType.UInt16, "BitsPerSample")
  
  local chunkdatasize = formatchunk.ChunkDataSize:value()

  if chunkdatasize > 0 then
    formatchunk:addField(DataType.Blob, chunkdatasize - 16, "ExtraFormatData")
  end

  return formatchunk:size()
end

function RiffFormat:defineDataChunk(formatmodel, buffer)
  local datachunk = formatmodel:addStructure("DataChunk")
  datachunk:addField(DataType.Char, 4, "ChunkID")
  datachunk:addField(DataType.UInt32, "ChunkDataSize")  
  datachunk:addField(DataType.Blob, datachunk.ChunkDataSize:value(), "SampleData")
  
  return datachunk:size()
end

function RiffFormat:defineFactChunk(formatmodel, buffer)
  local factchunk = formatmodel:addStructure("FactChunk")
  factchunk:addField(DataType.Char, 4, "ChunkID")
  factchunk:addField(DataType.UInt32, "ChunkDataSize")
  factchunk:addField(DataType.Blob, factchunk.ChunkDataSize:value(), "FormatData")
  
  return factchunk:size()
end