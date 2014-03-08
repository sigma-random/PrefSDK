require("sdk.math.address")
local Pointer = require("sdk.math.pointer")

local PeExport = { }

function PeExport.getFunctionNameAndOrdinal(functionep, buffer)
  local exporttable = functionep.exporttable
  local pnames = Pointer.new(rebaseaddress(exporttable.AddressOfNames:value(), exporttable.sectionheader.VirtualAddress:value(), exporttable.sectionheader.PointerToRawData:value()), DataType.UInt32, buffer)
  local pnamesord = Pointer.new(rebaseaddress(exporttable.AddressOfNameOrdinals:value(), exporttable.sectionheader.VirtualAddress:value(), exporttable.sectionheader.PointerToRawData:value()), DataType.UInt16, buffer)
  local ordinal = exporttable.Base:value() + functionep.funcindex
  
  for i = 0, exporttable.NumberOfNames:value() - 1 do    
    if pnamesord[i] == functionep.funcindex then
      local n = rebaseaddress(pnames[i], exporttable.sectionheader.VirtualAddress:value(), exporttable.sectionheader.PointerToRawData:value())
      return string.format("%s (Ordinal %04X)", buffer:readString(n), ordinal)
    end
  end
  
  return string.format("Ordinal %04X", ordinal)
end

function PeExport.createExportedFunctions(section, exporttable, buffer)
  local pep = Pointer.new(rebaseaddress(exporttable.AddressOfFunctions:value(), exporttable.sectionheader.VirtualAddress:value(), exporttable.sectionheader.PointerToRawData:value()), DataType.UInt32, buffer)
  
  for i = 0, exporttable.NumberOfFunctions:value() - 1 do
    local ep = pep[i]
    
    if ep ~= 0 then
      local f_funcep = section:addField(DataType.UInt32, string.format("ExportedFunction_%X", ep))
      f_funcep.exporttable = exporttable
      f_funcep.funcindex = i
      f_funcep:dynamicInfo(PeExport.getFunctionNameAndOrdinal)
    end
  end
end

return PeExport