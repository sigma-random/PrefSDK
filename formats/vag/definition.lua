local oop = require("sdk.lua.oop")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")

-- function saveAsWav(formatmodel, buffer)  
--  local filename = PrefUI.getSaveFileName("Convert to Wave...")
  
--  if string.len(filename) > 0 then
--    local vagheader = formatmodel:findStructure("VAG_HEADER")
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
    
--    local vagdata = formatmodel:findStructure("VAG_DATA")
--    outbuffer:writeChars("data")
--    outbuffer:writeUInt32(vagdata:size() + 8)
--    outbuffer:writeObject(vagdata:findField("WaveformData"))
--    outbuffer:save(filename)
--  end
-- end

local VagFormat = oop.class(FormatDefinition)
-- VagFormat:registerOption("Save as WAV", saveAsWav)

function VagFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function VagFormat:validate()
  self:checkData(0, DataType.AsciiString, "VAGp")
end
    
function VagFormat:parse(formatmodel, buffer)
  local vagheader = formatmodel:addStructure("VagHeader")
  vagheader:addField(DataType.Character, "Id", 4)
  vagheader:addField(DataType.UInt32_BE, "Version")
  vagheader:addField(DataType.UInt32_BE, "Reserved1")
  vagheader:addField(DataType.UInt32_BE, "DataSize")
  vagheader:addField(DataType.UInt32_BE, "SamplingFrequency")
  vagheader:addField(DataType.Blob, "Reserved2", 12)
  vagheader:addField(DataType.Character, "Name", 16)
  
  local vagdata = formatmodel:addStructure("VagData")
  vagdata:addField(DataType.Blob, "WaveformData", vagheader.DataSize:value())
end

return VagFormat