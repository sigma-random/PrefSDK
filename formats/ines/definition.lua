local oop = require("sdk.lua.oop")
local FormatDefinition = require("sdk.format.formatdefinition")
local DataType = require("sdk.types.datatype")
local MapperTypes = require("formats.ines.mappers")

local INesFormat = oop.class(FormatDefinition)

function INesFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function INesFormat:calcRomSize(romfield)
  return string.format("%dKB", romfield:value() * 16)
end

function INesFormat:calcVRomSize(vromfield)
  return string.format("%dKB", vromfield:value() * 8)
end

function INesFormat:calcRamSize(ramfield)
  local numbanks = ramfield:value()
  
  if numbanks == 0 then -- As Documentation Says: "Assume 1x8KB RAM if `numbanks` is zero"
    numbanks = 1
  end
  
  return string.format("%dKB", numbanks * 8)
end

function INesFormat:getMapperTypeFromLow(mappertypelowfield)
  local lowpart = mappertypelowfield:value()
  local highpart = self.tree.INesHeader.SystemFlags2.HighROMMapperType:value()
  local mt = bit.bor(bit.lshift(highpart, 4), lowpart)
  return MapperTypes[mt]
end

function INesFormat:getMapperTypeFromHigh(mappertypehighfield)
  local highpart = mappertypehighfield:value()
  local lowpart = self.tree.INesHeader.SystemFlags1.LowROMMapperType:value()
  local mt = bit.bor(bit.lshift(highpart, 4), lowpart)
  return MapperTypes[mt]
end

function INesFormat:getTvSystem(tvsystemfield)  
  if tvsystemfield:value() == 1 then
    return "PAL"
  end
  
  return "NTSC"
end

function INesFormat:getMirroring(mirroringfield)  
  if mirroringfield:value() == 1 then
    return "Vertical"
  end
    
  return "Horizontal"
end

function INesFormat:validate()
  self:checkData(0, DataType.UInt32_LE, 0x1A53454E) -- "'Nes^Z' Signature"
end

function INesFormat:parse(formattree)
  local inesheader = formattree:addStructure("INesHeader")
  inesheader:addField(DataType.Character, "Signature", 4)
  inesheader:addField(DataType.UInt8, "RomBanksCount"):dynamicInfo(INesFormat.calcRomSize)
  inesheader:addField(DataType.UInt8, "VRomBanksCount"):dynamicInfo(INesFormat.calcVRomSize)
  
  local f_systemflags1 = inesheader:addField(DataType.UInt8, "SystemFlags1")
  f_systemflags1:setBitField("Mirroring", 0):dynamicInfo(INesFormat.getMirroring)
  f_systemflags1:setBitField("BatteryRAM", 1)
  f_systemflags1:setBitField("HasTrainers", 2)
  f_systemflags1:setBitField("FourScreenRAM", 3)
  f_systemflags1:setBitField("LowROMMapperType", 4, 7):dynamicInfo(INesFormat.getMapperTypeFromLow)
  
  local f_systemflags2 = inesheader:addField(DataType.UInt8, "SystemFlags2")
  f_systemflags2:setBitField("CartridgeType", 0)
  f_systemflags2:setBitField("Reserved", 1, 3)
  f_systemflags2:setBitField("HighROMMapperType", 4, 7):dynamicInfo(INesFormat.getMapperTypeFromHigh)
  
  inesheader:addField(DataType.UInt8, "RamBanksCount"):dynamicInfo(INesFormat.calcRamSize)
  
  local f_screenflags = inesheader:addField(DataType.UInt8, "ScreenFlags")
  f_screenflags:setBitField("TvSystem", 0):dynamicInfo(INesFormat.getTvSystem)
  f_screenflags:setBitField("Reserved", 1, 7)
  
  local f_unofficialflags = inesheader:addField(DataType.UInt32_LE, "UnofficialFlags")
  f_unofficialflags:setBitField("TvSystem", 0, 1)
  f_unofficialflags:setBitField("RamInCPU", 4)
  f_unofficialflags:setBitField("BusConflicts", 5)
  
  inesheader:addField(DataType.UInt8, "Reserved", 2)
end

return INesFormat