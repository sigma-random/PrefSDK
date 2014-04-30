local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Widget = require("sdk.ui.widget")

ffi.cdef
[[
  void* Dialog_create(const char* title);
  void Dialog_setLayout(void* __this, void* layout);
  void Dialog_show(void* __this);
  void Dialog_exec(void* __this);
]]

local C = ffi.C
local Dialog = oop.class(Widget)

function Dialog:__ctor(title)
  Widget.__ctor(self, C.Dialog_create(title))
end

function Dialog:setLayout(layout)
  C.Dialog_setLayout(self.cthis, layout.cthis)
end

function Dialog:show()
  C.Dialog_show(self.cthis)
end

function Dialog:exec()
  C.Dialog_exec(self.cthis)
end

return Dialog