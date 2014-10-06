local oop = require("oop")
local Address = require("sdk.math.address")
local PeConstants = require("formats.portableexecutable.constants")
local PeFunctions = require("formats.portableexecutable.functions")
local ExportDirectory = require("formats.portableexecutable.datadirectory.exportdirectory")
local ImportDirectory = require("formats.portableexecutable.datadirectory.importdirectory")
local ResourceDirectory = require("formats.portableexecutable.datadirectory.resourcedirectory")

local DataDirectory = oop.class()

function DataDirectory:__ctor(formattree)
  self.formattree = formattree
  
  self.datadirdispatcher = { [1]  = DataDirectory.parseExportDirectory,    [2]  = DataDirectory.parseImportDirectory,            [3]  = DataDirectory.parseResourceDirectory,
                             [4]  = DataDirectory.parseExceptionDirectory, [5]  = DataDirectory.parseSecurityDirectory,          [6]  = DataDirectory.parseBaseRelocationDirectory,
                             [7]  = DataDirectory.parseDebugDirectory,     [8]  = DataDirectory.parseArchDataDirectory,          [9]  = DataDirectory.parseGlobalPtrDirectory,
                             [10] = DataDirectory.parseTlsDirectory,       [11] = DataDirectory.parseLoadConfigurationDirectory, [12] = DataDirectory.parseBoundImportTableDirectory,
                             [13] = DataDirectory.parseIatDirectory,       [14] = DataDirectory.parseDelayImportDirectory,       [15] = DataDirectory.parseComDirectory }
end

function DataDirectory.getDirectoryEntrySection(directoryentry, formattree)
   local sectionname, isvalid = PeFunctions.sectionName(directoryentry.VirtualAddress.value, formattree)
   
   if isvalid then
     sectionname = string.format("%q", sectionname)
   end
  
  return sectionname
end

function DataDirectory:parseExportDirectory(section, offset)
  local exportdirectory = ExportDirectory(self.formattree, section, offset)
  exportdirectory:parse()
end

function DataDirectory:parseImportDirectory(section, offset)
  local importdirectory = ImportDirectory(self.formattree, section, offset)
  importdirectory:parse()
end

function DataDirectory:parseResourceDirectory(section, offset)
  local resourcedirectory = ResourceDirectory(self.formattree, section, offset)
  resourcedirectory:parse()
end

function DataDirectory:parseExceptionDirectory(section, offset)
  
end

function DataDirectory:parseSecurityDirectory(section, offset)
  
end

function DataDirectory:parseBaseRelocationDirectory(section, offset)
  
end

function DataDirectory:parseDebugDirectory(section, offset)
  
end

function DataDirectory:parseArchDataDirectory(section, offset)
  
end

function DataDirectory:parseGlobalPtrDirectory(section, offset)
  
end

function DataDirectory:parseTlsDirectory(section, offset)
  
end

function DataDirectory:parseLoadConfigurationDirectory(section, offset)
  
end

function DataDirectory:parseBoundImportTableDirectory(section, offset)
  
end

function DataDirectory:parseIatDirectory(section, offset)
  
end

function DataDirectory:parseDelayImportDirectory(section, offset)
  
end

function DataDirectory:parseComDirectory(section, offset)
  
end

function DataDirectory:parse()
  local formattree = self.formattree
  local datadirectory = formattree.NtHeaders.OptionalHeader.DataDirectory
  
  for i = 1, PeConstants.NumberOfDirectoryEntries do
    local directoryentry = datadirectory[PeConstants.DirectoryNames[i]]
    
    if directoryentry.VirtualAddress.value > 0 then
      local section = PeFunctions.sectionFromRva(directoryentry.VirtualAddress.value, formattree)
      local directoryoffset = Address.rebase(directoryentry.VirtualAddress.value, section.VirtualAddress.value, section.PointerToRawData.value)
      
      directoryentry:dynamicInfo(DataDirectory.getDirectoryEntrySection)
      self.datadirdispatcher[i](self, section, directoryoffset)
    end
  end
end

return DataDirectory