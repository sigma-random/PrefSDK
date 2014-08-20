require("sdk.strict")
require("sdk.lua.table") -- Add Table Enhancements
local ffi = require("ffi")
local DataType = require("sdk.types.datatype")
local DataBuffer = require("sdk.io.databuffer")

ffi.cdef
[[
  typedef const char* LoaderId;
  
  void Pref_setSdkVersion(int8_t major, int8_t minor, int8_t revision, const char* custom);
  
  void Debug_showDialog(const char* s);
  
  void* QHexEditData_createReader(void* __this);
  void* QHexEditData_createWriter(void* __this);
  void QHexEditData_copyTo(void* __this, void* hexeditdata, int64_t start, int64_t end);
  int64_t QHexEditData_length(void* __this);
  int64_t QHexEditDataReader_indexOf(void* __this, int64_t pos, const char* s);
  char QHexEditDataReader_readAsciiChar(void* __this, int64_t pos);
  const char* QHexEditDataReader_readString(void* __this, int64_t pos, int64_t len);
  const char* QHexEditDataReader_readLine(void* __this, int64_t pos);
  uint8_t QHexEditDataReader_readUInt8(void* __this, uint64_t pos);
  uint16_t QHexEditDataReader_readUInt16(void* __this, uint64_t pos, int endian);
  uint32_t QHexEditDataReader_readUInt32(void* __this, uint64_t pos, int endian);
  uint64_t QHexEditDataReader_readUInt64(void* __this, uint64_t pos, int endian);
  int8_t QHexEditDataReader_readInt8(void* __this, uint64_t pos);
  int16_t QHexEditDataReader_readInt16(void* __this, uint64_t pos, int endian);
  int32_t QHexEditDataReader_readInt32(void* __this, uint64_t pos, int endian);
  int64_t QHexEditDataReader_readInt64(void* __this, uint64_t pos, int endian);
  
  void LoaderModel_setValid(void* __this, LoaderId loaderid);
]]

local C = ffi.C
local FormatTree = require("sdk.format.formattree")
local DisassemblerListing = require("sdk.disassembler.disassemblerlisting")

-- Notify PrefSDK's version.
C.Pref_setSdkVersion(1, 5, 0, nil)

-- This table store the SDK's state and it is available everywhere.
Sdk = { formatlist = { },
        loadedformats = { },
        loaderlist = { },
        exporterlist = { } }

function Sdk.parseFormat(formatid, baseoffset, databuffer, cformattree)
  local formattype = Sdk.formatlist[formatid] -- Get Format's Type from list.
  local buffer = DataBuffer(databuffer, baseoffset)
  local f = formattype(buffer) -- Create a format's instance
  
  for k, v in pairs(f.options) do
    C.Format_registerOption(databuffer, k, v.name)
  end
  
  f:validate()
  f.tree = FormatTree(cformattree, buffer)
  Sdk.loadedformats[databuffer] = f
  f:parse(f.tree)
end

function Sdk.validateLoaders(loadermodel, databuffer)
  local buffer = DataBuffer(databuffer)
  
  for k, v in pairs(Sdk.loaderlist) do
    local l = v(nil, buffer) -- Test Loader
    
    if l.validated then
      C.LoaderModel_setValid(loadermodel, k)
    end
  end
end

function Sdk.disassembleData(clisting, databuffer, loaderid)
  local errorhandler = function(loader, msg)
    local currentinstr = loader.listing.currentinstruction

    if currentinstr then
      Sdk.errorDialog(string.format("Disassembler in panic state: %s\n  Current Address: %X\n  Last Instruction: '%s' (Address %X, %d Operands)\n", 
                      msg, loader.listing.currentaddress, currentinstr.mnemonic, currentinstr.address, #currentinstr.operands)) 
    else
      Sdk.errorDialog("Disassembler in panic state: " .. msg .. "\n")
    end
  end
  
  local loadertype = Sdk.loaderlist[loaderid]
  local l = loadertype(DisassemblerListing(clisting), DataBuffer(databuffer))
  local res, msg = pcall(l.disassemble, l)
  
  if res == false then
    errorhandler(l, msg)
  end
end

function Sdk.parseDynamic(elementid, databuffer)
  local f = Sdk.loadedformats[databuffer]
  
  if f.dynamicelements[elementid] then
    local dynamicelement = f.dynamicelements[elementid]
    dynamicelement.parseprocedure(f, dynamicelement.element)
  end
end

function Sdk.executeOption(optionidx, databuffer, startoffset, endoffset)
  local f = Sdk.loadedformats[databuffer]
  
  if f.options[optionidx] then
    local option = f.options[optionidx]
    local buffer = f.databuffer
    option.action(f, buffer.baseoffset + startoffset, buffer.baseoffset + endoffset)
  end
end

function Sdk.getFormatElementInfo(elementid, databuffer)
  local f = Sdk.loadedformats[databuffer]
  
  if f.elementsinfo[elementid] then
    local elementinfo = f.elementsinfo[elementid]
    return elementinfo.infoprocedure(f, elementinfo.element)
  end
  
  return ""
end

function Sdk.exportData(exporterid, databufferin, databufferout, startoffset, endoffset)
  local exportertype = Sdk.exporterlist[exporterid]
  local exporter = exportertype()
  exporter:exportData(DataBuffer(databufferin), DataBuffer(databufferout), startoffset, endoffset)
end

function Sdk.errorDialog(obj)
  if type(obj) == "string" then
    C.Debug_showDialog(obj)
  elseif type(obj) == "number" then
    C.Debug_showDialog(tostring(obj))
  elseif type(obj) == "table" then
    local tableoutput = "Table:\n"
    
    for k,v in pairs(obj) do
      tableoutput = tableoutput .. string.format("%s = %s", k, v)
    end
    
    C.Debug_showDialog(tableoutput)
  else
    C.Debug_showDialog("Unupported Type: '" .. type(obj) .. "'")
  end
end