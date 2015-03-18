local oop = require("oop")
local pref = require("pref")
local ElfExecutable = require("formats.elf.functions")
local ElfConstants = require("formats.elf.constants")

local SectionParser = oop.class()

function SectionParser:__ctor(formattree)
  local st = ElfConstants.sectionheadertypes
  
  self._formattree = formattree
  
  self._dispatcher = { [st.StrTab] = SectionParser.parseStringTable,
                       [st.SymTab] = SectionParser.parseSymbolTable,
                       [st.DynSym] = SectionParser.parseSymbolTable }
end

function SectionParser.parseSymbols(symboltable, formattree)
  local i, idx, elfheader = 0, symboltable.name:match("[0-9]+"), formattree.ElfHeader
  local sectionheader = formattree.SectionHeaders["SectionHeader" .. idx]
  
  while symboltable.size < sectionheader.sh_size.value do
    local symbol = symboltable:addStructure("Symbol" .. i)
    symbol:addField(ElfExecutable.wordType(elfheader), "st_name")
    symbol:addField(ElfExecutable.addressType(elfheader), "st_value")
    symbol:addField(ElfExecutable.wordType(elfheader), "st_size")
    symbol:addField(pref.datatype.UInt8, "st_info")
    symbol:addField(pref.datatype.UInt8, "st_other")
    symbol:addField(ElfExecutable.halfType(elfheader), "st_shndx")
    
    i = i + 1
  end
end

function SectionParser.parseStrings(stringtable, formattree)
  local i, idx, elfheader = 0, stringtable.name:match("[0-9]+"), formattree.ElfHeader
  local sectionheader = formattree.SectionHeaders["SectionHeader" .. idx]
  
  while stringtable.size < sectionheader.sh_size.value do
    local s = formattree.buffer:readString(stringtable.offset + stringtable.size)
    local f = stringtable:addField(pref.datatype.Character, "st_string" .. i, #s + 1)
    i = i + #s + 1
  end
end

function SectionParser:parseStringTable(sectionheader, index)
  local offset = sectionheader.sh_offset.value
  self._formattree:addStructure("StringTable" .. index, offset):dynamicParser(sectionheader.sh_size.value > 0, SectionParser.parseStrings)
end

function SectionParser:parseSymbolTable(sectionheader, index)
  local offset = sectionheader.sh_offset.value
  self._formattree:addStructure("SymbolTable" .. index, offset):dynamicParser(sectionheader.sh_size.value > 0, SectionParser.parseSymbols)
end

function SectionParser:parse(sectionheader, index)
  if sectionheader.sh_size.value == 0 then -- Skip Empty Sections
    return
  end
  
  local dispatcher = self._dispatcher[sectionheader.sh_type.value]
  
  if dispatcher then
    dispatcher(self, sectionheader, index)
  end
end

return SectionParser
