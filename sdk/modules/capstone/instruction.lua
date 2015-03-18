local ffi = require("ffi") 
local oop = require("oop")

-- Somewhat equivalent to sdk.disassembler.instruction
local CapstoneInstruction = oop.class()

function CapstoneInstruction:__ctor(capstone, csinsn)  
  self.__csinsn = csinsn
  self.detail = csinsn.detail -- Shorthand
  
  self.id = csinsn.id
  self.address = tonumber(csinsn.address)
  self.mnemonic = string.upper(ffi.string(csinsn.mnemonic))
  self.type = tonumber(csinsn.id)
  self.size = csinsn.size
  self.isjump = capstone:instructionGroup(self, capstone.lib.CS_GRP_JUMP)
  self.iscall = capstone:instructionGroup(self, capstone.lib.CS_GRP_CALL)
  
  self.destination = 0
  self.isdestinationvalid = false
  self.ismacro = false
  self.isconditional = false  
end

return CapstoneInstruction
