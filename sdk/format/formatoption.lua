local oop = require("sdk.lua.oop")

local FormatOption = oop.class()

function FormatOption:__ctor(name, description, action)
  self.name = name
  self.description = description
  self.action = action
end

return FormatOption