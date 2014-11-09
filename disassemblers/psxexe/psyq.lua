local oop = require("oop")
local pref = require("pref")
local MipsRegisters = require("processors.mips.registers")
local ServiceCalls = require("disassemblers.psxexe.syscalls.servicecalls")
local SysCallsA0 = require("disassemblers.psxexe.syscalls.syscalls00A0")
local SysCallsB0 = require("disassemblers.psxexe.syscalls.syscalls00B0")
local SysCallsC0 = require("disassemblers.psxexe.syscalls.syscalls00C0")

local FunctionType = pref.disassembler.functiontype
local SymbolType = pref.disassembler.symboltype
local BiosSysCalls = { [0x000000A0] = SysCallsA0,
                       [0x000000B0] = SysCallsB0,
                       [0x000000C0] = SysCallsC0 }

local PsyQ = oop.class()

function PsyQ:__ctor()
  self.t2 = 0
  self.t1 = 0
  self.a0 = -1
  self.funcaddress = 0
  self.jrt2 = false
end

function PsyQ:analyze(listing, instruction)
  if instruction.mnemonic == "MOVE" then 
    if MipsRegisters.gpr[instruction.operands[1].value] == "t2" then
      self.funcaddress = instruction.address
      self.t2 = instruction.operands[2].value
      return
    elseif MipsRegisters.gpr[instruction.operands[1].value] == "t1" then
      self.t1 = instruction.operands[2].value
      
      if self.jrt2 and self.funcaddress then
        self:analyzeBiosCall(listing)
        return
      end
    elseif MipsRegisters.gpr[instruction.operands[1].value] == "a0" then
      self.funcaddress = instruction.address
      self.a0 = instruction.operands[2].value
      
      if self.a0 > 4 then
        self.a0 = 4
      end
      
      return
    end
  elseif (instruction.mnemonic == "JR") and (MipsRegisters.gpr[instruction.operands[1].value] == "t2") then
    self.jrt2 = true
    return
  elseif (self.a0 > -1) and (instruction.mnemonic == "SYSCALL") then
    self:analyzeServiceCall(listing)
    return
  end
  
  self.a0 = -1
  self.t2 = 0
  self.t1 = 0
  self.funcaddress = 0
  self.jrt2 = false
end

function PsyQ:analyzeBiosCall(listing)
  local syscalls = BiosSysCalls[self.t2]
  
  if syscalls then
    local callname = syscalls[self.t1]
    
    if callname then
      listing:setFunction(self.funcaddress, FunctionType.ImportFunction, callname)
    end
  end
end

function PsyQ:analyzeServiceCall(listing)
  local callname = ServiceCalls[self.a0]
  
  if callname then
    listing:setFunction(self.funcaddress, FunctionType.ImportFunction, callname)
  end
end

return PsyQ
