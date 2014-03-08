local PeDefs = require("formats.portableexecutable.pedefs")

local PeResources = { }

function PeResources.imageResourceNameIsString(val)
  return bit32.band(val, PeDefs.ImageResourceNameIsString) ~= 0
end

function PeResources.imageResourceDataIsDirectory(val)
  return bit32.band(val, PeDefs.ImageResourceDataIsDirectory) ~= 0
end

function PeResources.getEntriesCount(resourcedirectory, buffer)
  local tot = resourcedirectory.NumberOfNamedEntries:value() + resourcedirectory.NumberOfIdEntries:value()
  
  if tot == 0 then
    return "0 Entries"
  elseif tot == 1 then
    return "1 Entry"
  end
  
  return string.format("%d Entries", tot)
end

function PeResources.getNameInfo(namefield, buffer)
  local b = PeResources.imageResourceNameIsString(namefield:value())
  
  if b == true then
    return "Name Is String"
  end
  
  return "Name Is Standard ID"
end

function PeResources.getOffsetInfo(offsetfield, buffer)
  local b = PeResources.imageResourceDataIsDirectory(offsetfield:value())
  
  if b == true then
    return "Offset Is Directory"
  end
  
  return "Offset Is Data"
end

function PeResources.getResourceName(resourceentry, buffer)  
  if PeResources.imageResourceNameIsString(resourceentry.Name:value()) ~= 0 then
    local id = PeDefs.ResourceDirectoryId[resourceentry.Name.Id:value()]
    
    if id ~= nil then
      return id
    end
  end
  
  return ""
end

return PeResources