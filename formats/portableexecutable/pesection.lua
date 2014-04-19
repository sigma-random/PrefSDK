local oop = require("sdk.lua.oop")
local PeDefs = require("formats.portableexecutable.pedefs")
local PeDirectories = require("formats.portableexecutable.pedirectories")

local PeSectionTable = oop.class()

function PeSectionTable:__ctor(formattree, databuffer)
  self.formattree = formattree
  self.databuffer = databuffer
end

function PeSectionTable:imageFirstSection(ntheaders)
  local sizeofoptheader = ntheaders.FileHeader.SizeOfOptionalHeader:value()
  return ntheaders:offset() + sizeofoptheader + 0x18
end

function PeSectionTable:rvaInSection(rva, sectionheader)
  local sectrva = sectionheader.VirtualAddress:value()
  local sectsize = sectionheader.VirtualSize:value()
  
  if (rva >= sectrva) and (rva <= (sectrva + sectsize)) then
    return true
  end
  
  return false
end

function PeSectionTable:inSection(rva, sectionheader)
  local sectrva = sectionheader.VirtualAddress:value()
  local sectsize = sectionheader.VirtualSize:value()
  return ((rva >= sectrva) and (rva < (sectrva + sectsize)))
end

function PeSectionTable:sectionFromRva(rva, ntheaders)
  local numberofsections = ntheaders.FileHeader.NumberOfSections:value()
  
  if numberofsections > 0 then
    local sectiontable = ntheaders:model().SectionTable
    
    for i = 1, numberofsections do
      local section = sectiontable["Section" .. i]
      
      if PeSectionTable.inSection(rva, section) then
	return section
      end
    end
  end
  
  return nil
end

function PeSectionTable:sectionName(rva, ntheaders, buffer)
  local section = PeSectionTable.sectionFromRva(rva, ntheaders)
  
  if section ~= nil then
    return buffer:readString(section.Name:offset())
  end
  
  return ""
end

function PeSectionTable:sectionDisplayName(rva, ntheaders, buffer)
  local name = PeSectionTable.sectionName(rva, ntheaders, buffer)
  return name:gsub("%p", ""):gsub("%a", string.upper, 1)
end

function PeSectionTable:readSections()
end

return PeSectionTable