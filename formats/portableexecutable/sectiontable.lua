local oop = require("oop")
local PeFunctions = require("formats.portableexecutable.functions")

local SectionTable = oop.class()

function SectionTable:__ctor(formattree)
  self.formattree = formattree
end

function SectionTable.getSectionName(section, formattree)
  return string.format("%q", section.Name.value)
end

function SectionTable:parse()
  local formattree = self.formattree
  local numberofsections = formattree.NtHeaders.FileHeader.NumberOfSections.value
  
  if numberofsections > 0 then
    local sectionoffset = PeFunctions.imageFirstSection(formattree)
    local sectiontable = formattree:addStructure("SectionTable", sectionoffset)
    
     for i = 1, numberofsections do
      local section = sectiontable:addStructure("Section" .. i):dynamicInfo(SectionTable.getSectionName)
      section:addField(pref.datatype.Character, "Name", 8)
      section:addField(pref.datatype.UInt32_LE, "VirtualSize")
      section:addField(pref.datatype.UInt32_LE, "VirtualAddress")
      section:addField(pref.datatype.UInt32_LE, "SizeOfRawData")
      section:addField(pref.datatype.UInt32_LE, "PointerToRawData")
      section:addField(pref.datatype.UInt32_LE, "PointertoRelocations")
      section:addField(pref.datatype.UInt32_LE, "PointertoLineNumbers")
      section:addField(pref.datatype.UInt16_LE, "NumberOfRelocations")
      section:addField(pref.datatype.UInt16_LE, "NumberOfLineNumbers")
      section:addField(pref.datatype.UInt32_LE, "Characteristics")
    end
  end
end

return SectionTable