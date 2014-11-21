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

local RsOperand = Operand:define(OperandType.Register, DataType.UInt8)

function RsOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)
end

local RtOperand = Operand:define(OperandType.Register, DataType.UInt8)

function RtOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local RdOperand = Operand:define(OperandType.Register, DataType.UInt8)

function RdOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

local ShamtOperand = Operand:define(OperandType.Immediate, DataType.UInt8)

function ShamtOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x000007C0), 0x06)
end

local Imm16Operand = Operand:define(OperandType.Immediate, DataType.UInt16)

function Imm16Operand:__ctor(data)
  self.value = signExtend(bit.band(data, 0x0000FFFF))
end

local TargetOperand = Operand:define(OperandType.Address, DataType.UInt32)

function TargetOperand:__ctor(data, baseaddress)
  self.value = baseaddress + bit.lshift(bit.band(data, 0x03FFFFFF), 2)
end

local OffsetOperand = Operand:define(OperandType.Offset, DataType.UInt32)

function OffsetOperand:__ctor(data, address)
  self.value = address + 4 + bit.lshift(signExtend(bit.band(data, 0x0000FFFF)), 2)
end

local MemoryOperand = Operand:define(OperandType.Memory, DataType.UInt32)

function MemoryOperand:__ctor(data)
  self.base = bit.rshift(bit.band(data, 0x03E00000), 0x15)
  self.disp = signExtend(bit.band(data, 0x0000FFFF))
end

local CacheOpOperand = Operand:define(OperandType.Immediate, DataType.UInt16)

function CacheOpOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local CodeOperand = Operand:define(OperandType.Code, DataType.UInt32)

function CodeOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x03FFFFC0), 0x06)
end

-------------------------
-- COPX Performance Op --
-------------------------

local CoFunOperand = Operand:define(OperandType.Immediate, DataType.UInt32)

function CoFunOperand:__ctor(data)
  self.value = bit.band(data, 0x01FFFFFF)
end

-----------------------
-- MIPS FPU Operands --
-----------------------
local BaseIndexOperand = Operand:define(OperandType.BaseIndex, DataType.UInt32)

function BaseIndexOperand:__ctor(data)
  self.base = bit.rshift(bit.band(data, 0x03E00000), 0x15)
  self.index = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local FtOperand = Operand:define(OperandType.FPURegister, DataType.UInt8)

function FtOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local FsOperand = Operand:define(OperandType.FPURegister, DataType.UInt8)

function FsOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

local FdOperand = Operand:define(OperandType.FPURegister, DataType.UInt8)

function FdOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x000007C0), 0x06)
end

------------------------
-- MIPS COP0 Operands --
------------------------
local Cop0RsOperand = Operand:define(OperandType.COP0Register, DataType.UInt8)

function Cop0RsOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)
end

local Cop0RtOperand = Operand:define(OperandType.COP0Register, DataType.UInt8)

function Cop0RtOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local Cop0RdOperand = Operand:define(OperandType.COP0Register, DataType.UInt8)

function Cop0RdOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

------------------------
-- MIPS COP2 Operands --
------------------------

-- Data Registers --
local Cop2DataRsOperand = Operand:define(OperandType.COP2DataRegister, DataType.UInt8)

function Cop2DataRsOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)
end

local Cop2DataRtOperand = Operand:define(OperandType.COP2DataRegister, DataType.UInt8)

function Cop2DataRtOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local Cop2DataRdOperand = Operand:define(OperandType.COP2DataRegister, DataType.UInt8)

function Cop2DataRdOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

-- Control Registers --

local Cop2ControlRsOperand = Operand:define(OperandType.COP2ControlRegister, DataType.UInt8)

function Cop2ControlRsOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x03E00000), 0x15)
end

local Cop2ControlRtOperand = Operand:define(OperandType.COP2ControlRegister, DataType.UInt8)

function Cop2ControlRtOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x001F0000), 0x10)
end

local Cop2ControlRdOperand = Operand:define(OperandType.COP2ControlRegister, DataType.UInt8)

function Cop2ControlRdOperand:__ctor(data)
  self.value = bit.rshift(bit.band(data, 0x0000F800), 0x0B)
end

return { rs = RsOperand, rt = RtOperand, rd = RdOperand,
         shamt = ShamtOperand, imm16 = Imm16Operand, target = TargetOperand, offset = OffsetOperand, memory = MemoryOperand,
         op = CacheOpOperand, cofun = CoFunOperand, baseindex = BaseIndexOperand, code = CodeOperand,
         ft = FtOperand, fs = FsOperand, fd = FdOperand,
         cop0rs = Cop0RsOperand, cop0rt = Cop0RtOperand, cop0rd = Cop0RdOperand,
         cop2datars = Cop2DataRsOperand, cop2datart = Cop2DataRtOperand, cop2datard = Cop2DataRdOperand,
         cop2ctrlrs = Cop2ControlRsOperand, cop2ctrlrt = Cop2ControlRtOperand, cop2ctrlrd = Cop2ControlRdOperand }
