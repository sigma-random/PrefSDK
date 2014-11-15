-- http://en.wikipedia.org/wiki/MIPS_instruction_set#MIPS_I_instruction_formats
--
-- Type | -31-                    format (bits)                        -0-
--   R  | opcode (6) | rs (5) | rt (5) | rd (5) | shamt (5) | func (6)  |
--   I  | opcode (6) | rs (5) | rt (5) | immediate (16)                 |
--   J  | opcode (6) |                     address (26)                 |

local oop = require("oop")
local pref = require("pref")
local Operand = require("sdk.disassembler.operand")
local OperandType = require("processors.mips.operand.type")

local DataType = pref.datatype

local function signExtend(value)
  if bit.band(value, 0x8000) ~= 0 then
    return bit.bor(0xFFFF0000, value)
  end
  
  return value
end

local RsOperand = oop.class(Operand)
RsOperand.type = OperandType.Register

function RsOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)
end

local RtOperand = oop.class(Operand)
RtOperand.type = OperandType.Register

function RtOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local RdOperand = oop.class(Operand)
RdOperand.type = OperandType.Register

function RdOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

local ShamtOperand = oop.class(Operand)
ShamtOperand.type = OperandType.Immediate

function ShamtOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x000007C0), 0x06)
end

local Imm16Operand = oop.class(Operand)
Imm16Operand.type = OperandType.Immediate

function Imm16Operand:__ctor(data)
  self:__super(DataType.Int16)
  self.value = signExtend(bit.band(data, 0x0000FFFF))
end

local TargetOperand = oop.class(Operand)
TargetOperand.type = OperandType.Address

function TargetOperand:__ctor(data, baseaddress)
  self:__super(DataType.UInt32)
  self.value = baseaddress + bit.lshift(bit.band(data, 0x03FFFFFF), 2)
end

local OffsetOperand = oop.class(Operand)
OffsetOperand.type = OperandType.Offset

function OffsetOperand:__ctor(data, address)
  self:__super(DataType.UInt32)
  self.value = address + 4 + bit.lshift(signExtend(bit.band(data, 0x0000FFFF)), 2)
end

local MemoryOperand = oop.class(Operand)
MemoryOperand.type = OperandType.Memory

function MemoryOperand:__ctor(data)
  self:__super(DataType.UInt32)
  self.base = bit.rshift(bit.band(data, 0x03E00000), 0x15)
  self.disp = signExtend(bit.band(data, 0x0000FFFF))
end

local CacheOpOperand = oop.class(Operand)
CacheOpOperand.type = OperandType.Immediate

function CacheOpOperand:__ctor(data)
  self:__super(DataType.UInt16)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local CodeOperand = oop.class(Operand)
CodeOperand.type = OperandType.Code

function CodeOperand:__ctor(data)
  self:__super(DataType.UInt32)
  self.value = bit.rshift(bit.band(data, 0x03FFFFC0), 0x06)
end

-------------------------
-- COPX Performance Op --
-------------------------

local CoFunOperand = oop.class(Operand)
CoFunOperand.type = OperandType.Immediate

function CoFunOperand:__ctor(data)
  self:__super(DataType.UInt32)
  self.value = bit.band(data, 0x01FFFFFF)
end

-----------------------
-- MIPS FPU Operands --
-----------------------
local BaseIndexOperand = oop.class()
BaseIndexOperand.type = OperandType.BaseIndex

function BaseIndexOperand:__ctor(data)
  self:_super(DataType.UInt32)
  self.base = bit.rshift(bit.band(data, 0x03E00000), 0x15)
  self.index = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local FtOperand = oop.class(Operand)
FtOperand.type = OperandType.FPURegister

function FtOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local FsOperand = oop.class(Operand)
FsOperand.type = OperandType.FPURegister

function FsOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

local FdOperand = oop.class(Operand)
FdOperand.type = OperandType.FPURegister

function FdOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x000007C0), 0x06)
end

------------------------
-- MIPS COP0 Operands --
------------------------
local Cop0RsOperand = oop.class(Operand)
Cop0RsOperand.type = OperandType.COP0Register

function Cop0RsOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)
end

local Cop0RtOperand = oop.class(Operand)
Cop0RtOperand.type = OperandType.COP0Register

function Cop0RtOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local Cop0RdOperand = oop.class(Operand)
Cop0RdOperand.type = OperandType.COP0Register

function Cop0RdOperand:__ctor(data)
  self:__super(DataType.UInt8)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

------------------------
-- MIPS COP2 Operands --
------------------------

-- Data Registers --
local Cop2DataRsOperand = oop.class(RsOperand)
Cop2DataRsOperand.type = OperandType.COP2DataRegister

local Cop2DataRtOperand = oop.class(RtOperand)
Cop2DataRtOperand.type = OperandType.COP2DataRegister

local Cop2DataRdOperand = oop.class(RdOperand)
Cop2DataRdOperand.type = OperandType.COP2DataRegister

-- Control Registers --
local Cop2ControlRsOperand = oop.class(RsOperand)
Cop2ControlRsOperand.type = OperandType.COP2ControlRegister

local Cop2ControlRtOperand = oop.class(RtOperand)
Cop2ControlRtOperand.type = OperandType.COP2ControlRegister

local Cop2ControlRdOperand = oop.class(RdOperand)
Cop2ControlRdOperand.type = OperandType.COP2ControlRegister

return { rs = RsOperand, rt = RtOperand, rd = RdOperand,
         shamt = ShamtOperand, imm16 = Imm16Operand, target = TargetOperand, offset = OffsetOperand, memory = MemoryOperand,
         op = CacheOpOperand, cofun = CoFunOperand, baseindex = BaseIndexOperand, code = CodeOperand,
         ft = FtOperand, fs = FsOperand, fd = FdOperand,
         cop0rs = Cop0RsOperand, cop0rt = Cop0RtOperand, cop0rd = Cop0RdOperand,
         cop2datars = Cop2DataRsOperand, cop2datart = Cop2DataRtOperand, cop2datard = Cop2DataRdOperand,
         cop2ctrlrs = Cop2ControlRsOperand, cop2ctrlrt = Cop2ControlRtOperand, cop2ctrlrd = Cop2ControlRdOperand }
