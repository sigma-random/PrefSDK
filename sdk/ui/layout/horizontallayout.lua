local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local BoxLayout = require("sdk.ui.layout.boxlayout")

ffi.cdef
[[
  void* Layout_createHorizontal();
]]

local C = ffi.C
local HorizontalLayout = oop.class(BoxLayout)

function HorizontalLayout:__ctor()
  BoxLayout.__ctor(self, C.Layout_createHorizontal())
end

return HorizontalLayout