local WaveCompressionType = require("formats.riff.wavcompressiontypes")

local RiffFunctions = { }

function RiffFunctions.getWaveCompressionType(compressiontypefield, formattree)
  local compressiontype = WaveCompressionType[compressiontypefield.value]
  
  if compressiontype ~= nil then
    return compressiontype
  end
  
  return "Unknown"
end

function RiffFunctions.verifyChunkType(chunktype, formattree)
  if chunktype == "fmt " then
    return RiffFunctions.defineFmtChunk(formattree)
  elseif chunktype == "data" then
    return RiffFunctions.defineDataChunk(formattree)
  elseif chunktype == "fact" then
    return RiffFunctions.defineFactChunk(formattree)
  end
  
  return 0
end

function RiffFunctions.defineFmtChunk(formattree)
  local formatchunk = formattree:addStructure("FormatChunk")
  formatchunk:addField(pref.datatype.Character, "ChunkID", 4)
  formatchunk:addField(pref.datatype.UInt32_LE, "ChunkDataSize")
  formatchunk:addField(pref.datatype.UInt16_LE, "CompressionCode"):dynamicInfo(RiffFunctions.getWaveCompressionType)
  formatchunk:addField(pref.datatype.UInt16_LE, "NumberOfChannels")
  formatchunk:addField(pref.datatype.UInt32_LE, "SampleRate")
  formatchunk:addField(pref.datatype.UInt32_LE, "AvgBytesPerSecond")
  formatchunk:addField(pref.datatype.UInt16_LE, "BlockAlign")
  formatchunk:addField(pref.datatype.UInt16_LE, "BitsPerSample")
  
  local chunkdatasize = formatchunk.ChunkDataSize.value

  if chunkdatasize > 0 then
    formatchunk:addField(pref.datatype.Blob, "ExtraFormatData", chunkdatasize - 16)
  end

  return formatchunk.size
end

function RiffFunctions.defineDataChunk(formattree)
  local datachunk = formattree:addStructure("DataChunk")
  datachunk:addField(pref.datatype.Character, "ChunkID", 4)
  datachunk:addField(pref.datatype.UInt32_LE, "ChunkDataSize")  
  datachunk:addField(pref.datatype.Blob, datachunk.ChunkDataSize.value, "SampleData")
  
  return datachunk.size
end

function RiffFunctions.defineFactChunk(formattree)
  local factchunk = formattree:addStructure("FactChunk")
  factchunk:addField(pref.datatype.Character, "ChunkID", 4)
  factchunk:addField(pref.datatype.UInt32_LE, "ChunkDataSize")
  factchunk:addField(pref.datatype.Blob, factchunk.ChunkDataSize.value, "FormatData")
  
  return factchunk.size
end

return RiffFunctions
