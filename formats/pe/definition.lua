local pref = require("pref")
local Address = require("sdk.math.address")
local PeFunctions = require("formats.pe.functions")
local DosHeader = require("formats.pe.dosheader")
local NtHeaders = require("formats.pe.ntheaders")
local SectionTable = require("formats.pe.sectiontable")
local DataDirectory = require("formats.pe.datadirectory")
local SignatureDB = require("formats.pe.signaturedb")

local DataType = pref.datatype
local PeFormat = pref.format.create("Portable Executable", "Windows", "Dax", "1.0")

function PeFormat:validate(validator)
  local buffer = validator.buffer
  validator:checkType(0, 0x5A4D, DataType.UInt16_LE)
  
  local peheaderoffset = buffer:readType(0x3C, DataType.UInt32_LE) -- Get NtHeaders' offset
  validator:checkType(peheaderoffset, 0x00004550, DataType.UInt32_LE)
end

function PeFormat:parse(formattree)
  local dosheader = DosHeader(formattree)
  dosheader:parse()

  local ntheaders = NtHeaders(formattree)
  ntheaders:parse()
  
  local sectiontable = SectionTable(formattree)
  sectiontable:parse()
   
  local datadirectory = DataDirectory(formattree, ntheaders, sectiontable)
  datadirectory:parse()
  
  self:analyzeSignature(formattree, sectiontable)
  self:displaySectionsEntropy(formattree)
end

function PeFormat:analyzeSignature(formattree)
  local buffer = formattree.buffer
  local eprva = formattree.NtHeaders.OptionalHeader.AddressOfEntryPoint.value
  local section = PeFunctions.sectionFromRva(eprva, formattree)
   
  if section == nil then
    pref.error("Cannot find a valid section")
    return
  end
   
  local epoffset = Address.rebase(eprva, section.VirtualAddress.value, section.PointerToRawData.value)
  local found, signature = SignatureDB():match(buffer, epoffset)
  
  if found then
    pref.logline("Matched Signature: '%s'", signature)
    return
  end
  
  pref.warning("Unknown Signature detected")
end

function PeFormat:displaySectionsEntropy(formattree)
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections.value
  
  for i = 1, numberofsections do
    local section = formattree.SectionTable["Section" .. i]
    
    if (section.SizeOfRawData.value > 0) and (bit.band(section.Characteristics.value, 0x20000000) ~= 0) then
      local e = pref.math.entropy(formattree.buffer, section.PointerToRawData.value, section.VirtualSize.value)
      pref.logline("Section '%s' Entropy: %f", section.Name.value, e)
    end
  end
end

function PeFormat:view(formattree)
  return pref.format.loadview("formats/pe/ui/PeEditor.qml", formattree)
end

return PeFormat