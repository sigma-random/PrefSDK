local oop = require("sdk.lua.oop")

local AddressQueue = oop.class()

function AddressQueue:__ctor()
  self.first = 0
  self.last = -1
end

function AddressQueue:isEmpty()
  return (self.first > self.last)
end

function AddressQueue:pushFront(address)
  local last = self.last + 1
  self.last = last
  self[last] = address
end

function AddressQueue:popBack()
  local last = self.last
  
  if self:isEmpty() then
    error("AddressQueue is Empty")
  end
  
  local value = self[last]
  self[last] = nil -- Allow Garbage Collection
  self.last = last - 1
  
  return value
end

return AddressQueue