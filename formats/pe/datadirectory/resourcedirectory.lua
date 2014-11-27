local oop = require("oop")
local Address = require("sdk.math.address")
local Pointer = require("sdk.math.pointer")
local PeConstants = require("formats.pe.constants")

local DataType = pref.datatype
local ResourceDirectory = oop.class()

function ResourceDirectory:__ctor(formattree, section, directoryoffset)
  self.buffer = formattree.buffer
  self.formattree = formattree
  self.section = section
  self.directoryoffset = directoryoffset
end

function ResourceDirectory.isResourceNameString(val)
  return bit.band(val, PeConstants.ImageResourceNameIsString[32]) ~= 0
end

function ResourceDirectory.isResourceDataDirectory(val)
  return bit.band(val, PeConstants.ImageResourceDataIsDirectory[32]) ~= 0
end

function ResourceDirectory.getEntriesCount(formatdefinition, resourcedirectory)
  local tot = resourcedirectory.NumberOfNamedEntries.value + resourcedirectory.NumberOfIdEntries.value
  
  if tot == 0 then
    return "0 Entries"
  elseif tot == 1 then
    return "1 Entry"
  end
  
  return string.format("%d Entries", tot)
end

function ResourceDirectory.getResourceName(entry, formattree)
  if not ResourceDirectory.isResourceNameString(entry.Name.value) then
    local id = PeConstants.ResourceDirectoryId[entry.Name.Id.value]
    return id or ""
  end
  
  return ""
end

function ResourceDirectory.getNameInfo(name, formattree)
  if ResourceDirectory.isResourceNameString(name.value) then
    return "Name is String"
  end
  
  return "Name is ID"
end

function ResourceDirectory.getOffsetInfo(offsettodata, formattree)
  if ResourceDirectory.isResourceDataDirectory(offsettodata.value) then
    return "Offset is Directory"
  end
  
  return "Offset is Data"
end

function ResourceDirectory:parse()
  local resourcedirectory = self.formattree:addStructure(PeConstants.DirectoryNames[3], self.directoryoffset)
  resourcedirectory:addField(DataType.UInt32_LE, "Characteristics")
  resourcedirectory:addField(DataType.UInt32_LE, "TimeDateStamp")
  resourcedirectory:addField(DataType.UInt16_LE, "MajorVersion")
  resourcedirectory:addField(DataType.UInt16_LE, "MinorVersion")
  resourcedirectory:addField(DataType.UInt16_LE, "NumberOfNamedEntries")
  resourcedirectory:addField(DataType.UInt16_LE, "NumberOfIdEntries")
  
  local totentries = resourcedirectory.NumberOfNamedEntries.value + resourcedirectory.NumberOfIdEntries.value
  local directoryentries = resourcedirectory:addStructure("DirectoryEntries")
  
  for i = 1, totentries do
    local entry = directoryentries:addStructure("Entry" .. i):dynamicInfo(ResourceDirectory.getResourceName)
    local fname = entry:addField(DataType.UInt32_LE, "Name"):dynamicInfo(ResourceDirectory.getNameInfo)
    fname:setBitField("Id", 0, 16)
    
    local foffsettodata = entry:addField(DataType.UInt32_LE, "OffsetToData"):dynamicInfo(ResourceDirectory.getOffsetInfo)
    foffsettodata:setBitField("Offset", 0, 30)
    foffsettodata:setBitField("IsDirectory", 31, 32)
  end
end

return ResourceDirectory