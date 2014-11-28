-- http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/RIFF.html
-- http://www.aelius.com/njh/wavemetatools/doc/riffmci.pdf
-- http://www.sonicspot.com/guide/wavefiles.html

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
  riffheader:addField(DataType.Character, "ckID", 4)
  riffheader:addField(DataType.UInt32_LE, "ckSize")
  riffheader:addField(DataType.Character, "ckType", 4)
  
  local i, pos = 0, riffheader.endoffset
  
  while pos < buffer.length do
    local chunk = self:defineChunk(formattree, string.format("Chunk%d", i))
    pos = pos + chunk.size
    i = i + 1
  end
end

function RiffFormat:defineChunk(formattree, name)
  local chunk = formattree:addStructure(name):dynamicInfo(RiffFormat.getChunkType)
  chunk:addField(DataType.Character, "ckID", 4)
  chunk:addField(DataType.UInt32_LE, "ckSize")
  
  local chunkid = chunk.ckID.value
  
  if chunkid == "fmt " then
    self:defineFmtChunk(chunk)
  elseif chunk.ckSize.value > 0 then  
    chunk:addField(DataType.Blob, "ckData", chunk.ckSize.value)
  end
  
  return chunk
end

function RiffFormat:defineFmtChunk(chunk)
  chunk:addField(DataType.UInt16_LE, "wFormatTag"):dynamicInfo(RiffFormat.getFormatTag)
  chunk:addField(DataType.UInt16_LE, "wChannels")
  chunk:addField(DataType.UInt32_LE, "dwSamplesPerSec")
  chunk:addField(DataType.UInt32_LE, "dwAvgBytesPerSec")
  chunk:addField(DataType.UInt16_LE, "wBlockAlign")
  
  local formattag = chunk.wFormatTag.value
  
  if formattag == 0x0001 then -- PCM
    chunk:addField(DataType.UInt16_LE, "wBitsPerSample")
  else
    local extradata = chunk.ckSize.value - (chunk.size - 8)
  
    if extradata > 0 then
      chunk:addField(DataType.Blob, "bExtraData", extradata)
    end
  end
end

function RiffFormat.getChunkType(chunk)
  return string.format("%q", chunk.ckID.value)
end

function RiffFormat.getFormatTag(compressiontypefield, formattree)
  return WaveCompressionType[compressiontypefield.value] or "Unknown"
end

return RiffFormat