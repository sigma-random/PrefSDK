local FormatDefinition = require("sdk.format.formatdefinition")

local Ecma130Format = FormatDefinition:new("ECMA-130 Format", "File System", "Dax", "1.0", Endian.PlatformEndian)

function getSectorType(formatobject, buffer)
  
end

function Ecma130Format:sectorToOffset(sector)
  return sector * SectorSize
end

function Ecma130Format:createSector(offset, sectoridx, formatmodel)
  local sector = formatmodel:addStructure(string.format("Sector%X", sectoridx))
  sector:addField(DataType.UInt8, 12, "Sync")
  
  local header = sector:addStructure("Header")
  header:addField(DataType.UInt8, 3, "Address")
  header:addField(DataType.UInt8, "Mode")
  local mode = header.Mode:value()
 
  if (mode == 0) or (mode == 2) then
    self:createSectorMode00_02(sector)
  elseif mode == 1 then
    self:createSectorMode01(sector)
  else
    error("Unknown Sector Mode")
  end
  
  sector:addField(DataType.UInt8, 24, "F1-Frames")
  sector:addField(DataType.UInt8, 24, "F2-Frames")
  sector:addField(DataType.UInt8, 24, "F3-Frames")
  sector:addField(DataType.UInt8, 24, "Boh")
  
  return offset + sector:size()
end

function Ecma130Format:createSectorMode00_02(sector)
  sector:addField(DataType.Blob, 2336, "UserData")
end

function Ecma130Format:createSectorMode01(sector)
  sector:addField(DataType.Blob, 2048, "UserData")
  sector:addField(DataType.UInt32, "EDC")
  sector:addField(DataType.UInt8, 8, "Intermediate")
  sector:addField(DataType.UInt8, 172, "P-Parity")
  sector:addField(DataType.UInt8, 104, "P-Parity")
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