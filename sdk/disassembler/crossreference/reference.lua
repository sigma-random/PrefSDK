local oop = require("sdk.lua.oop")
local ReferenceType = require("sdk.disassembler.crossreference.referencetype")

local Reference = oop.class()

function Reference:__ctor(address, addressby, referencetype)
  self.address = address
  self.type = referencetype
  self.xrefs = { }
  
  self:generatePrefix()
  self:update(addressby)
end

function Reference:generatePrefix()
  if (self.type == ReferenceType.CallFar) or (self.type == ReferenceType.CallNear) then
    self.prefix = "sub_"
  elseif (self.type == ReferenceType.JumpFar) or (self.type == ReferenceType.JumpNear) then
    self.prefix = "loc_"
  else
    self.prefix = "" -- Empty Prefix
  end
end

function Reference:update(addressby)
  table.insert(self.xrefs, addressby)
end

return Reference