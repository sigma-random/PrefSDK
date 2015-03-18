-- ELF Format References:
-- 1) man elf
-- 2) http://www.skyfree.org/linux/references/ELF_Format.pdf
-- 3) http://lxr.free-electrons.com (mainly: elf.h)

local pref = require("pref")
local ElfExecutable = require("formats.elf.functions")
local ElfConstants = require("formats.elf.constants")
local ProgramHeader = require("formats.elf.programheader")
local SectionHeader = require("formats.elf.sectionheader")

local ElfFormat = pref.format.create("Executable and Linkable Format (ELF)", "Linux/Unix/BSD", "Dax", "1.0")

function ElfFormat:validate(validator)
  validator:checkType(0, 0x7F, pref.datatype.UInt8)
  validator:checkAscii(1, "ELF")
  
  local classok, dataok = false, false
  
  for _, v in pairs(ElfConstants.classtypes) do
    if validator:checkType(4, v, pref.datatype.UInt8, false) == true then
      classok = true
      break
    end
  end
  
  if not classok then
    validator:error("Invalid Class Field")
  end
  
  for _, v in pairs(ElfConstants.datatypes) do
    if validator:checkType(4, v, pref.datatype.UInt8, false) == true then
      dataok = true
      break
    end
  end
  
  if not dataok then
    validator:error("Invalid Data Field")
  end
  
  validator:checkType(6, 1, pref.datatype.UInt8)
  
  local abiok = false
  
  for k, _ in pairs(ElfConstants.abiname) do
    if validator:checkType(7, k, pref.datatype.UInt8, false) == true then
      abiok = true
      break
    end
  end
  
  if not abiok then
    validator:error("Invalid OS ABI")
  end
  
  validator:checkType(7, 0, pref.datatype.UInt8)
end

function ElfFormat:parse(formattree)
  local elfheader = formattree:addStructure("ElfHeader")
  
  local ident = elfheader:addStructure("e_ident")
  ident:addField(pref.datatype.UInt8, "mag_0")
  ident:addField(pref.datatype.Character, "mag_123", 3)
  ident:addField(pref.datatype.UInt8, "class"):dynamicInfo(ElfExecutable.displayArchitecture)
  ident:addField(pref.datatype.UInt8, "data"):dynamicInfo(ElfExecutable.displayData)
  ident:addField(pref.datatype.UInt8, "version"):dynamicInfo(ElfExecutable.displayVersion)
  ident:addField(pref.datatype.UInt8, "os_abi"):dynamicInfo(ElfExecutable.displayOsABI)
  ident:addField(pref.datatype.UInt8, "abi_version")
  ident:addField(pref.datatype.Blob, "pad", 7)
  
  elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_type"):dynamicInfo(ElfExecutable.displayType)
  elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_machine"):dynamicInfo(ElfExecutable.displayMachine)
  elfheader:addField(ElfExecutable.uintType(elfheader, 32), "e_version")
  elfheader:addField(ElfExecutable.addressType(elfheader), "e_entry")
  local phoffset = elfheader:addField(ElfExecutable.addressType(elfheader), "e_phoff")
  local shoffset = elfheader:addField(ElfExecutable.addressType(elfheader), "e_shoff")
  elfheader:addField(ElfExecutable.uintType(elfheader, 32), "e_flags")
  elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_ehsize")
  elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_phentsize")
  local phcount = elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_phnum")
  elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_shsize")
  local shcount = elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_shnum")
  elfheader:addField(ElfExecutable.uintType(elfheader, 16), "e_shstrndx")
  
  if phoffset.value ~= 0 then
    local programheader = ProgramHeader(formattree, phoffset.value, phcount.value)
    programheader:parse()
  end
  
  if shoffset.value ~= 0 then
    local sectionheader = SectionHeader(formattree, shoffset.value, shcount.value)
    sectionheader:parse()
  end
end

return ElfFormat
