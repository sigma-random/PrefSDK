local oop = require("sdk.lua.oop")

local MapItemParser = oop.class()

function MapItemParser:__ctor(formattree, mapitem)
  self.formattree = formattree
  self.mapitem = mapitem
  
  self.parseitemtable = { [0x0000] = MapItemParser.parseHeader,
                          [0x0001] = MapItemParser.parseStringID,
                          [0x0002] = MapItemParser.parseTypeID,
                          [0x0003] = MapItemParser.parseProtoID,
                          [0x0004] = MapItemParser.parseFieldID,
                          [0x0005] = MapItemParser.parseMethodID,
                          [0x0006] = MapItemParser.parseClassDefinition,
                          [0x1000] = MapItemParser.parseMapList,
                          [0x1001] = MapItemParser.parseTypeList,
                          [0x1002] = MapItemParser.parseAnnotationSetRef,
                          [0x1003] = MapItemParser.parseAnnotationSet,
                          [0x2000] = MapItemParser.parseClassData,
                          [0x2001] = MapItemParser.parseCode,
                          [0x2002] = MapItemParser.parseStringData,
                          [0x2003] = MapItemParser.parseDebugInfo,
                          [0x2004] = MapItemParser.parseAnnotation,
                          [0x2005] = MapItemParser.parseEncodedArray,
                          [0x2006] = MapItemParser.parseAnnotationDirectory }
end

function MapItemParser:parseHeader()
  -- Already parsed, do nothing
end

function MapItemParser:parseStringID()
end

function MapItemParser:parseTypeID()
end

function MapItemParser:parseProtoID()
end

function MapItemParser:parseFieldID()
end

function MapItemParser:parseMethodID()
end

function MapItemParser:parseClassDefinition()
end

function MapItemParser:parseMapList()
end

function MapItemParser:parseTypeList()
end

function MapItemParser:parseAnnotationSetRef()
end

function MapItemParser:parseAnnotationSet()
end

function MapItemParser:parseClassData()
end

function MapItemParser:parseCode()
end

function MapItemParser:parseStringData()
end

function MapItemParser:parseDebugInfo()
end

function MapItemParser:parseAnnotation()
end

function MapItemParser:parseEncodedArray()
end

function MapItemParser:parseAnnotationDirectory()
end

function MapItemParser:parseItem()
  local itemtype = self.mapitem.Type.value
  local parseproc = self.parseitemtable[itemtype]
  
  if parseproc then
    parseproc(self)
  else
    error(string.format("Invalid Map Item Type: %04X", itemtype))
  end  
end

return MapItemParser
