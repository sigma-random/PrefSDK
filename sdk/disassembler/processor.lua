local oop = require("oop")

local Processor = oop.class()

function Processor:decode(address, memorybuffer)
  -- Override This Method
  return nil
end

return Processor
