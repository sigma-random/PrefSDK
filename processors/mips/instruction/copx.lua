local InstructionType = require("processors.mips.instruction.type")
local InstructionDefinition = require("processors.mips.instruction.definition")
local OperandDefinition = require("processors.mips.operand.definition")

-- Not Implemented Instructions
-- C.cond.fmt
-- MADD.fmt
-- MOVF.fmt (Check CC Operand?)
-- MSUB.fmt
-- NMADD.fmt
-- NMSUB.fmt
-- PLL.fmt
-- PLU.fmt
-- PREFX.fmt
-- PUL.fmt
-- PUU.fmt
-- SDXC1 (Check Operands)
-- WRPGPR: COP0 

local Cop0Functions = { } -- Debug Functions
Cop0Functions[0x00001F] = InstructionDefinition("DERET", InstructionType.Stop)
Cop0Functions[0x000018] = InstructionDefinition("ERET", InstructionType.Stop)
Cop0Functions[0x000018] = InstructionDefinition("ERET", InstructionType.Stop) 
Cop0Functions[0x00000A] = InstructionDefinition("RDPGPR", InstructionType.Debug, { OperandDefinition.rd, OperandDefinition.rt })
Cop0Functions[0x000008] = InstructionDefinition("TLBP", InstructionType.Debug)
Cop0Functions[0x000001] = InstructionDefinition("TLBR", InstructionType.Debug)
Cop0Functions[0x000002] = InstructionDefinition("TLBWI", InstructionType.Debug)
Cop0Functions[0x000006] = InstructionDefinition("TLBWR", InstructionType.Debug)
Cop0Functions[0x000020] = InstructionDefinition("WAIT", InstructionType.Debug)

local Cop0Operations = { } -- COP0 (Debug) Operations  (TODO Da Verificare TODO)
-- local Cop0Operations[0x0000B] = InstructionDefinition("DI", InstructionType.Debug, { OperandDefinition.rt })
-- local Cop0Operations[0x0000B] = InstructionDefinition("EI", InstructionType.Debug, { OperandDefinition.rt })
Cop0Operations[0x00000] = InstructionDefinition("MFC0", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop0rd })
Cop0Operations[0x00004] = InstructionDefinition("MTC0", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop0rd })

function Cop0Operations.operation(op, func, data)
  if bit.band(data, 0x02000000) ~= 0 then
    return Cop0Functions[func]
  end
  
  return Cop0Operations[op]
end

local Cop1Functions = { } -- FPU Functions
Cop1Functions[0x000005] = InstructionDefinition("ABS", InstructionType.FPUAbs, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000000] = InstructionDefinition("ADD", InstructionType.FPUAdd, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.ft })
Cop1Functions[0x00000A] = InstructionDefinition("CEIL.L", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x00000E] = InstructionDefinition("CEIL.W", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000020] = InstructionDefinition("CVT", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000024] = InstructionDefinition("CVT", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000003] = InstructionDefinition("DIV", InstructionType.FPUDiv, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.ft })
Cop1Functions[0x000006] = InstructionDefinition("MOV", InstructionType.Load, { OperandDefinition.fd, OperandDefinition.fs })
-- Cop1Functions[0x000011] = InstructionDefinition("MOVF", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000013] = InstructionDefinition("MOVN", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.rt })
-- Cop1Functions[0x000011] = InstructionDefinition("MOVT", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000012] = InstructionDefinition("MOVZ", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.rt })
Cop1Functions[0x000002] = InstructionDefinition("MUL", InstructionType.FPUMul, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.ft })
Cop1Functions[0x000002] = InstructionDefinition("MUL", InstructionType.FPUNot, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.ft })
Cop1Functions[0x000015] = InstructionDefinition("RECIP", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000008] = InstructionDefinition("ROUND.L", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000018] = InstructionDefinition("ROUND.W", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000016] = InstructionDefinition("RSQRT", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000004] = InstructionDefinition("SQRT", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x000001] = InstructionDefinition("SUB", InstructionType.FPUSub, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.ft })
Cop1Functions[0x000009] = InstructionDefinition("TRUNC.L", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })
Cop1Functions[0x00000D] = InstructionDefinition("TRUNC.W", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs })

