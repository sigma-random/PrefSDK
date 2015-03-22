local oop = require("oop")
local pref = require("pref")
local capstone = require("capstone")
local PeConstants = require("formats.pe.constants")
local PeFunctions = require("formats.pe.functions")

local InstructionAnalyzer = oop.class()

function InstructionAnalyzer:__ctor(cshandle, formattree)
  self.cshandle = cshandle
  self.formattree = formattree
  self.optionalheader = formattree.NtHeaders.OptionalHeader -- Shorthand
end

function InstructionAnalyzer:analyze(instruction)
  if (instruction.iscall or instruction.isjump) then
    if capstone.operandcount(self.cshandle, instruction.csinsn, capstone.X86_OP_IMM) > 0 then
      local idx = capstone.operandindex(self.cshandle, instruction.csinsn, capstone.X86_OP_IMM, 1)
      instruction.isdestinationvalid = true
      instruction.destination = instruction.detail.x86.operands[idx].imm
    elseif capstone.operandcount(self.cshandle, instruction.csinsn, capstone.X86_OP_MEM) > 0 then
      local idx = capstone.operandindex(self.cshandle, instruction.csinsn, capstone.X86_OP_MEM, 1)
      instruction.isdestinationvalid = false -- Do not follow this address
      instruction.destination = instruction.detail.x86.operands[idx].mem.disp
    end
  end
end

function InstructionAnalyzer:isImportBranch(instruction)
  local importdirectory = self.optionalheader.DataDirectory.ImportDirectory
  
  if importdirectory == nil then -- PE does not contains an IT
    return false
  end
  
  local section = PeFunctions.sectionFromRva(importdirectory.VirtualAddress.value, self.formattree)
  
  if section == nil then
    return false -- Something wrong: Junk data in DataDirectory?
  end
  
  if (not instruction.iscall) and (not instruction.isjump) then
    return false
  end
    
  if capstone.operandcount(self.cshandle, instruction.csinsn, capstone.X86_OP_MEM) == -1 then
    return false
  end
  
  local idx = capstone.operandindex(self.cshandle, instruction.csinsn, capstone.X86_OP_MEM, 1)
  local op = instruction.detail.x86.operands[idx]
  
  if PeFunctions.rvaInSection(op.mem.disp - self.optionalheader.ImageBase.value, section) then
    return true -- Got it! It's an IT call
  end
  
  return false
end

return InstructionAnalyzer
