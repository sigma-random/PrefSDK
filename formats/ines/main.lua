local FormatDefinition = require("sdk.format.formatdefinition")
local MapperTypes = require("formats.ines.mappers")

local INesFormat = FormatDefinition:new("iNES Format", "Nintendo", "Dax", "1.0", Endian.LittleEndian)

function INesFormat.calcRomSize(formatobject, buffer)
  return string.format("%dKB", formatobject:value() * 16)
end

function INesFormat.calcVRomSize(formatobject, buffer)
  return string.format("%dKB", formatobject:value() * 8)
end

function INesFormat.calcRamSize(formatobject, buffer)
  local numbanks = formatobject:value()
  
  if numbanks == 0 then -- As Documentation Says: "Assume 1x8KB RAM if `numbanks` is zero"
    numbanks = 1
  end
  
  return string.format("%dKB", numbanks * 8)
end

function INesFormat.getMapperTypeFromLow(formatobject, buffer)
  local lowpart = formatobject:value()
  local highpart = formatobject:model().INesHeader.SystemFlags2.HighROMMapperType:value()
  local mt = bit.bor(bit.lshift(highpart, 4), lowpart)
  return MapperTypes[mt]
end

function INesFormat.getMapperTypeFromHigh(formatobject, buffer)
  local highpart = formatobject:value()
  local lowpart = formatobject:model().INesHeader.SystemFlags1.LowROMMapperType:value()
  local mt = bit.bor(bit.lshift(highpart, 4), lowpart)
  return MapperTypes[mt]
end

function INesFormat.getTvSystem(formatobject, buffer)  
  if formatobject:value() == 1 then
    return "PAL"
  end
  
  return "NTSC"
end

function INesFormat.getMirroring(formatobject, buffer)
  local mirroring = formatobject:value()
  
  if mirroring == 1 then
    return "Vertical"
  end
    
  return "Horizontal"
end

function INesFormat:validateFormat(buffer)
  return false
end

function INesFormat:parseFormat(formatmodel, buffer)
  local inesheader = formatmodel:addStructure("INesHeader")
  inesheader:addField(DataType.Char, 4, "Signature")
  inesheader:addField(DataType.UInt8, "RomBanksCount"):dynamicInfo(INesFormat.calcRomSize)
  inesheader:addField(DataType.UInt8, "VRomBanksCount"):dynamicInfo(INesFormat.calcVRomSize)
  
  local f_systemflags1 = inesheader:addField(DataType.UInt8, "SystemFlags1")
  f_systemflags1:setBitField(0, "Mirroring"):dynamicInfo(INesFormat.getMirroring)
  f_systemflags1:setBitField(1, "BatteryRAM")
  f_systemflags1:setBitField(2, "HasTrainers")
  f_systemflags1:setBitField(3, "FourScreenRAM")
  f_systemflags1:setBitField(4, 7, "LowROMMapperType"):dynamicInfo(INesFormat.getMapperTypeFromLow)
  
  local f_systemflags2 = inesheader:addField(DataType.UInt8, "SystemFlags2")
  f_systemflags2:setBitField(0, "CartridgeType")
  f_systemflags2:setBitField(1, 3, "Reserved")
  f_systemflags2:setBitField(4, 7, "HighROMMapperType"):dynamicInfo(INesFormat.getMapperTypeFromHigh)
  
  inesheader:addField(DataType.UInt8, "RamBanksCount"):dynamicInfo(INesFormat.calcRamSize)
  
  local f_screenflags = inesheader:addField(DataType.UInt8, "ScreenFlags")
  f_screenflags:setBitField(0, "TvSystem"):dynamicInfo(INesFormat.getTvSystem)
  f_screenflags:setBitField(1, 7, "Reserved")
  
  local f_unofficialflags = inesheader:addField(DataType.UInt32, "UnofficialFlags")
  f_unofficialflags:setBitField(0, 1, "TvSystem")
  f_unofficialflags:setBitField(4, "RamInCPU")
  f_unofficialflags:setBitField(5, "BusConflicts")
  
  inesheader:addField(DataType.UInt8, 2, "Reserved")
end