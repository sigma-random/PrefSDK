local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")
local DosHeader = require("formats.portableexecutable.dosheader")
local NtHeaders = require("formats.portableexecutable.ntheaders")
local SectionTable = require("formats.portableexecutable.sectiontable")
local DataDirectory = require("formats.portableexecutable.datadirectory")
local SectionTableDialog = require("formats.portableexecutable.ui.sectiontabledialog")

local PeFormat = FormatDefinition.register("Portable Executable Format", "Windows", "Dax", "1.0")

function PeFormat:showSectionTable(startoffset, endoffset)
  local sectiontabledialog = SectionTableDialog(self.formattree)
  sectiontabledialog:show()
end

PeFormat:registerOption("Section Table", PeFormat.showSectionTable)

function PeFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
  self.peheaders = { } -- Store Headers' definition
end

function PeFormat:validateFormat()
  self:checkData(0, DataType.UInt16_LE, 0x5A4D)
  
  local peheaderoffset = self.databuffer:readType(0x3C, DataType.UInt32_LE) -- Get NtHeaders' offset
  self:checkData(peheaderoffset, DataType.UInt32_LE, 0x00004550)
end

function PeFormat:parseFormat(formattree)
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
end