-- From:
-- https://pcsxr.codeplex.com/SourceControl/latest#pcsxr/libpcsxcore/gte.c
-- https://code.google.com/p/pops-gte/source/browse/trunk/GTE

local GTEFunctions = { }
GTEFunctions.comments = { }

GTEFunctions[0x00] = "RTPS"
GTEFunctions[0x01] = "RTPS"
GTEFunctions[0x06] = "NCLIP"
GTEFunctions[0x0C] = "OP"
GTEFunctions[0x10] = "DPCS"
GTEFunctions[0x11] = "INTPL"
GTEFunctions[0x12] = "MVMVA"
GTEFunctions[0x13] = "NCDS"
GTEFunctions[0x14] = "CDP"
GTEFunctions[0x16] = "NCDT"
GTEFunctions[0x1B] = "NCCS"
GTEFunctions[0x1C] = "CC"
GTEFunctions[0x1E] = "NCS"
GTEFunctions[0x20] = "NCT"
GTEFunctions[0x28] = "SQR"
GTEFunctions[0x29] = "DPCL"
GTEFunctions[0x2A] = "DPCT"
GTEFunctions[0x2D] = "AVSZ3"
GTEFunctions[0x2E] = "AVSZ4"
GTEFunctions[0x30] = "RTPT"
GTEFunctions[0x3D] = "GPF"
GTEFunctions[0x3E] = "GPL"
GTEFunctions[0x3F] = "NCCT"

GTEFunctions.comments[0x00] = "Coordinate transformation and perspective transformation"
GTEFunctions.comments[0x01] = "Coordinate transformation and perspective transformation"
GTEFunctions.comments[0x06] = "Normal clipping"
GTEFunctions.comments[0x0C] = "Outer product"
GTEFunctions.comments[0x10] = "Depth queuing"
GTEFunctions.comments[0x11] = "Interpolation"
GTEFunctions.comments[0x12] = "Matrix and vector multiplication"
GTEFunctions.comments[0x13] = "Light source calculation"
GTEFunctions.comments[0x14] = "Light source calculation"
GTEFunctions.comments[0x16] = "Light source calculation"
GTEFunctions.comments[0x1B] = "Light source calculation"
GTEFunctions.comments[0x1C] = "Light source calculation"
GTEFunctions.comments[0x1E] = "Light source calculation"
GTEFunctions.comments[0x20] = "Light source calculation"
GTEFunctions.comments[0x28] = "Vector squaring"
GTEFunctions.comments[0x29] = "Depth queuing"
GTEFunctions.comments[0x2A] = "Depth queuing"
GTEFunctions.comments[0x2D] = "Z-Averaging"
GTEFunctions.comments[0x2E] = "Z-Averaging"
GTEFunctions.comments[0x30] = "Coordinate transformation and perspective transformation"
GTEFunctions.comments[0x3D] = "General purpose interpolation"
GTEFunctions.comments[0x3E] = "General purpose interpolation"
GTEFunctions.comments[0x3F] = "Light source calculation"

function GTEFunctions.exists(gteop)
  local gtefunc = bit.band(gteop, 0x3F)
  return GTEFunctions[gtefunc] ~= nil
end

function GTEFunctions.name(gteop)
  local gtefunc = bit.band(gteop, 0x3F)
  return GTEFunctions[gtefunc]
end

function GTEFunctions.comment(gteop)
  local gtefunc = bit.band(gteop, 0x3F)
  return GTEFunctions.comments[gtefunc]
end

return GTEFunctions