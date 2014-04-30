local ffi = require("ffi")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  void Layout_addWidget(void* __this, void* widget);
  void Layout_setMargins(void* __this, int left, int top, int right, int bottom);
]]

local C = ffi.C
local Layout = oop.class()

function Layout:__ctor(cthis)
  self.cthis = cthis
end

function Layout:setMargins(left, top, right, bottom)
  C.Layout_setMargins(self.cthis, left, top, right, bottom)
end

function Layout:addWidget(widget)
  C.Layout_addWidget(self.cthis, widget.cthis)
end

return Layout
