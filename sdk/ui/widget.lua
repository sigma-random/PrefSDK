local ffi = require("ffi")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  void Widget_resize(void* __this, int w, int h);
]]

local C = ffi.C
local Widget = oop.class()

function Widget:__ctor(cthis)
  self.cthis = cthis
end

function Widget:resize(w, h)
  C.Widget_resize(self.cthis, w, h)
end

return Widget