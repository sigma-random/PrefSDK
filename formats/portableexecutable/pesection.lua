local PeDefs = require("formats.portableexecutable.pedefs")
local PeDirectories = require("formats.portableexecutable.pedirectories")

local PeSections = { }

function PeSections.imageFirstSection(ntheaders)
  local sizeofoptheader = ntheaders.FileHeader.SizeOfOptionalHeader:value()
  return ntheaders:offset() + sizeofoptheader + 0x18
end

function PeSections.rvaInSection(rva, sectionheader)
  local sectrva = sectionheader.VirtualAddress:value()
  local sectsize = sectionheader.VirtualSize:value()
  
  if (rva >= sectrva) and (rva <= (sectrva + sectsize)) then
    return true
  end
  
  return false
end

function PeSections.inSection(rva, sectionheader)
  local sectrva = sectionheader.VirtualAddress:value()
  local sectsize = sectionheader.VirtualSize:value()
  return ((rva >= sectrva) and (rva < (sectrva + sectsize)))
end

function PeSections.sectionFromRva(rva, ntheaders)
  local numberofsections = ntheaders.FileHeader.NumberOfSections:value()
  
  if numberofsections > 0 then
    local sectiontable = ntheaders:model().SectionTable
    
    for i = 1, numberofsections do
      local section = sectiontable["Section" .. i]
      
      if PeSections.inSection(rva, section) then
	return section
      end
    end
  end
  
  return nil
end

function PeSections.sectionName(rva, ntheaders, buffer)
  local section = PeSections.sectionFromRva(rva, ntheaders)
  
  if section ~= nil then
    return buffer:readString(section.Name:offset())
  end
  
  return ""
end

function PeSections.sectionDisplayName(rva, ntheaders, buffer)
  local name = PeSections.sectionName(rva, ntheaders, buffer)
  return name:gsub("%p", ""):gsub("%a", string.upper, 1)
end

function PeSections.analyzeSection(sectionheader, section, ntheaders, buffer)
  local datadirectory = ntheaders.OptionalHeader.DataDirectory
  
  for i = 1, PeDefs.NumberOfDirectoryEntries do
    local directory = datadirectory[PeDefs.DirectoryNames[i]]
    local rva = directory.VirtualAddress:value()
    
    if (rva ~= 0) and PeSections.inSection(rva, sectionheader) then
      PeDirectories.createDirectory(sectionheader, section, rva, i, buffer)
    end
  end
end

return PeSections