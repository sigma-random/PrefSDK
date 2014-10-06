local Address = require("sdk.math.address")
local PeConstants = require("formats.portableexecutable.constants")
local SignatureDB = require("formats.portableexecutable.signaturedb")

local PeFunctions = { }

function PeFunctions.analyzeSignature(formatdefinition, formattree)
  local buffer = formattree.buffer
  local eprva = formattree.NtHeaders.OptionalHeader.AddressOfEntryPoint.value
  local section = PeFunctions.sectionFromRva(eprva, formattree)
   
  if section == nil then
    formatdefinition:error("Cannot find a valid section")
    return
  end
   
  local epoffset = Address.rebase(eprva, section.VirtualAddress.value, section.PointerToRawData.value)
  local found, signature = SignatureDB():match(buffer, epoffset)
  
  if found then
    formatdefinition:logline("Matched Signature: '" .. signature .. "'")
    return
  end
  
  formatdefinition:warning("Unknown Signature detected")
end

function PeFunctions.displaySectionsEntropy(formatdefinition, formattree)
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections.value
  
  for i = 1, numberofsections do
    local section = formattree.SectionTable["Section" .. i]
    
    if (section.SizeOfRawData.value > 0) and (bit.band(section.Characteristics.value, 0x20000000) ~= 0) then
      local e = pref.math.entropy(formattree.buffer, section.PointerToRawData.value, section.VirtualSize.value)
      formatdefinition:logline(string.format("Section %q Entropy: %f", section.Name.value, e))
    end
  end
end

function PeFunctions.rvaInSection(rva, section)
  local sectrva = section.VirtualAddress.value
  local sectsize = section.VirtualSize.value
  
  if (rva >= sectrva) and (rva < (sectrva + sectsize)) then
    return true
  end
  
  return false
end

function PeFunctions.sectionFromRva(rva, formattree)
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections.value
  
  if numberofsections > 0 then
    local sectiontable = formattree.SectionTable
    
    for i = 1, numberofsections do
      local section = sectiontable["Section" .. i]
      
      if PeFunctions.rvaInSection(rva, section) then
        return section
      end
    end
  end
  
  return nil
end

function PeFunctions.sectionName(rva, formattree)
  local section = PeFunctions.sectionFromRva(rva, formattree)
  
  if section ~= nil then
    return section.Name.value, true
  end
  
  return "INVALID", false
end

function PeFunctions.imageFirstSection(formattree)
  local ntheaders = formattree.NtHeaders
  local optheadersize = ntheaders.FileHeader.SizeOfOptionalHeader.value
  return ntheaders.offset + optheadersize + 0x18
end

function PeFunctions.isResourceNameString(val)
  return bit.band(val, PeConstants.ImageResourceNameIsString[32]) ~= 0
end

function PeFunctions.isResourceDataDirectory(val)
  return bit.band(val, PeConstants.ImageResourceDataIsDirectory[32]) ~= 0
end

return PeFunctions
