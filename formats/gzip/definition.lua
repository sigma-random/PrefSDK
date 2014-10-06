local pref = require("pref")
local GZipFunctions = require("formats.gzip.functions")

local GZipFormat = pref.format.create("GZip Format", "Compression", "Karl", "1.1")

function GZipFormat:validate(validator)
  validator:checkType(0, 0x8B1F, pref.datatype.UInt16_LE)
  validator:checkType(2, 0x08, pref.datatype.UInt8)
end
    
function GZipFormat:parse(formattree)  
  GZipFunctions.defineHeader(formattree)
  GZipFunctions.defineData(formattree)
  GZipFunctions.defineTrailer(formattree)
end

return GZipFormat