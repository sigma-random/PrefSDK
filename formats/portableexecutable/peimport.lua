local PeDefs = require("formats.portableexecutable.pedefs")
local Pointer = require("sdk.math.pointer")

local PeImport = { }

function PeImport.descriptorName(descriptor, buffer)
  local offset = rebaseaddress(descriptor.Name:value(), descriptor.sectionheader.VirtualAddress:value(), descriptor.sectionheader.PointerToRawData:value())
  return buffer:readString(offset)
end

function PeImport.getDescriptorName(formatobject, buffer)
  return PeImport.descriptorName(formatobject:parent(), buffer)
end

function PeImport.getThunkName(formatobject, buffer)
  local sectionheader = formatobject:parent().sectionheader
  local pordinal = Pointer.new(rebaseaddress(formatobject:value(), sectionheader.VirtualAddress:value(), sectionheader.PointerToRawData:value()), DataType.UInt16, buffer)
  local name = buffer:readString(pordinal.value + DataType.sizeOf(DataType.UInt16))
  
  if pordinal[0] ~= 0 then
    return string.format("%s (Ordinal: %04X)", name, pordinal[0])
  end
  
  return name
end

function PeImport.createThunkData(tt, section, descriptor, rva, buffer)
  local i = 0
  local name = PeImport.descriptorName(descriptor, buffer)
  local pthunk = Pointer:new(rebaseaddress(rva, descriptor.sectionheader.VirtualAddress:value(), descriptor.sectionheader.PointerToRawData:value()), DataType.UInt32, buffer)
  
  local thunk = section:addStructure(string.format("Import_%s_%s_%X", name:match("%w+"), tt, rva), pthunk.value)
  thunk.sectionheader = descriptor.sectionheader
    
  while pthunk[i] ~= 0 do
    thunk:addField(DataType.UInt32, string.format("Thunk%X", pthunk[i])):dynamicInfo(PeImport.getThunkName)
    i = i + 1
  end
end

return PeImport