local pref = require("pref")

-- function saveAsWav(formattree, buffer)  
--  local filename = PrefUI.getSaveFileName("Convert to Wave...")
  
--  if string.len(filename) > 0 then
--    local vagheader = formattree:findStructure("VAG_HEADER")
--    local outbuffer = Buffer:new(Endian.LittleEndian)
  
--    outbuffer:writeChars("RIFF")
--    outbuffer:writeUInt32(0x00000000)
--    outbuffer:writeChars("WAVE")
    
--    outbuffer:writeChars("fmt ")
--    outbuffer:writeUInt32(16)
--    outbuffer:writeUInt16(1)
--    outbuffer:writeUInt16(1)
    
--    local samplefreq = buffer:readObject(vagheader:findField("SamplingFrequency"))
--    outbuffer:writeUInt32(samplefreq)
--    outbuffer:writeUInt32(samplefreq * 2 * (16 / 8))
--    outbuffer:writeUInt16(2 * (16 / 8))
--    outbuffer:writeUInt16(16)
    
--    local vagdata = formattree:findStructure("VAG_DATA")
--    outbuffer:writeChars("data")
--    outbuffer:writeUInt32(vagdata:size() + 8)
--    outbuffer:writeObject(vagdata:findField("WaveformData"))
--    outbuffer:save(filename)
--  end
-- end

local VagFormat = pref.format.create("VAG Format", "Sony Playstation 1", "Dax", "1.0")
-- VagFormat:registerOption("Save as WAV", saveAsWav)

function VagFormat:validate(validator)
  validator:checkAscii(0, "VAGp")
end
    
function VagFormat:parse(formattree)
  local vagheader = formattree:addStructure("VagHeader")
  vagheader:addField(pref.datatype.Character, "Id", 4)
  vagheader:addField(pref.datatype.UInt32_BE, "Version")
  vagheader:addField(pref.datatype.UInt32_BE, "Reserved1")
  vagheader:addField(pref.datatype.UInt32_BE, "DataSize")
  vagheader:addField(pref.datatype.UInt32_BE, "SamplingFrequency")
  vagheader:addField(pref.datatype.Blob, "Reserved2", 12)
  vagheader:addField(pref.datatype.Character, "Name", 16)
  
  local vagdata = formattree:addStructure("VagData")
  vagdata:addField(pref.datatype.Blob, "WaveformData", vagheader.DataSize.value)
end

return VagFormat