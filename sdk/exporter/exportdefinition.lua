local ExportDefinition = { name = "",
                           description = "",
                           author = "Anonymous", 
                           version = "No Version" }

ExportDefinition.__index = ExportDefinition

function ExportDefinition:new(name, description, author, version)
  local o = setmetatable({ }, self)
  
  o.name = name
  o.description = description
  o.author = author
  o.version = version
  
  table.insert(ExportList, o)
  return o
end

function ExportDefinition:exportData(inbuffer, outbuffer, startoffset, endoffset)
  -- This function must be reimplemented
end

return ExportDefinition