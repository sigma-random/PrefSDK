local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local BoxLayout = require("sdk.ui.layout.boxlayout")

ffi.cdef
[[
  void* Layout_createVertical();
]]

local C = ffi.C
local VerticalLayout = oop.class(BoxLayout)

function VerticalLayout:__ctor()
  BoxLayout.__ctor(self, C.Layout_createVertical())
end

return VerticalLayout