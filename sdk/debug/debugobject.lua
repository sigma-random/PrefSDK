local ffi = require("ffi")
local oop = require("sdk.lua.oop")

ffi.cdef
[[
  void Debug_log(void* hexeditdata, const char* s);
  void Debug_logLine(void* hexeditdata, const char* s);
  void Debug_logNotice(void* hexeditdata, const char* s);
  void Debug_logWarning(void* hexeditdata, const char* s);
  void Debug_logError(void* hexeditdata, const char* s);
]]

local C = ffi.C
local DebugObject = oop.class()

function DebugObject:__ctor(databuffer)
  self.databuffer = databuffer
end

function DebugObject:log(msg)
  C.Debug_log(self.databuffer.cthis, msg)
end

function DebugObject:logLine(msg)
  C.Debug_logLine(self.databuffer.cthis, msg)
end

function DebugObject:notice(msg)
  C.Debug_logNotice(self.databuffer.cthis, msg)
end

function DebugObject:warning(msg)
  C.Debug_logWarning(self.databuffer.cthis, msg)
end

function DebugObject:error(msg)
  C.Debug_logError(self.databuffer.cthis, msg)
end

return DebugObject