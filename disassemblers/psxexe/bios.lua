local oop = require("oop")
local pref = require("pref")
local MipsRegisters = require("processors.mips.registers")
local ServiceCalls = require("disassemblers.psxexe.syscalls.servicecalls")
local SysCalls00A0 = require("disassemblers.psxexe.syscalls.syscalls00A0")
local SysCalls00B0 = require("disassemblers.psxexe.syscalls.syscalls00B0")
local SysCalls00C0 = require("disassemblers.psxexe.syscalls.syscalls00C0")

local FunctionType = pref.disassembler.functiontype
local SymbolType = pref.disassembler.symboltype
local BiosSysCalls = { [0xA0] = SysCalls00A0,
                       [0xB0] = SysCalls00B0,
                       [0xC0] = SysCalls00C0 }

local PsxBios = oop.class()

function PsxBios:__ctor()
  self.t2 = 0
  self.t1 = 0
  self.a0 = -1
  self.funcaddress = 0
  self.jrt2 = false
end

function PsxBios:analyze(listing, instruction)
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

function PsxBios:analyzeBiosCall(listing)
  local syscalls = BiosSysCalls[self.t2]
  
  if syscalls then
    local callname = syscalls[self.t1]
    
    if callname then
      listing:setFunction(self.funcaddress, FunctionType.ImportFunction, callname)
    end
  end
end

function PsxBios:analyzeServiceCall(listing)
  local callname = ServiceCalls[self.a0]
  
  if callname then
    listing:setFunction(self.funcaddress, FunctionType.ImportFunction, callname)
  end
end

return PsxBios
