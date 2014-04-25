local oop = require("sdk.lua.oop")
local DataType = require("sdk.types.datatype")
local PeConstants = require("formats.portableexecutable.peconstants")

local DataDirectory = oop.class()

function DataDirectory:__ctor(formattree, ntheaders, sectiontable)
  self.formattree = formattree
  self.ntheaders = ntheaders
  self.sectiontable = sectiontable
end

function DataDirectory.getDirectoryEntrySection(formatdefinition, directoryentry)
  local sectiontable = formatdefinition.peheaders.SectionTable
  local sectionname = sectiontable:sectionName(directoryentry.VirtualAddress:value())
  
  if #sectionname then
    return string.format("%q", sectionname)
  end
  
  return ""
end

function DataDirectory:parse()
  local sectiontable = self.sectiontable
  local datadirectory = self.formattree.NtHeaders.OptionalHeader.DataDirectory
  
  for i = 1, PeConstants.NumberOfDirectoryEntries do
    local directoryentry = datadirectory[PeConstants.DirectoryNames[i]]
    
    if directoryentry.VirtualAddress:value() > 0 then
      directoryentry:dynamicInfo(DataDirectory.getDirectoryEntrySection)
    end
  end
end

return DataDirectory