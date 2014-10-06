local MapItemTypes = require("formats.dex.mapitemtypes")
local MapItemParser = require("formats.dex.mapitemparser")

local DexFunctions = { }

function DexFunctions.displayEndian(endiantag, formattree)
  local e = endiantag.value
  
  if e == 0x12345678 then
    return "Little Endian"
  elseif e == 0x78563412 then
    return "Big Endian"
  end
  
  return "Unknown"
end

function DexFunctions.displayDexInfo(headeritem, formattree)
  return string.format("Dex File v%s (%s)", string.match(headeritem.Magic.value, "%d+"), DexFunctions.displayEndian(headeritem.EndianTag))
end

function DexFunctions.displayMapItemType(mapitem, formattree)
  local itemtype = MapItemTypes[mapitem.Type.value]
  return itemtype or "Unknown"
end

function DexFunctions.parseMapList(formattree, mapoffset)
  local maplist = formattree:addStructure("MapList", mapoffset.value)
  maplist:addField(pref.datatype.UInt32_LE, "Size")
  local list = maplist:addStructure("List")
  
  for i = 1, maplist.Size.value do
    local mapitem = list:addStructure(string.format("MapItem_%d", i - 1)):dynamicInfo(DexFunctions.displayMapItemType)
    mapitem:addField(pref.datatype.UInt16_LE, "Type")
    mapitem:addField(pref.datatype.UInt16_LE, "Unused")
    mapitem:addField(pref.datatype.UInt32_LE, "Size")
    mapitem:addField(pref.datatype.UInt32_LE, "Offset")
    
    local mapitemparser = MapItemParser(formattree, mapitem)
    mapitemparser:parseItem()
  end
end


return DexFunctions
