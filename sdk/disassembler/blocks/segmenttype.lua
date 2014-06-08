local ffi = require("ffi")

ffi.cdef
[[
  const int SegmentType_Code;
  const int SegmentType_Data;
]]

local C = ffi.C
local SegmentType = { Code = C.SegmentType_Code,
                      Data = C.SegmentType_Data }

return SegmentType