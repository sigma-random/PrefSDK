local oop = require("oop")
local pref = require("pref")
local Mips32RegisterSet = require("processors.mips32.registerset")
local SysCallsA0 = require("loaders.psxexe.syscalls.syscalls00A0")
local SysCallsB0 = require("loaders.psxexe.syscalls.syscalls00B0")
local SysCallsC0 = require("loaders.psxexe.syscalls.syscalls00C0")

local BiosSysCalls = { [0x000000A0] = SysCallsA0,
                       [0x000000B0] = SysCallsB0,
                       [0x000000C0] = SysCallsC0 }
                       
local BiosCalls = oop.class()

function BiosCalls:__ctor(loader, listing)
  self._loader = loader
  self._listing = listing
  self._t1reg = Mips32RegisterSet["t1"]
  self._t2reg = Mips32RegisterSet["t2"]
end

function BiosCalls:analyze(f)
  local instruction = self._listing:firstInstruction(f)
  
  -- Check Call Type and Register
  if (instruction == nil) or (instruction.mnemonic ~= "LI") or (instruction:operand(0).value ~= self._t2reg) then
    return
  end
  
  local calltype = instruction:operand(1).value
  instruction = self._listing:nextInstruction(instruction)
  
  -- Check If JR is calling t2
  if (instruction == nil) or (instruction.type ~= pref.disassembler.instructiontype.Stop) or (instruction:operand(0).value ~= self._t2reg) then
    self._loader:logline(string.format("%x", pref.disassembler.instructiontype.Stop))
    return
  end
  
  instruction = self._listing:nextInstruction(instruction)
  
  -- Check Function Id
  if (instruction == nil) or (instruction.mnemonic ~= "LI") or (instruction:operand(0).value ~= self._t1reg) then
    return 
  end
  
  local syscalls = BiosSysCalls[calltype]
  
  if syscalls == nil then
    return
  end
  
  local callname = syscalls[instruction:operand(1).value]
  
  if callname == nil then
    return
  end
  
  f.type = pref.disassembler.functiontype.ImportFunction
  self._loader:setSymbol(f.startaddress, callname)
end

return BiosCalls
