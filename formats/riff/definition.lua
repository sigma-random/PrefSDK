local pref = require("pref")
local WaveCompressionType = require("formats.riff.wavcompressiontypes")

local DataType = pref.datatype
local RiffFormat = pref.format.create("Resource Interchange Format", "Media", "Dax", "1.0")

function RiffFormat:validate(validator)
  validator:checkAscii(0, "RIFF")
end

function RiffFormat:parse(formattree)
  local buffer = formattree.buffer
  local riffheader = formattree:addStructure("RiffHeader")
  riffheader:addField(DataType.Character, "ChunkID", 4)
  riffheader:addField(DataType.UInt32_LE, "ChunkDataSize")
  riffheader:addField(DataType.Character, "RiffType", 4)
  
  local pos = riffheader.endoffset
  
  while pos < buffer.length do
    local chunksize = self:verifyChunkType(buffer:readString(pos, 4), formattree)
    
    if chunksize == 0 then
      pref.warning("Unknown Chunk Detected at %08Xh", pos)
      break
    end
    
    pos = pos + chunksize
  end
end

function RiffFormat:verifyChunkType(chunktype, formattree)
  if chunktype == "fmt " then
    return self:defineFmtChunk(formattree)
  elseif chunktype == "data" then
    return self:defineDataChunk(formattree)
  elseif chunktype == "fact" then
    return self:defineFactChunk(formattree)
  end
  
  return 0
end

function RiffFormat:defineFmtChunk(formattree)
  local formatchunk = formattree:addStructure("FormatChunk")
  formatchunk:addField(DataType.Character, "ChunkID", 4)
  formatchunk:addField(DataType.UInt32_LE, "ChunkDataSize")
  formatchunk:addField(DataType.UInt16_LE, "CompressionCode"):dynamicInfo(RiffFormat.getWaveCompressionType)
  formatchunk:addField(DataType.UInt16_LE, "NumberOfChannels")
  formatchunk:addField(DataType.UInt32_LE, "SampleRate")
  formatchunk:addField(DataType.UInt32_LE, "AvgBytesPerSecond")
  formatchunk:addField(DataType.UInt16_LE, "BlockAlign")
  formatchunk:addField(DataType.UInt16_LE, "BitsPerSample")
  
  local chunkdatasize = formatchunk.ChunkDataSize.value

  if chunkdatasize > 0 then
    formatchunk:addField(DataType.Blob, "ExtraFormatData", chunkdatasize - 16)
  end

  return formatchunk.size
end

function RiffFormat:defineDataChunk(formattree)
  local datachunk = formattree:addStructure("DataChunk")
  datachunk:addField(DataType.Character, "ChunkID", 4)
  datachunk:addField(DataType.UInt32_LE, "ChunkDataSize")  
  datachunk:addField(DataType.Blob, datachunk.ChunkDataSize.value, "SampleData")
  
  return datachunk.size
end

function RiffFormat:defineFactChunk(formattree)
  local factchunk = formattree:addStructure("FactChunk")
  factchunk:addField(DataType.Character, "ChunkID", 4)
  factchunk:addField(DataType.UInt32_LE, "ChunkDataSize")
  factchunk:addField(DataType.Blob, factchunk.ChunkDataSize.value, "FormatData")
  
  return factchunk.size
end

function RiffFormat:getWaveCompressionType(compressiontypefield, formattree)
  local compressiontype = WaveCompressionType[compressiontypefield.value]
  
  if compressiontype ~= nil then
    return compressiontype
  end
  
  return "Unknown"
end

return RiffFormat