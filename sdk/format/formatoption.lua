local oop = require("sdk.lua.oop")

local FormatOption = oop.class()

function FormatOption:__ctor(name, action)
  self.name = name
  self.action = action
end

return FormatOption