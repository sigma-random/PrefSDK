local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Layout = require("sdk.ui.layout.layout")

ffi.cdef
[[
  void BoxLayout_addLayout(void* __this, void* layout, bool stretch);
]]

local C = ffi.C
local BoxLayout = oop.class(Layout)

function BoxLayout:__ctor(cthis)
  Layout.__ctor(self, cthis)
end

function BoxLayout:addLayout(layout, stretch)
  C.BoxLayout_addLayout(self.cthis, layout.cthis, stretch or false)
end

return BoxLayout