local oop = require("sdk.lua.oop")
local Address = require("sdk.math.address")
local MathFunctions = require("sdk.math.functions")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")
local MessageBox = require("sdk.ui.messagebox")
local DosHeader = require("formats.portableexecutable.dosheader")
local NtHeaders = require("formats.portableexecutable.ntheaders")
local SectionTable = require("formats.portableexecutable.sectiontable")
local DataDirectory = require("formats.portableexecutable.datadirectory")
local SectionTableDialog = require("formats.portableexecutable.ui.sectiontabledialog")
local SignatureDB = require("formats.portableexecutable.signaturedb")

local PeFormat = oop.class(FormatDefinition)

function PeFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
  self:registerOption("Section Table", PeFormat.showSectionTable)
  self.peheaders = { } -- Store Headers' definition
end

function PeFormat:showSectionTable(startoffset, endoffset)
  local sectiontabledialog = SectionTableDialog(self.tree)
  sectiontabledialog:show()
end

function PeFormat:analyzeSignature(eprva)
  local section = self.peheaders.SectionTable:sectionFromRva(eprva)
   
  if section == nil then
    self:error("Cannot find a valid section")
    return
  end
   
  local epoffset = Address.rebase(eprva, section.VirtualAddress:value(), section.PointerToRawData:value())
  local found, signature = SignatureDB():match(self.databuffer, epoffset)
  
  if found then
    self:logLine("Matched Signature: '" .. signature .. "'")
    return
  end
  
  self:warning("Unknown Signature detected")
end

function PeFormat:displaySectionsEntropy()
  local numberofsections = self.tree.NtHeaders.FileHeader.NumberOfSections:value()
  
  for i = 1, numberofsections do
    local section = self.tree.SectionTable["Section" .. i]
    
    if (section.SizeOfRawData:value() > 0) and (bit.band(section.Characteristics:value(), 0x20000000) ~= 0) then
      local e = MathFunctions.entropy(self.databuffer, section.PointerToRawData:value(), section.VirtualSize:value())
      self:logLine(string.format("Section %q Entropy: %f", section.Name:value(), e))
    end
  end
end

function PeFormat:validate()
  self:checkData(0, DataType.UInt16_LE, 0x5A4D)
  
  local peheaderoffset = self.databuffer:readType(0x3C, DataType.UInt32_LE) -- Get NtHeaders' offset
  self:checkData(peheaderoffset, DataType.UInt32_LE, 0x00004550)
end

function PeFormat:parse(formattree)
  local dosheader = DosHeader(formattree)
  dosheader:parse()

  local ntheaders = NtHeaders(formattree)
  ntheaders:parse()
  
  local sectiontable = SectionTable(formattree, ntheaders)
  sectiontable:parse()
  
  local datadirectory = DataDirectory(self.databuffer, formattree, ntheaders, sectiontable)
  datadirectory:parse()
  
  self.peheaders["DosHeader"] = dosheader
  self.peheaders["NtHeaders"] = ntheaders
  self.peheaders["SectionTable"] = sectiontable
  self.peheaders["DataDirectory"] = datadirectory
  
  self:analyzeSignature(self.tree.NtHeaders.OptionalHeader.AddressOfEntryPoint:value())
  self:displaySectionsEntropy()
end

return PeFormat