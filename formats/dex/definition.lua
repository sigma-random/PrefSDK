local pref = require("pref")
local DexFunctions = require("formats.dex.functions")

local DexFormat = pref.format.create("Dalvik Executable Format", "Android", "Dax", "1.0")

function DexFormat:validate(validator)
  validator:checkAscii(0x00000000, "dex")
  validator:checkType(0x00000003, 0x0A, pref.datatype.UInt8)
  validator:checkType(0x00000007, 0x00, pref.datatype.UInt8)
end

function DexFormat:parse(formattree)
  local headeritem = formattree:addStructure("HeaderItem"):dynamicInfo(DexFunctions.displayDexInfo)
  headeritem:addField(pref.datatype.Character, "Magic", 8)
  headeritem:addField(pref.datatype.UInt32_LE, "Checksum")
  headeritem:addField(pref.datatype.UInt8, "Signature", 20)
  headeritem:addField(pref.datatype.UInt32_LE, "FileSize")
  headeritem:addField(pref.datatype.UInt32_LE, "HeaderSize")
  headeritem:addField(pref.datatype.UInt32_LE, "EndianTag"):dynamicInfo(DexFunctions.displayEndian)
  headeritem:addField(pref.datatype.UInt32_LE, "LinkSize")
  headeritem:addField(pref.datatype.UInt32_LE, "LinkOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "MapOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "StringIDsSize")
  headeritem:addField(pref.datatype.UInt32_LE, "StringIDsOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "TypeIDsSize")
  headeritem:addField(pref.datatype.UInt32_LE, "TypeIDsOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "ProtoIDsSize")
  headeritem:addField(pref.datatype.UInt32_LE, "ProtoIDsOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "FieldIDsSize")
  headeritem:addField(pref.datatype.UInt32_LE, "FieldIDsOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "MethodIDsSize")
  headeritem:addField(pref.datatype.UInt32_LE, "MethodIDsOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "ClassDefsSize")
  headeritem:addField(pref.datatype.UInt32_LE, "ClassDefsOffset")
  headeritem:addField(pref.datatype.UInt32_LE, "DataSize")
  headeritem:addField(pref.datatype.UInt32_LE, "DataOffset")
  
  if headeritem.MapOffset.value > 0 then
    DexFunctions.parseMapList(formattree, headeritem.MapOffset)
  end
end

return DexFormat