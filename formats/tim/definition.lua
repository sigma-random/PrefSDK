local pref = require("pref")
local TimFunctions = require("formats.tim.functions")

local TimFormat = pref.format.create("TIM Format", "Sony Playstation 1", "Dax", "1.0")

function TimFormat:validate(validator)
  local buffer = validator.buffer
  local id = buffer:readType(0, pref.datatype.UInt32_LE)
  
  if bit.band(id, 0xFF) ~= 0x10 then -- Id
    validator:error("Invalid ID")
  end
  
  if bit.rshift(bit.band(id, 0xFF00), 8) ~= 0x00 then -- Version
    validator:error("Invalid Version")
  end
  
  if bit.rshift(bit.band(id, 0xFFFF0000), 16) ~= 0x0000 then -- Reserved
    validator:error("Reserved field must be 0")
  end
    
  local flag = buffer:readType(4, pref.datatype.UInt32_LE)
  local bpp = bit.band(flag, 0x7)
  
  if (bpp < 0) or (bpp > 4) then -- Bpp
    validator:error("Invalid BPP")
  end
  
  local hasclut = bit.rshift(bit.band(flag, 0x8), 3)
  
  if (hasclut ~= 0) and (hasclut ~= 1) then
    validator:error("Invalid CLUT field")
  end
  
  if bit.rshift(bit.band(flag, 0xFFFFFFF0), 4) ~= 0x000000 then
    validator:error("Upper part of FLAGS field must be 0")
  end
  
  local pixeldatapos = 8
  
  if hasclut == 1 then
    local clblksize = buffer:readType(8, pref.datatype.UInt32_LE)
    local clfbx = buffer:readType(12, pref.datatype.UInt16_LE)
    local clfby = buffer:readType(14, pref.datatype.UInt16_LE)
    local clw = buffer:readType(16, pref.datatype.UInt16_LE)
    local clh = buffer:readType(18, pref.datatype.UInt16_LE)
    
    if ((clfbx < 0) or (clw < 0) or (clfby < 0) or (clh < 0)) or (clfbx >= clw) or (clfby >= clh) then
      validator:error("Invalid TIM Metrics")
    end
    
    local clutelements = 0

    if bpp == 0 then -- 4-Bit CLUT
      clutelements = 16
    elseif bpp == 1 then -- 8-Bit CLUT
      clutelements = 256
    else
      validator:error("Invalid CLUT Table Size")
    end
    
    -- clutcount = clutsize - sizeof(CLUT_TABLE) / (cluelements * entrysize)
    local clutcount = (clblksize - 12) / (clutelements * 2)
    local clutsize = 0
    
    for i = 1, clutcount do
      clutsize = clutsize + (clutelements * 2)
    end
    
    if clutsize > buffer.length then
      validator:error("CLUT's size cannot be greater than file size")
    end
    
    pixeldatapos = clutsize + 20
  end
  
  pixeldatapos = pixeldatapos + 4 -- Skip Pixel Block Size
  
  local pxfbx = buffer:readType(pixeldatapos, pref.datatype.UInt16_LE)
  local pxfby = buffer:readType(pixeldatapos + 2, pref.datatype.UInt16_LE)
  local pxw = buffer:readType(pixeldatapos + 4, pref.datatype.UInt16_LE)
  local pxh = buffer:readType(pixeldatapos + 6, pref.datatype.UInt16_LE)
  
  if ((pxfbx < 0) or (pxw < 0) or (pxfby < 0) or (pxh < 0)) or (pxfbx > pxw) or (pxfby > pxh) then
    validator:error("Invalid Pixel Block Metrics")
  end
end
    
function TimFormat:parse(formattree)
  local timheader = formattree:addStructure("TimHeader")
  
  local fid = timheader:addField(pref.datatype.UInt32_LE, "Id")
  fid:setBitField("Id", 0, 7)
  fid:setBitField("Version", 8, 15)
  fid:setBitField("Reserved", 16, 31)
  
  local fflag = timheader:addField(pref.datatype.UInt32_LE, "Flag")
  fflag:setBitField("Bpp", 0, 2):dynamicInfo(TimFunctions.getBpp)
  fflag:setBitField("HasClut", 3)
  fflag:setBitField("Reserved", 4, 31)
  
  if timheader.Flag.HasClut.value == 1 then
    TimFunctions.createClutBlocks(formattree, timheader.Flag.Bpp.value)
  end
  
  local pixeldata = formattree:addStructure("PixelData")
  pixeldata:addField(pref.datatype.UInt32_LE, "BlockSize")
  pixeldata:addField(pref.datatype.UInt16_LE, "FrameBufferX")
  pixeldata:addField(pref.datatype.UInt16_LE, "FrameBufferY")
  pixeldata:addField(pref.datatype.UInt16_LE, "Width")
  pixeldata:addField(pref.datatype.UInt16_LE, "Height")
  pixeldata:addField(pref.datatype.Blob, "Pixel", pixeldata.BlockSize.value - pixeldata.size)
end

return TimFormat