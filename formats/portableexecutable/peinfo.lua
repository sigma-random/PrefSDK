local PeDefs = require("formats.portableexecutable.pedefs")
local PeSection = require("formats.portableexecutable.pesection")

local PeInfo = { }

function PeInfo.getDirectoryEntrySection(directoryentry, buffer)
  if directoryentry.VirtualAddress:value() > 0 then
    return PeSection.sectionName(directoryentry.VirtualAddress:value(), directoryentry:model().NtHeaders, buffer)
  end
  
  return ""
end

function PeInfo.getOptionalHeaderFieldSection(field, buffer)
  return PeSection.sectionName(field:value(), field:model().NtHeaders, buffer)
end

function PeInfo.getMachine(machine, buffer)
  return PeDefs.ImageFileMachine[machine:value()]
end

function PeInfo.getOptionalHeaderMagic(magic, buffer)
  return PeDefs.ImageOptionalHeaderMagic[magic:value()]
end

function PeInfo.getSectionName(sectionheader, buffer)
  return buffer:readString(sectionheader.Name:offset())
end

return PeInfo