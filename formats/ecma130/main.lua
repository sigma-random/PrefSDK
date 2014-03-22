local FormatDefinition = require("sdk.format.formatdefinition")

local Ecma130Format = FormatDefinition:new("ECMA-130 Format", "File System", "Dax", "1.0", Endian.PlatformEndian)

function getSectorType(formatobject, buffer)
  
end

function Ecma130Format:sectorToOffset(sector)
  return sector * SectorSize
end

function Ecma130Format:createSector(offset, sectoridx, formatmodel)
  local sector = formatmodel:addStructure(string.format("Sector%X", sectoridx))
  sector:addField(DataType.UInt8, "Sync", 12)
  
  local header = sector:addStructure("Header")
  header:addField(DataType.UInt8, "Address", 3)
  header:addField(DataType.UInt8, "Mode")
  local mode = header.Mode:value()
 
  if (mode == 0) or (mode == 2) then
    self:createSectorMode00_02(sector)
  elseif mode == 1 then
    self:createSectorMode01(sector)
  else
    error("Unknown Sector Mode")
  end
  
  sector:addField(DataType.UInt8, "F1-Frames", 24)
  sector:addField(DataType.UInt8, "F2-Frames", 24)
  sector:addField(DataType.UInt8, "F3-Frames", 24)
  sector:addField(DataType.UInt8, "Boh", 24)
  
  return offset + sector:size()
end

function Ecma130Format:createSectorMode00_02(sector)
  sector:addField(DataType.Blob, "UserData", 2336)
end

function Ecma130Format:createSectorMode01(sector)
  sector:addField(DataType.Blob, "UserData", 2048)
  sector:addField(DataType.UInt32, "EDC")
  sector:addField(DataType.UInt8, "Intermediate", 8)
  sector:addField(DataType.UInt8, "P-Parity", 172)
  sector:addField(DataType.UInt8, "P-Parity", 104)
end

function Ecma130Format:validateFormat(formatmodel, buffer)
  return false
end

function Ecma130Format:parseFormat(formatmodel, buffer)
  local offset = 0
  local sectoridx = 0
  
  while sectoridx < 20 do
    offset = self:createSector(offset, sectoridx, formatmodel)
    sectoridx = sectoridx + 1
  end
end