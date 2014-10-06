local oop = require("oop")
local Address = require("sdk.math.address")
local Pointer = require("sdk.math.pointer")
local PeConstants = require("formats.portableexecutable.constants")

local ExportDirectory = oop.class()

function ExportDirectory:__ctor(formattree, section, directoryoffset)
  self.buffer = formattree.buffer
  self.formattree = formattree
  self.section = section
  self.directoryoffset = directoryoffset
end

function ExportDirectory:parseExportedFunctions(exportdirectory)
  local formattree, buffer = self.formattree, self.buffer
  local sectva, sectoffset = self.section.VirtualAddress.value, self.section.PointerToRawData.value
  local funcoffset = Address.rebase(exportdirectory.AddressOfFunctions.value, sectva, sectoffset)
  local namesoffset = Address.rebase(exportdirectory.AddressOfNames.value, sectva, sectoffset)
  local nameordoffset = Address.rebase(exportdirectory.AddressOfNameOrdinals.value, sectva, sectoffset)
  local base = exportdirectory.Base.value
  
  local exportedfunctions = formattree:addStructure("ExportedFunctions", funcoffset)
  local pfunc = Pointer(funcoffset, pref.datatype.UInt32_LE, buffer)
  local pnames = Pointer(namesoffset, pref.datatype.UInt32_LE, buffer)
  local pnameord = Pointer(nameordoffset, pref.datatype.UInt16_LE, buffer)
  
  for i = 0, exportdirectory.NumberOfFunctions.value - 1 do    
    if pfunc[i] ~= 0 then
      local found = false
      local ordinal = base + i
      
      for j = 0, exportdirectory.NumberOfNames.value - 1 do        
        if pnameord[j] == i then
          found = true
          local nameoffset = Address.rebase(pnames[j], sectva, sectoffset)
          exportedfunctions:addField(pref.datatype.UInt32_LE, buffer:readString(nameoffset))
          break
        end
      end
      
      if not found then
        exportedfunctions:addField(pref.datatype.UInt32_LE, string.format("Ordinal_%04X", ordinal))
      end
    end
  end
end

function ExportDirectory:parse()
  local exportdirectory = self.formattree:addStructure(PeConstants.DirectoryNames[1], self.directoryoffset)
  exportdirectory:addField(pref.datatype.UInt32_LE, "Characteristics")
  exportdirectory:addField(pref.datatype.UInt32_LE, "TimeDateStamp")
  exportdirectory:addField(pref.datatype.UInt16_LE, "MajorVersion")
  exportdirectory:addField(pref.datatype.UInt16_LE, "MinorVersion")
  exportdirectory:addField(pref.datatype.UInt32_LE, "Name")
  exportdirectory:addField(pref.datatype.UInt32_LE, "Base")
  exportdirectory:addField(pref.datatype.UInt32_LE, "NumberOfFunctions")
  exportdirectory:addField(pref.datatype.UInt32_LE, "NumberOfNames")
  exportdirectory:addField(pref.datatype.UInt32_LE, "AddressOfFunctions")
  exportdirectory:addField(pref.datatype.UInt32_LE, "AddressOfNames")
  exportdirectory:addField(pref.datatype.UInt32_LE, "AddressOfNameOrdinals")
  
  self:parseExportedFunctions(exportdirectory)
end

return ExportDirectory
