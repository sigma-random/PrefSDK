local pref = require("pref")
local ElfConstants = require("formats.elf.constants")

local ElfExecutable = { }

function ElfExecutable.addressType(elfheader)
  if elfheader.e_ident.class.value == ElfConstants.classtypes.Class32 then
    if elfheader.e_ident.data.value == ElfConstants.datatypes.Data2LSB then
      return pref.datatype.UInt32_LE
    elseif elfheader.e_ident.data.value == ElfConstants.datatypes.Data2MSB then
      return pref.datatype.UInt32_BE
    end
    
    return pref.datatype.UInt32
  elseif elfheader.e_ident.class.value == ElfConstants.Class64 then
    if elfheader.e_ident.data.value == ElfConstants.datatypes.Data2LSB then
      return pref.datatype.UInt64_LE
    elseif elfheader.e_ident.data.value == ElfConstants.datatypes.Data2MSB then
      return pref.datatype.UInt64_BE
    end
    
    return pref.datatype.UInt32
  end
end

function ElfExecutable.uintType(elfheader, bitwidth)
  if elfheader.e_ident.data.value == ElfConstants.datatypes.Data2LSB then
    return pref.datatype["UInt" .. tostring(bitwidth) .. "_LE"]
  else
    return pref.datatype["UInt" .. tostring(bitwidth) .. "_BE"]
  end
end

function ElfExecutable.wordType(elfheader)
  if elfheader.e_ident.data.value == ElfConstants.datatypes.Data2LSB then
    return pref.datatype.UInt32_LE
  else
    return pref.datatype.UInt32_BE
  end
end

function ElfExecutable.halfType(elfheader)
  if elfheader.e_ident.data.value == ElfConstants.datatypes.Data2LSB then
    return pref.datatype.UInt16_LE
  else
    return pref.datatype.UInt16_BE
  end
end

function ElfExecutable.displayArchitecture(classfield, formattree)
  if classfield.value == ElfConstants.classtypes.Class32 then
    return "32 Bit"
  elseif classfield.value == ElfConstants.Class64 then
    return "64 Bit"
  end
  
  return "Invalid"
end

function ElfExecutable.displayData(datafield, formattree)
  if datafield.value == ElfConstants.datatypes.Data2LSB then
    return "Little Endian"
  elseif datafield.value == ElfConstants.datatypes.Data2MSB then
    return "Big Endian"
  end
  
  return "Invalid"
end

function ElfExecutable.displayVersion(versionfield, formattree)
  if versionfield.value == 1 then
    return "Current"
  end
  
  return "Invalid"
end

function ElfExecutable.displayOsABI(versionfield, formattree)
  local abi = ElfConstants.abiname[versionfield.value]
  
  if abi then
    return abi
  end
  
  return "Invalid"
end

function ElfExecutable.displayType(typefield, formattree)
  local type = ElfConstants.elftype[typefield.value]
  
  if type then
    return type
  end
  
  return "Invalid"
end

function ElfExecutable.displayMachine(machinefield, formattree)
  local machine = ElfConstants.elfmachine[machinefield.value]
  
  if machine then
    return machine
  end
  
  return "Invalid"
end

function ElfExecutable.displayProgramHeaderType(ph, formattree)
  local type = ElfConstants.programheadertype[ph.p_type.value]
  
  if type then
    return type
  end
  
  return "Invalid"
end

function ElfExecutable.displayProgramHeaderFlags(phflags, formattree)
  local flags = ""
  
  if bit.band(phflags.value, ElfConstants.programheaderflags.Readable) ~= 0 then
    flags = flags .. "R"
  end
  
  if bit.band(phflags.value, ElfConstants.programheaderflags.Writable) ~= 0 then
    flags = flags .. "W"
  end
  
  if bit.band(phflags.value, ElfConstants.programheaderflags.Executable) ~= 0 then
    flags = flags .. "E"
  end
  
  if #flags == 0 then
    return "Invalid"
  end
  
  return flags
end

function ElfExecutable.displaySectionHeaderTypeName(shtype, formattree)
  local typename = ElfConstants.sectionheadertypenames[shtype.value]
  
  if typename then
    return typename
  end
  
  return "Invalid"
end

function ElfExecutable.displaySectionHeaderFlags(shflags, formattree)
  local flags = ""
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Write) ~= 0 then
    flags = flags .. " WRITE"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Alloc) ~= 0 then
    flags = flags .. " ALLOC"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.ExeInstr) ~= 0 then
    flags = flags .. " EXEINSTR"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Merge) ~= 0 then
    flags = flags .. " MERGE"
  end

  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Strings) ~= 0 then
    flags = flags .. " STRINGS"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.LinkInfo) ~= 0 then
    flags = flags .. " INFOLINK"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.LinkOrder) ~= 0 then
    flags = flags .. " LINKORDER"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Group) ~= 0 then
    flags = flags .. " GROUP"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Tls) ~= 0 then
    flags = flags .. " TLS"
  end
  
  if bit.band(shflags.value, ElfConstants.sectionheaderflags.Compressed) ~= 0 then
    flags = flags .. " COMPRESSED"
  end
  
  if #flags == 0 then
    return "Invalid"
  end
  
  return flags:gsub("^%s*(.-)%s*$", "%1")
end

function ElfExecutable.readStringTable(index, formattree)
  local stringtableidx = formattree.ElfHeader.e_shstrndx.value
  
  if stringtableidx == 0 then
    return ""
  end
  
  local stringtablesection = formattree.SectionHeaders["SectionHeader" .. stringtableidx]
  return formattree.buffer:readString(stringtablesection.sh_offset.value + index)
end

function ElfExecutable.displaySectionName(sectionheader, formattree)
  return ElfExecutable.readStringTable(sectionheader.sh_name.value, formattree)
end

return ElfExecutable
