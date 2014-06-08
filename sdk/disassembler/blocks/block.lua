local oop = require("sdk.lua.oop")

local Block = oop.class()

function Block:__ctor(startaddress, endaddress)
  self.startaddress = startaddress
  self.endaddress = endaddress
end

function Block:size()
  return self.endaddress - self.startaddress
end

function Block:contains(address)
  return (address >= self.startaddress) and (address <= self.endaddress)
end

function Block:isEmpty()
  return self.endaddress >= self.startaddress
end

function Block:compile()
  -- This function must be reimplemented
end

return Block
