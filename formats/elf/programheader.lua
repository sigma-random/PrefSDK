local oop = require("oop")
local pref = require("pref")
local ElfExecutable = require("formats.elf.functions")

local ProgramHeader = oop.class()

function ProgramHeader:__ctor(formattree, phoffset, phcount)
  self._formattree = formattree
  self._phoffset = phoffset
  self._phcount = phcount
end

function ProgramHeader:parse()
  local elfheader = self._formattree.ElfHeader
  local programheaders = self._formattree:addStructure("ProgramHeaders", self._phoffset)
  
  for i = 1, self._phcount do
    local ph = programheaders:addStructure("ProgramHeader" .. i):dynamicInfo(ElfExecutable.displayProgramHeaderType)
    ph:addField(ElfExecutable.uintType(elfheader, 32), "p_type")
    ph:addField(ElfExecutable.addressType(elfheader), "p_offset")
    ph:addField(ElfExecutable.addressType(elfheader), "p_vaddr")
    ph:addField(ElfExecutable.addressType(elfheader), "p_paddr")
    ph:addField(ElfExecutable.uintType(elfheader, 32), "p_filesz")
    ph:addField(ElfExecutable.uintType(elfheader, 32), "p_memsz")
    ph:addField(ElfExecutable.uintType(elfheader, 32), "p_flags"):dynamicInfo(ElfExecutable.displayProgramHeaderFlags)
    ph:addField(ElfExecutable.uintType(elfheader, 32), "p_align")
  end
end

return ProgramHeader