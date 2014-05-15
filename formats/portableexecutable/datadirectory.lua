local oop = require("sdk.lua.oop")
local Address = require("sdk.math.address")
local DataType = require("sdk.types.datatype")
local PeConstants = require("formats.portableexecutable.peconstants")
local ExportDirectory = require("formats.portableexecutable.datadirectory.exportdirectory")
local ImportDirectory = require("formats.portableexecutable.datadirectory.importdirectory")
local ResourceDirectory = require("formats.portableexecutable.datadirectory.resourcedirectory")

local DataDirectory = oop.class()

function DataDirectory:__ctor(databuffer, formattree, ntheaders, sectiontable)
  self.databuffer = databuffer
  self.formattree = formattree
  self.ntheaders = ntheaders
  self.sectiontable = sectiontable
  
  self.datadirdispatcher = { [1]  = DataDirectory.parseExportDirectory,    [2]  = DataDirectory.parseImportDirectory,            [3]  = DataDirectory.parseResourceDirectory,
                             [4]  = DataDirectory.parseExceptionDirectory, [5]  = DataDirectory.parseSecurityDirectory,          [6]  = DataDirectory.parseBaseRelocationDirectory,
                             [7]  = DataDirectory.parseDebugDirectory,     [8]  = DataDirectory.parseArchDataDirectory,          [9]  = DataDirectory.parseGlobalPtrDirectory,
                             [10] = DataDirectory.parseTlsDirectory,       [11] = DataDirectory.parseLoadConfigurationDirectory, [12] = DataDirectory.parseBoundImportTableDirectory,
                             [13] = DataDirectory.parseIatDirectory,       [14] = DataDirectory.parseDelayImportDirectory,       [15] = DataDirectory.parseComDirectory }
end

function DataDirectory.getDirectoryEntrySection(formatdefinition, directoryentry)
  local sectiontable = formatdefinition.peheaders.SectionTable
  local sectionname = sectiontable:sectionName(directoryentry.VirtualAddress:value())
  
  if #sectionname then
    return string.format("%q", sectionname)
  end
  
  return "INVALID"
end

function DataDirectory:parseExportDirectory(section, offset)
  local exportdirectory = ExportDirectory(self.databuffer, self.formattree, section, offset)
  exportdirectory:parse()
  return exportdirectory
end

function DataDirectory:parseImportDirectory(section, offset)
  local importdirectory = ImportDirectory(self.databuffer, self.formattree, section, offset)
  importdirectory:parse()
  return importdirectory
end

function DataDirectory:parseResourceDirectory(section, offset)
  local resourcedirectory = ResourceDirectory(self.databuffer, self.formattree, section, offset)
  resourcedirectory:parse()
  return resourcedirectory
end

function DataDirectory:parseExceptionDirectory(section, offset)
  return nil
end

function DataDirectory:parseSecurityDirectory(section, offset)
  return nil
end

function DataDirectory:parseBaseRelocationDirectory(section, offset)
  return nil
end

function DataDirectory:parseDebugDirectory(section, offset)
  return nil
end

function DataDirectory:parseArchDataDirectory(section, offset)
  return nil
end

function DataDirectory:parseGlobalPtrDirectory(section, offset)
  return nil
end

function DataDirectory:parseTlsDirectory(section, offset)
  return nil
end

function DataDirectory:parseLoadConfigurationDirectory(section, offset)
  return nil
end

function DataDirectory:parseBoundImportTableDirectory(section, offset)
  return nil
end

function DataDirectory:parseIatDirectory(section, offset)
  return nil
end

function DataDirectory:parseDelayImportDirectory(section, offset)
  return nil
end

function DataDirectory:parseComDirectory(section, offset)
  return nil
end

function DataDirectory:parse()
  local sectiontable = self.sectiontable
  local datadirectory = self.formattree.NtHeaders.OptionalHeader.DataDirectory
  
  for i = 1, PeConstants.NumberOfDirectoryEntries do
    local directoryentry = datadirectory[PeConstants.DirectoryNames[i]]
    
    if directoryentry.VirtualAddress:value() > 0 then
      local section = sectiontable:sectionFromRva(directoryentry.VirtualAddress:value())
      local directoryoffset = Address.rebase(directoryentry.VirtualAddress:value(), section.VirtualAddress:value(), section.PointerToRawData:value())
      
      directoryentry:dynamicInfo(DataDirectory.getDirectoryEntrySection)
      self[PeConstants.DirectoryNames[1]] = self.datadirdispatcher[i](self, section, directoryoffset)
    end
  end
end

return DataDirectory