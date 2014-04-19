local FormatDefinition = require("sdk.format.formatdefinition")
local ByteOrder = require("sdk.types.byteorder")

local TimBpp = { [0] = "4-Bit CLUT", [1] = "8-Bit CLUT", [2] = "15-Bit Direct", [3] = "24-Bit Direct", [4] = "Mixed" } 
local TimFormat = FormatDefinition.register("TIM Format", "Sony Playstation 1", "Dax", "1.0")

function TimFormat:__ctor(databuffer)
  FormatDefinition.__ctor(self, databuffer)
end

function TimFormat:getBpp(bppfield)
  local bpp = TimBpp[bppfield:value()]
  
  if bpp ~= nil then
    return bpp
  end
  
  return "Unknown"
end

function TimFormat:validateFormat()
  local databuffer = self.databuffer
  local id = databuffer:readUInt32(0, ByteOrder.LittleEndian)
  
  if bit.band(id, 0xFF) ~= 0x10 then -- Id
    error("Invalid ID")
  end
  
  if bit.rshift(bit.band(id, 0xFF00), 8) ~= 0x00 then -- Version
    error("Invalid Version")
  end
  
  if bit.rshift(bit.band(id, 0xFFFF0000), 16) ~= 0x0000 then -- Reserved
    error("Reserved field must be 0")
  end
    
  local flag = databuffer:readUInt32(4, ByteOrder.LittleEndian)
  local bpp = bit.band(flag, 0x7)
  
  if (bpp < 0) or (bpp > 4) then -- Bpp
    error("Invalid BPP")
  end
  
  local hasclut = bit.rshift(bit.band(flag, 0x8), 3)
  
  if (hasclut ~= 0) and (hasclut ~= 1) then
    error("Invalid CLUT field")
  end
  
  if bit.rshift(bit.band(flag, 0xFFFFFFF0), 4) ~= 0x000000 then
    error("Upper part of FLAGS field must be 0")
  end
  
  local pixeldatapos = 8
  
  if hasclut == 1 then
    local clblksize = databuffer:readUInt32(8, ByteOrder.LittleEndian)
    local clfbx = databuffer:readUInt16(12, ByteOrder.LittleEndian)
    local clfby = databuffer:readUInt16(14, ByteOrder.LittleEndian)
    local clw = databuffer:readUInt16(16, ByteOrder.LittleEndian)
    local clh = databuffer:readUInt16(18, ByteOrder.LittleEndian)
    
    if ((clfbx < 0) or (clw < 0) or (clfby < 0) or (clh < 0)) or (clfbx >= clw) or (clfby >= clh) then
      error("Invalid TIM Metrics")
    end
    
    local clutelements = 0

    if bpp == 0 then -- 4-Bit CLUT
      clutelements = 16
    elseif bpp == 1 then -- 8-Bit CLUT
      clutelements = 256
    else
      error("Invalid CLUT Table Size")
    end
    
    -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
    local clutcount = (clblksize - 12) / (clutelements * 2)
    local clutsize = 0
    
    for i = 1, clutcount do
      clutsize = clutsize + (clutelements * 2)
    end
    
    if clutsize > databuffer:size() then
      error("CLUT's size cannot be greater than file size")
    end
    
    pixeldatapos = clutsize + 20
  end
  
  pixeldatapos = pixeldatapos + 4 -- Skip Pixel Block Size
  
  local pxfbx = databuffer:readUInt16(pixeldatapos, ByteOrder.LittleEndian)
  local pxfby = databuffer:readUInt16(pixeldatapos + 2, ByteOrder.LittleEndian)
  local pxw = databuffer:readUInt16(pixeldatapos + 4, ByteOrder.LittleEndian)
  local pxh = databuffer:readUInt16(pixeldatapos + 6, ByteOrder.LittleEndian)
  
  if ((pxfbx < 0) or (pxw < 0) or (pxfby < 0) or (pxh < 0)) or (pxfbx > pxw) or (pxfby > pxh) then
    error("Invalid Pixel Block Metrics")
  end
end
    
function TimFormat:parseFormat(formattree)
  local timheader = formattree:addStructure("TimHeader")
  
  local fid = timheader:addField(DataType.UInt32_LE, "Id")
  fid:setBitField("Id", 0, 7)
  fid:setBitField("Version", 8, 15)
  fid:setBitField("Reserved", 16, 31)
  
  local fflag = timheader:addField(DataType.UInt32_LE, "Flag")
  fflag:setBitField("Bpp", 0, 2):dynamicInfo(TimFormat.getBpp)
  fflag:setBitField("HasClut", 3)
  fflag:setBitField("Reserved", 4, 31)
  
  if timheader.Flag.HasClut:value() == 1 then
    self:createClutBlocks(formattree, timheader.Flag.Bpp:value())
  end
  
  local pixeldata = formattree:addStructure("PixelData")
  pixeldata:addField(DataType.UInt32_LE, "BlockSize")
  pixeldata:addField(DataType.UInt16_LE, "FrameBufferX")
  pixeldata:addField(DataType.UInt16_LE, "FrameBufferY")
  pixeldata:addField(DataType.UInt16_LE, "Width")
  pixeldata:addField(DataType.UInt16_LE, "Height")
  pixeldata:addField(DataType.Blob, "Pixel", pixeldata.BlockSize:value() - pixeldata:size())
end

function TimFormat:createClutBlocks(formattree, bpp)
  local clut = formattree:addStructure("Clut")
  clut:addField(DataType.UInt32_LE, "BlockSize")
  clut:addField(DataType.UInt16_LE, "FrameBufferX")
  clut:addField(DataType.UInt16_LE, "FrameBufferY")
  clut:addField(DataType.UInt16_LE, "Width")
  clut:addField(DataType.UInt16_LE, "Height")
  
  local clutelements = 0

  if bpp == 0 then -- 4-Bit CLUT
    clutelements = 16
  elseif bpp == 1 then -- 8-Bit CLUT
    clutelements = 256
  end
  
  -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
  local clutcount = (clut.BlockSize:value() - clut:size()) / (clutelements * 2)
  local colors = clut:addStructure("Colors")
  
  for i = 1, clutcount do
    colors:addField(DataType.Blob, "Clut" .. (i - 1), clutelements * 2)
  end
end