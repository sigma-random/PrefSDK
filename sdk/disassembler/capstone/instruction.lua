local oop = require("oop")
local capstone = require("capstone")

-- Somewhat equivalent to sdk.disassembler.instruction
local CapstoneInstruction = oop.class()

function CapstoneInstruction:__ctor(cshandle, csinsn)  
  self.csinsn = csinsn
  self.detail = csinsn.detail -- Shorthand
  
  self.id = csinsn.id
  self.address = csinsn.address
  self.mnemonic = string.upper(csinsn.mnemonic)
  self.type = csinsn.id
  self.size = csinsn.size
  self.isjump = capstone.instructiongroup(cshandle, csinsn, capstone.CS_GRP_JUMP)
  self.iscall = capstone.instructiongroup(cshandle, csinsn, capstone.CS_GRP_CALL)
  
  self.destination = 0
  self.isdestinationvalid = false
  self.ismacro = false
  self.isconditional = false  
end

return CapstoneInstruction