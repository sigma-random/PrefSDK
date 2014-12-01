local pref = require("pref")
local MapItemTypes = require("formats.dex.mapitemtypes")
local MapItemParser = require("formats.dex.mapitemparser")

local DataType = pref.datatype
local DexFormat = pref.format.create("Dalvik Executable", "Android", "Dax", "1.0")

function DexFormat:validate(validator)
  validator:checkAscii(0x00000000, "dex")
  validator:checkType(0x00000003, 0x0A, DataType.UInt8)
  validator:checkType(0x00000007, 0x00, DataType.UInt8)
end

function DexFormat:parse(formattree)
  local headeritem = formattree:addStructure("HeaderItem"):dynamicInfo(DexFormat.displayDexInfo)
  headeritem:addField(DataType.Character, "Magic", 8)
  headeritem:addField(DataType.UInt32_LE, "Checksum")
  headeritem:addField(DataType.UInt8, "Signature", 20)
  headeritem:addField(DataType.UInt32_LE, "FileSize")
  headeritem:addField(DataType.UInt32_LE, "HeaderSize")
  headeritem:addField(DataType.UInt32_LE, "EndianTag"):dynamicInfo(DexFormat.displayEndian)
  headeritem:addField(DataType.UInt32_LE, "LinkSize")
  headeritem:addField(DataType.UInt32_LE, "LinkOffset")
  headeritem:addField(DataType.UInt32_LE, "MapOffset")
  headeritem:addField(DataType.UInt32_LE, "StringIDsSize")
  headeritem:addField(DataType.UInt32_LE, "StringIDsOffset")
  headeritem:addField(DataType.UInt32_LE, "TypeIDsSize")
  headeritem:addField(DataType.UInt32_LE, "TypeIDsOffset")
  headeritem:addField(DataType.UInt32_LE, "ProtoIDsSize")
  headeritem:addField(DataType.UInt32_LE, "ProtoIDsOffset")
  headeritem:addField(DataType.UInt32_LE, "FieldIDsSize")
  headeritem:addField(DataType.UInt32_LE, "FieldIDsOffset")
  headeritem:addField(DataType.UInt32_LE, "MethodIDsSize")
  headeritem:addField(DataType.UInt32_LE, "MethodIDsOffset")
  headeritem:addField(DataType.UInt32_LE, "ClassDefsSize")
  headeritem:addField(DataType.UInt32_LE, "ClassDefsOffset")
  headeritem:addField(DataType.UInt32_LE, "DataSize")
  headeritem:addField(DataType.UInt32_LE, "DataOffset")
  
  if headeritem.MapOffset.value > 0 then
    self:parseMapList(formattree, headeritem.MapOffset)
  end
end

function DexFormat:parseMapList(formattree, mapoffset)
  local maplist = formattree:addStructure("MapList", mapoffset.value)
  maplist:addField(pref.datatype.UInt32_LE, "Size")
  local list = maplist:addStructure("List")
  
  for i = 1, maplist.Size.value do
    local mapitem = list:addStructure(string.format("MapItem_%d", i - 1)):dynamicInfo(DexFormat.displayMapItemType)
    mapitem:addField(pref.datatype.UInt16_LE, "Type")
    mapitem:addField(pref.datatype.UInt16_LE, "Unused")
    mapitem:addField(pref.datatype.UInt32_LE, "Size")
    mapitem:addField(pref.datatype.UInt32_LE, "Offset")
    
    local mapitemparser = MapItemParser(formattree, mapitem)
    mapitemparser:parseItem()
  end
end

function DexFormat.displayEndian(endiantag)
  local e = endiantag.value
  
  if e == 0x12345678 then
    return "Little Endian"
  elseif e == 0x78563412 then
    return "Big Endian"
  end
  
  return "Unknown"
end

function DexFormat.displayDexInfo(headeritem)
  return string.format("Dex File v%s (%s)", string.match(headeritem.Magic.value, "%d+"), DexFormat.displayEndian(headeritem.EndianTag))
end

function DexFormat.displayMapItemType(mapitem)
  local itemtype = MapItemTypes[mapitem.Type.value]
  return itemtype or "Unknown"
end

return DexFormat