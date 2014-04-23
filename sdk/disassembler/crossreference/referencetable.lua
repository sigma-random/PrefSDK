local oop = require("sdk.lua.oop")
local Reference = require("sdk.disassembler.crossreference.reference")

local ReferenceTable = oop.class()

function ReferenceTable:__ctor()
  self.length = 0
end

function ReferenceTable:isReference(address)
  return (self[address] ~= nil)
end

function ReferenceTable:makeReference(address, addressby, referencetype)
  self[address] = Reference(address, addressby, referencetype)
  self.length = self.length + 1
end

return ReferenceTable
