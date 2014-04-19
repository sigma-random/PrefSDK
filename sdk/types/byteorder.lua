local ffi = require("ffi")
local DataType = require("sdk.types.datatype")

ffi.cdef
[[
    const int ByteOrder_LittleEndian;
    const int ByteOrder_BigEndian;
    const int ByteOrder_PlatformEndian;
]]

local C = ffi.C
local ByteOrder = { LittleEndian   = C.ByteOrder_LittleEndian,
                    BigEndian      = C.ByteOrder_BigEndian,
                    PlatformEndian = C.ByteOrder_PlatformEndian } 

return ByteOrder
