local ffi = require("ffi")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  void PrefUI_show(void* __this);
  void PrefUI_showModal(void* __this);
]]

local C = ffi.C
local PrefWidget = oop.class()

function PrefWidget:__ctor(cthis)
  self.cthis = cthis
end

function PrefWidget:show()
  C.PrefUI_show(self.cthis)
end

function PrefWidget:showModal()
  C.PrefUI_showModal(self.cthis)
end

return PrefWidget