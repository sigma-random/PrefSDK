require("sdk.format.formatoption")

local FormatDefinition = { name = "Unknown",
                           category = "Unknown",
                           author = "Anonymous",
                           version = "Unknown",
                           options = { },
                           endian = Endian.PlatformEndian }

FormatDefinition.__index = FormatDefinition
                     
function FormatDefinition:new(name, category, author, version, endian)
  local o = setmetatable({ }, self)
  
  o.name = name
  o.category = category
  o.author = author
  o.version = version
  o.endian = endian
  o.options = { }
    
  table.insert(FormatList, o)
  return o
end

function FormatDefinition:validateFormat(buffer)
  return false
end

function FormatDefinition:parseFormat(formatmodel, buffer)
  -- This method must be reimplemented!
end

function FormatDefinition:generateLoader(loader, formatmodel, buffer)
  -- This method must be reimplemented!
end

function FormatDefinition:registerOption(name, action)
  table.insert(self.options, FormatOption:new(name, action))
end

function FormatDefinition:executeOption(optidx, formatmodel, buffer)
  if optidx <= #self.options then
    self.options[optidx].action(formatmodel, buffer)
  end
end

return FormatDefinition