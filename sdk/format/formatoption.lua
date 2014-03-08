local FormatOption = { name = "<NoName>",
                       action = nil }

function FormatOption:new(name, action)
  local o = setmetatable({ }, { __index = FormatOption })
  o.name = name
  o.action = action
  return o
end

return FormatOption