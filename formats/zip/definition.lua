local pref = require("pref")
local ZipFunctions = require("formats.zip.functions")

local ZipFormat = pref.format.create("Zip Format", "Compression", "Dax", "1.0")

function ZipFormat:validate(validator)
  validator:checkType(0, 0x04034B50, pref.datatype.UInt32_LE)
end
    
function ZipFormat:parse(formattree)  
  local pos, buffer = 0, formattree.buffer
  
  while pos < buffer.length do
    local tag = buffer:readType(pos, pref.datatype.UInt32_LE)
    
    if tag == 0x04034B50 then
      pos = pos + ZipFunctions.defineFileRecord(formattree)
    elseif tag == 0x08074b50 then
      pos = pos + ZipFunctions.defineDataDescriptor(formattree)
    elseif tag == 0x02014b50 then
      pos = pos + ZipFunctions.defineDirEntry(formattree)
    elseif tag == 0x05054b50 then
      pos = pos + ZipFunctions.defineDigitalSignature(formattree)
    elseif tag == 0x06054b50 then
      pos = pos + ZipFunctions.defineEndLocator(formattree)
    else
      self:error("Unknown Tag")
      return
    end
  end
end

return ZipFormat