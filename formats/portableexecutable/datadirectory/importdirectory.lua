local oop = require("sdk.lua.oop")
local Address = require("sdk.math.address")
local Pointer = require("sdk.math.pointer")
local DataType = require("sdk.types.datatype")
local PeConstants = require("formats.portableexecutable.peconstants")

local ImportDirectory = oop.class()

function ImportDirectory:__ctor(databuffer, formattree, section, directoryoffset)
  self.databuffer = databuffer
  self.formattree = formattree
  self.section = section
  self.directoryoffset = directoryoffset
end

function ImportDirectory:getModuleName(descriptoroffset)
  local namerva = self.databuffer:readType(descriptoroffset + 0x0C, DataType.UInt32_LE)
  local nameoffset = Address.rebase(namerva, self.section.VirtualAddress:value(), self.section.PointerToRawData:value())
  local modulename = string.upper(self.databuffer:readString(nameoffset))
  return string.gsub(modulename, "%.DLL", "") -- Remove '.DLL' suffix
end

function ImportDirectory:getImportName(thunkdata)
  if bit.band(thunkdata, PeConstants.ImageOrdinalFlag[32]) ~= 0 then -- Function imported by Ordinal
    return string.format("Ordinal#%04X", bit.bxor(thunkdata, PeConstants.ImageOrdinalFlag[32]))
  end
  
  -- Function Imported by Name
  local thunkdataoffset = Address.rebase(thunkdata, self.section.VirtualAddress:value(), self.section.PointerToRawData:value())
  return self.databuffer:readString(thunkdataoffset + DataType.sizeOf(DataType.UInt16_LE)) -- Skip Ordinal
end

function ImportDirectory:parseOFT(oftrva, modulename)
  if oftrva == 0 then
    return
  end
  
  local oftoffset = Address.rebase(oftrva, self.section.VirtualAddress:value(), self.section.PointerToRawData:value())  
  local thunkstruct = self.formattree:addStructure(string.format("%s_OFT", modulename), oftoffset)
  self:parseThunk(thunkstruct, oftoffset)
end

function ImportDirectory:parseFT(ftrva, modulename)
  if ftrva == 0 then
    return
  end
  
  local ftoffset = Address.rebase(ftrva, self.section.VirtualAddress:value(), self.section.PointerToRawData:value())  
  local thunkstruct = self.formattree:addStructure(string.format("%s_FT", modulename), ftoffset)
  self:parseThunk(thunkstruct, ftoffset)
end

function ImportDirectory:parseThunk(thunkstruct, thunkoffset)
  local i = 0
  local pthunk = Pointer(thunkoffset, DataType.UInt32_LE, self.databuffer)
  
  while pthunk[i] ~= 0 do
    local importname = self:getImportName(pthunk[i])
    thunkstruct:addField(DataType.UInt32_LE, importname)
    i = i + 1
  end
end

function ImportDirectory:parse()
  local databuffer = self.databuffer
  local importdirectory = self.formattree:addStructure(PeConstants.DirectoryNames[2], self.directoryoffset) 
  
  local offset = self.directoryoffset
  local oft = databuffer:readType(offset, DataType.UInt32_LE)
  local ft = databuffer:readType(offset + 0x10, DataType.UInt32_LE)
  
  while (oft ~= 0) or (ft ~= 0) do
    local modulename = self:getModuleName(offset)
    local descriptor = importdirectory:addStructure(modulename)
    descriptor:addField(DataType.UInt32_LE, "OriginalFirstThunk")
    descriptor:addField(DataType.UInt32_LE, "TimeDateStamp")
    descriptor:addField(DataType.UInt32_LE, "ForwaredChain")
    descriptor:addField(DataType.UInt32_LE, "Name")
    descriptor:addField(DataType.UInt32_LE, "FirstThunk")
    
    self:parseOFT(oft, modulename)
    self:parseFT(ft, modulename)
    
    offset = offset + descriptor:size()
    oft = databuffer:readType(offset, DataType.UInt32_LE)
    ft = databuffer:readType(offset + 0x10, DataType.UInt32_LE)
  end
end

return ImportDirectory
