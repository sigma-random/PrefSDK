require("sdk.strict")
local ffi = require("ffi")
local DataBuffer = require("sdk.io.databuffer")

ffi.cdef
[[  
  void Pref_setSdkVersion(int8_t major, int8_t minor, int8_t revision, const char* custom);
  
  void Debug_print(const char* s);
  void Debug_println(const char* s);
  void Debug_showDialog();
  
  void QHexEditData_copyTo(void* __this, void* hexeditdata);
  int64_t QHexEditData_indexOf(void* __this, int64_t pos, const char* s);
  int64_t QHexEditData_length(void* __this);
  char QHexEditData_readAsciiChar(void* __this, int64_t pos);
  const char* QHexEditData_readString(void* __this, int64_t pos, int64_t len);
  const char* QHexEditData_readLine(void* __this, int64_t pos);
  uint8_t QHexEditData_readUInt8(void* __this, uint64_t pos);
  uint16_t QHexEditData_readUInt16(void* __this, uint64_t pos, int endian);
  uint32_t QHexEditData_readUInt32(void* __this, uint64_t pos, int endian);
  uint64_t QHexEditData_readUInt64(void* __this, uint64_t pos, int endian);
  int8_t QHexEditData_readInt8(void* __this, uint64_t pos);
  int16_t QHexEditData_readInt16(void* __this, uint64_t pos, int endian);
  int32_t QHexEditData_readInt32(void* __this, uint64_t pos, int endian);
  int64_t QHexEditData_readInt64(void* __this, uint64_t pos, int endian);
]]

local C = ffi.C
local FormatTree = require("sdk.format.formattree")

-- Notify PrefSDK's version.
C.Pref_setSdkVersion(1, 5, 0, nil)

-- This table store the SDK's state and it is available everywhere.
Sdk = { formatlist = { },
        loadedformats = { },
        exporterlist = { } }

function Sdk.parseFormat(formatid, baseoffset, databuffer, cformattree)
  local formattype = Sdk.formatlist[formatid] -- Get Format's Type from list.
  local f = formattype(databuffer, baseoffset) -- Create a format's instance
  
  f:validateFormat()
  
  if f.validated then
    f.formattree = FormatTree(cformattree, databuffer)
    Sdk.loadedformats[databuffer] = f
    f:parseFormat(f.formattree)
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
    option.action(f, startoffset, endoffset)
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

function Sdk.dbgprint(obj, showdialog)
  if type(obj) == "string" then
    C.Debug_print(obj)
  elseif type(obj) == "number" then
    C.Debug_print(tostring(obj))
  elseif type(obj) == "table" then
    C.Debug_println("Table:")
    
    for k,v in pairs(obj) do
      C.Debug_println(string.format("%s = %s", k, v))
    end
  end
  
  if showdialog == nil or showdialog == true then
    C.Debug_showDialog()
  end
end