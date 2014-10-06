local pref = require("pref")
local INesFunctions = require("formats.ines.functions")

local INesFormat = pref.format.create("iNES Format", "Nintendo", "Dax", "1.0")

function INesFormat:validate(validator)
  validator:checkType(0, 0x1A53454E, pref.datatype.UInt32_LE) -- "'Nes^Z' Signature"
end

function INesFormat:parse(formattree)
  local inesheader = formattree:addStructure("INesHeader")
  inesheader:addField(pref.datatype.Character, "Signature", 4)
  inesheader:addField(pref.datatype.UInt8, "RomBanksCount"):dynamicInfo(INesFunctions.calcRomSize)
  inesheader:addField(pref.datatype.UInt8, "VRomBanksCount"):dynamicInfo(INesFunctions.calcVRomSize)
  
  local f_systemflags1 = inesheader:addField(pref.datatype.UInt8, "SystemFlags1")
  f_systemflags1:setBitField("Mirroring", 0):dynamicInfo(INesFunctions.getMirroring)
  f_systemflags1:setBitField("BatteryRAM", 1)
  f_systemflags1:setBitField("HasTrainers", 2)
  f_systemflags1:setBitField("FourScreenRAM", 3)
  f_systemflags1:setBitField("LowROMMapperType", 4, 7):dynamicInfo(INesFunctions.getMapperTypeFromLow)
  
  local f_systemflags2 = inesheader:addField(pref.datatype.UInt8, "SystemFlags2")
  f_systemflags2:setBitField("CartridgeType", 0)
  f_systemflags2:setBitField("Reserved", 1, 3)
  f_systemflags2:setBitField("HighROMMapperType", 4, 7):dynamicInfo(INesFunctions.getMapperTypeFromHigh)
  
  inesheader:addField(pref.datatype.UInt8, "RamBanksCount"):dynamicInfo(INesFunctions.calcRamSize)
  
  local f_screenflags = inesheader:addField(pref.datatype.UInt8, "ScreenFlags")
  f_screenflags:setBitField("TvSystem", 0):dynamicInfo(INesFunctions.getTvSystem)
  f_screenflags:setBitField("Reserved", 1, 7)
  
  local f_unofficialflags = inesheader:addField(pref.datatype.UInt32_LE, "UnofficialFlags")
  f_unofficialflags:setBitField("TvSystem", 0, 1)
  f_unofficialflags:setBitField("RamInCPU", 4)
  f_unofficialflags:setBitField("BusConflicts", 5)
  
  inesheader:addField(pref.datatype.UInt8, "Reserved", 2)
end

return INesFormat