local Cop1Operations = { } -- COP1 (FPU) Operations
Cop1Operations[0x00002] = InstructionDefinition("CFC1", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.fs })
Cop1Operations[0x00006] = InstructionDefinition("CTC1", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.fs })
Cop1Operations[0x00000] = InstructionDefinition("MFC1", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.fs })
Cop1Operations[0x00004] = InstructionDefinition("MTC1", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.fs })
Cop1Operations[0x00003] = InstructionDefinition("MFHC1", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.fs })
Cop1Operations[0x00007] = InstructionDefinition("MTHC1", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.fs })

function Cop1Operations.operation(op, func)  
 if op <= 0x0F then -- Used to encode Coprocessor Operation instructions (MFC1, CTC1, etc.)
   return Cop1Operations[op]
 end
 
 return Cop1Functions[func]
end


local Cop2Operations = { } -- COP2 Operations
Cop2Operations[0x00002] = InstructionDefinition("CFC2", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop2ctrlrd })
Cop2Operations[0x00006] = InstructionDefinition("CTC2", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop2ctrlrd })
Cop2Operations[0x00000] = InstructionDefinition("MFC2", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop2datard })
Cop2Operations[0x00004] = InstructionDefinition("MTC2", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop2datard })
Cop1Operations[0x00003] = InstructionDefinition("MFHC2", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop2datard })
Cop1Operations[0x00007] = InstructionDefinition("MTHC2", InstructionType.Undefined, { OperandDefinition.rt, OperandDefinition.cop2datard })

function Cop2Operations.operation(op, func, data)
  if op <= 0x0F then -- Used to encode Coprocessor Operation instructions (MFC2, CTC2, etc.)
    return Cop2Operations[op]
  end
  
  if bit.band(data, 0x02000000) == 0x02000000 then
    return InstructionDefinition("COP2", InstructionType.Undefined, { OperandDefinition.cofun })
  end
  
  return nil
end

local Cop1XFunctions = { } 
Cop1XFunctions[0x00001E] = InstructionDefinition("ALNV.PS", InstructionType.Undefined, { OperandDefinition.fd, OperandDefinition.fs, OperandDefinition.ft, OperandDefinition.rs })
Cop1XFunctions[0x000001] = InstructionDefinition("LDXC1", InstructionType.FPULoad, { OperandDefinition.fd, OperandDefinition.baseindex })
Cop1XFunctions[0x000005] = InstructionDefinition("LUXC1", InstructionType.FPULoad, { OperandDefinition.fd, OperandDefinition.baseindex })
Cop1XFunctions[0x000000] = InstructionDefinition("LWXC1", InstructionType.FPULoad, { OperandDefinition.fd, OperandDefinition.baseindex })
Cop1XFunctions[0x000009] = InstructionDefinition("SDXC1", InstructionType.FPUStore, { OperandDefinition.fs, OperandDefinition.baseindex })
Cop1XFunctions[0x00000D] = InstructionDefinition("SUXC1", InstructionType.FPUStore, { OperandDefinition.fs, OperandDefinition.baseindex })
Cop1XFunctions[0x000008] = InstructionDefinition("SWXC1", InstructionType.FPUStore, { OperandDefinition.fs, OperandDefinition.baseindex })

local Cop1XOperations = { } -- COP1X Operations (64-Bit FPU)

function Cop1XOperations.operation(op, func)
  return Cop1Functions[func]
end

local CopXInstructionSet = { tf = { [0] = "F", [1] = "T" }, nd = { [0] = "" , [1] = "L" },
                             [0] = Cop0Operations, [1] = Cop1Operations, [2] = Cop2Operations, [3] = Cop1XOperations }

function CopXInstructionSet.isvalid(copn, op, func, data)
  if (copn > 3) or (CopXInstructionSet[copn] == nil) then
    return false
  end
  
  return CopXInstructionSet[copn].operation(op, func, data) ~= nil
end

function CopXInstructionSet.operation(copn, op, func, data)
  if op == 0x00008 then
    local tf = bit.rshift(bit.band(data, 0x00010000), 0x10)
    local nd = bit.rshift(bit.band(data, 0x00020000), 0x11)
    local mnemonic = string.format("BC%d%s%s", copn, CopXInstructionSet.tf[tf], CopXInstructionSet.nd[nd])
    return InstructionDefinition(mnemonic, InstructionType.ConditionalJump, { OperandDefinition.imm16 })  -- FIXME: Check Condition Code?
  end
  
  return CopXInstructionSet[copn].operation(op, func, data)
end

return CopXInstructionSet
