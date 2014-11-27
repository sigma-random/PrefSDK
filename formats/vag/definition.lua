local pref = require("pref")

local DataType = pref.datatype
local VagFormat = pref.format.create("VAG Format", "Sony Playstation 1", "Dax", "1.0")

function VagFormat:validate(validator)
  validator:checkAscii(0, "VAGp")
end
    
function VagFormat:parse(formattree)
  local vagheader = formattree:addStructure("VagHeader")
  vagheader:addField(DataType.Character, "Id", 4)
  vagheader:addField(DataType.UInt32_BE, "Version")
  vagheader:addField(DataType.UInt32_BE, "Reserved1")
  vagheader:addField(DataType.UInt32_BE, "DataSize")
  vagheader:addField(DataType.UInt32_BE, "SamplingFrequency")
  vagheader:addField(DataType.Blob, "Reserved2", 12)
  vagheader:addField(DataType.Character, "Name", 16)
  
  local vagdata = formattree:addStructure("VagData")
  vagdata:addField(DataType.Blob, "WaveformData", vagheader.DataSize.value)
end

return VagFormat