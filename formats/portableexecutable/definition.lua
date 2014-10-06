local qt = require("qt")
local pref = require("pref")
local PeFunctions = require("formats.portableexecutable.functions")
local DosHeader = require("formats.portableexecutable.dosheader")
local NtHeaders = require("formats.portableexecutable.ntheaders")
local SectionTable = require("formats.portableexecutable.sectiontable")
local DataDirectory = require("formats.portableexecutable.datadirectory")

local PeFormat = pref.format.create("Portable Executable Format", "Windows", "Dax", "1.0")

function PeFormat:validate(validator)
  local buffer = validator.buffer
  validator:checkType(0, 0x5A4D, pref.datatype.UInt16_LE)
  
  local peheaderoffset = buffer:readType(0x3C, pref.datatype.UInt32_LE) -- Get NtHeaders' offset
  validator:checkType(peheaderoffset, 0x00004550, pref.datatype.UInt32_LE)
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
  
  PeFunctions.analyzeSignature(self, formattree)
  PeFunctions.displaySectionsEntropy(self, formattree)
end

function PeFormat:view(formattree)
  return qt.qml.load("formats/portableexecutable/ui/PeEditor.qml", { name = "formattree", 
                                                                     object = formattree })
end

return PeFormat