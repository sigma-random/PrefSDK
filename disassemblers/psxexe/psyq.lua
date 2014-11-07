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

function PsyQ:analyze(disassembler, instruction)
  if instruction.mnemonic == "MOVE" then 
    if MipsRegisters.gpr[instruction.operands[1].value] == "t2" then
      self.funcaddress = instruction.address
      self.t2 = instruction.operands[2].value
      return
    elseif MipsRegisters.gpr[instruction.operands[1].value] == "t1" then
      self.t1 = instruction.operands[2].value
      
      if self.jrt2 and self.funcaddress then
        self:analyzeBiosCall(disassembler)
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
    self:analyzeServiceCall(disassembler)
    return
  end
  
  self.a0 = -1
  self.t2 = 0
  self.t1 = 0
  self.funcaddress = 0
  self.jrt2 = false
end

function PsyQ:analyzeBiosCall(disassembler)
  local syscalls = BiosSysCalls[self.t2]
  
  if syscalls then
    local callname = syscalls[self.t1]
    
    if callname then
      disassembler:setFunction(self.funcaddress, callname, FunctionType.ImportFunction)
    end
  end
end

function PsyQ:analyzeServiceCall(disassembler)
  local callname = ServiceCalls[self.a0]
  
  if callname then
    disassembler:setFunction(self.funcaddress, callname, FunctionType.ImportFunction)
  end
end

return PsyQ
