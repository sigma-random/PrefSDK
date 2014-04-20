local ffi = require("ffi")

ffi.cdef
[[
  const uint64_t SegmentType_Data;
  const uint64_t SegmentType_Code;
]]

local C = ffi.C
local SegmentType = { Data = C.SegmentType_Data,
                      Code = C.SegmentType_Code }

return SegmentType