local pref = require("pref")
local RiffFunctions = require("formats.riff.functions")

local RiffFormat = pref.format.create("Resource Interchange Format", "Media", "Dax", "1.0")

function RiffFormat:validate(validator)
  validator:checkAscii(0, "RIFF")
end

function RiffFormat:parse(formattree)
  local buffer = formattree.buffer
  local riffheader = formattree:addStructure("RiffHeader")
  riffheader:addField(pref.datatype.Character, "ChunkID", 4)
  riffheader:addField(pref.datatype.UInt32_LE, "ChunkDataSize")
  riffheader:addField(pref.datatype.Character, "RiffType", 4)
  
  local pos = riffheader.endoffset
  
  while pos < buffer.length do
    local chunksize = RiffFunctions.verifyChunkType(buffer:readString(pos, 4), formattree)
    
    if chunksize == 0 then
      self:warning(string.format("Unknown Chunk Detected at %08Xh", pos))
      break
    end
    
    pos = pos + chunksize
  end
end

return RiffFormat