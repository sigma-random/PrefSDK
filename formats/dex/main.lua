local DataType = require("sdk.types.datatype")
local FormatDefinition = require("sdk.format.formatdefinition")
local MapItemTypes = require("formats.dex.mapitemtypes")
local MapItemParser = require("formats.dex.mapitemparser")

local DexFormat = FormatDefinition.register("Dalvik Executable Format", "Android", "Dax", "1.0") 

function DexFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
  
  self.endianconstant = 0x12345678        -- Little Endian DEX
  self.reverseendianconstant = 0x78563412 -- Big Endian DEX
end

function DexFormat:validateFormat()
  self:checkData(0x00000000, DataType.AsciiString, "dex")
  self:checkData(0x00000003, DataType.UInt8, 0x0A)
  self:checkData(0x00000007, DataType.UInt8, 0x00)
end

function DexFormat:parseFormat(formattree)
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
  
  if headeritem.MapOffset:value() > 0 then
    self:parseMapList(formattree, headeritem.MapOffset)
  end
end

function DexFormat:displayDexInfo(headeritem)
  return string.format("Dex File v%s (%s)", string.match(headeritem.Magic:value(), "%d+"), self:displayEndian(headeritem.EndianTag))
end

function DexFormat:displayEndian(endiantag)
  local e = endiantag:value()
  
  if e == self.endianconstant then
    return "Little Endian"
  elseif e == self.reverseendianconstant then
    return "Big Endian"
  end
  
  return "Unknown"
end

function DexFormat:displayMapItemType(mapitem)
  local itemtype = MapItemTypes[tonumber(mapitem.Type:value())]
  return itemtype or "Unknown"
end

function DexFormat:parseMapList(formattree, mapoffset)
  local maplist = formattree:addStructure("MapList", mapoffset:value())
  maplist:addField(DataType.UInt32_LE, "Size")
  local list = maplist:addStructure("List")
  
  for i = 1, maplist.Size:value() do
    local mapitem = list:addStructure(string.format("MapItem_%d", i - 1)):dynamicInfo(DexFormat.displayMapItemType)
    mapitem:addField(DataType.UInt16_LE, "Type")
    mapitem:addField(DataType.UInt16_LE, "Unused")
    mapitem:addField(DataType.UInt32_LE, "Size")
    mapitem:addField(DataType.UInt32_LE, "Offset")
    
    local mapitemparser = MapItemParser(formattree, mapitem)
    mapitemparser:parseItem()
  end
end