local ffi = require("ffi")
local oop = require("sdk.lua.oop") 

ffi.cdef
[[
  void MessageBox_show(const char* title, const char* message);
]]

local C = ffi.C
local MessageBox = oop.class()

function MessageBox:__ctor(title, message)
  self.title = title
  self.message = message
end

function MessageBox:show()
  C.MessageBox_show(self.title, self.message)
end

return MessageBox