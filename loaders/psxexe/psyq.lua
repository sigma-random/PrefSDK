local oop = require("oop")
local pref = require("pref")
local SysCallsA0 = require("loaders.psxexe.syscalls.syscalls00A0")
local SysCallsB0 = require("loaders.psxexe.syscalls.syscalls00B0")
local SysCallsC0 = require("loaders.psxexe.syscalls.syscalls00C0")
local PsxGTE = require("loaders.psxexe.gte")

local BiosSysCalls = { [0x000000A0] = SysCallsA0,
                       [0x000000B0] = SysCallsB0,
                       [0x000000C0] = SysCallsC0 }
                       
local PsyQ = oop.class()

function PsyQ:__ctor(loader, listing)
  self._loader = loader
  self._listing = listing
  self._instructionset = loader.processor.instructionset
  self._registerset = loader.processor.registerset
  self._t1reg = loader.processor.registerset["t1"].id
  self._t2reg = loader.processor.registerset["t2"].id
end

function PsyQ:analyze(f)
  local instruction = self._listing:firstInstruction(f)
  
  if instruction == nil then
    return
  end
  
  local res = self:analyzeBiosCall(f, instruction)
  
  if res == true then
    return
  end
  
  instruction = self._listing:firstInstruction(f)
  
  while instruction and (instruction.address < f.endaddress) do
    if (instruction.opcode == self._instructionset["COP2"].opcode) and PsxGTE.functions[instruction:operand(0).value] then
      self._loader:setConstant(instruction, instruction:operand(0).datatype, instruction:operand(0).value, PsxGTE.functions[instruction:operand(0).value])
    elseif (instruction.opcode == self._instructionset["LWC2"].opcode) or (instruction.opcode == self._instructionset["SWC2"].opcode) then  -- Check another COP2 Instructions
      local op = instruction:operand(0)
      op.type = pref.disassembler.operandtype.Register
      op.registername = PsxGTE.dataregisters[op.value]
    elseif bit.band(instruction.opcode, 0xFC000000) == 0x48000000 then  -- Check for COP2 Instructions
      self:elaborateCop2(instruction)
    end
    
    instruction = self._listing:nextInstruction(instruction)
  end
end

function PsyQ:elaborateCop2(instruction)
  if instruction.category ~= pref.disassembler.instructioncategory.LoadStore then
    return
  end
  
  local op2 = instruction:operand(1)
  op2.datatype = pref.datatype.UInt8
  op2.value = bit.rshift(bit.band(op2.value, 0x0000F800), 0x0B) -- This is a COP2 Register
  op2.type = pref.disassembler.operandtype.Register
  
  if (instruction.opcode == self._instructionset["MTC2"].opcode) or (instruction.opcode == self._instructionset["MFC2"].opcode) then
    op2.registername = PsxGTE.dataregisters[op2.value]
  elseif (instruction.opcode == self._instructionset["CTC2"].opcode) or (instruction.opcode == self._instructionset["CFC2"].opcode) then
    op2.registername = PsxGTE.controlregisters[op2.value]
  end
end

function PsyQ:analyzeBiosCall(f, instruction)
  -- Check Call Type and Register
  if (instruction.mnemonic ~= "LI") or (instruction:operand(0).value ~= self._t2reg) then
    return false
  end
  
  local calltype = instruction:operand(1).value
  instruction = self._listing:nextInstruction(instruction)
  
  -- Check If JR is calling t2
  if (instruction == nil) or (instruction.type ~= pref.disassembler.instructiontype.Stop) or (instruction:operand(0).value ~= self._t2reg) then
    return false
  end
  
  instruction = self._listing:nextInstruction(instruction)
  
  -- Check Function Id
  if (instruction == nil) or (instruction.mnemonic ~= "LI") or (instruction:operand(0).value ~= self._t1reg) then
    return false
  end
  
  local syscalls = BiosSysCalls[calltype]
  
  if syscalls == nil then
    return false
  end
  
  local callname = syscalls[instruction:operand(1).value]
  
  if callname == nil then
    return false
  end
  
  f.type = pref.disassembler.functiontype.ImportFunction
  self._loader:setSymbol(f.startaddress, callname)
  return true
end

return PsyQ
