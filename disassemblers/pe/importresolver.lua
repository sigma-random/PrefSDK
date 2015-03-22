local pref = require("pref")
local oop = require("oop")
local PeFunctions = require("formats.pe.functions")

local DataType = pref.datatype
local SymbolType = pref.disassembler.symboltype

local ImportResolver = oop.class()

function ImportResolver:__ctor(formattree)
  self.formattree = formattree
  self.optionalheader = formattree.NtHeaders.OptionalHeader
end

function ImportResolver:generateSymbols(symboltable, lib, thunkfield, suffix)
  local thunk = self.formattree[lib.name .. suffix]
  
  if thunk == nil then
    return
  end
  
  local imagebase = self.optionalheader.ImageBase.value
  
  for i = 0, thunk.fieldCount - 1 do
    local address = imagebase + thunkfield.value + (i * thunkfield.size)
    local name = lib.name .. "." .. thunk:field(i).name
    symboltable:set(address, SymbolType.Library, name)
  end
end

function ImportResolver:createImports(listing)
  local symboltable = listing.symboltable

  local importdirectory = self.formattree.ImportDirectory
  
  if importdirectory == nil then
    return
  end
  
  for i = 0, importdirectory.fieldCount - 1 do
    local lib = importdirectory:field(i)
    
    if lib.FirstThunk.value > 0 then
      self:generateSymbols(symboltable, lib, lib.FirstThunk, "_FT")
    end
    
    if lib.OriginalFirstThunk.value > 0 then
      self:generateSymbols(symboltable, lib, lib.OriginalFirstThunk, "_OFT")
    end
  end  
end

function ImportResolver:callName(fullname)
  local name = string.match(fullname, "%w+.(%a+)")
  return name and name or fullname
end

return ImportResolver
