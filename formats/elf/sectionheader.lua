local oop = require("oop")
local pref = require("pref")
local ElfExecutable = require("formats.elf.functions")
local SectionParser = require("formats.elf.sectionparser")

local SectionHeader = oop.class()

function SectionHeader:__ctor(formattree, shoffset, shcount)
  self._formattree = formattree
  self._shoffset = shoffset
  self._shcount = shcount
end

function SectionHeader:parse()
  local elfheader = self._formattree.ElfHeader
  local sectionheaders = self._formattree:addStructure("SectionHeaders", self._shoffset)
  local sectionparser = SectionParser(self._formattree)
  
  for i = 1, self._shcount do
    local sh = sectionheaders:addStructure("SectionHeader" .. (i - 1)):dynamicInfo(ElfExecutable.displaySectionName)
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_name")
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_type"):dynamicInfo(ElfExecutable.displaySectionHeaderTypeName)
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_flags"):dynamicInfo(ElfExecutable.displaySectionHeaderFlags)
    sh:addField(ElfExecutable.addressType(elfheader), "sh_addr")
    sh:addField(ElfExecutable.addressType(elfheader), "sh_offset")
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_size")
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_link")
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_info")
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_addralign")
    sh:addField(ElfExecutable.uintType(elfheader, 32), "sh_entsize")
    
    sectionparser:parse(sh, i - 1)
  end
end

return SectionHeader