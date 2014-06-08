local ffi = require("ffi")

ffi.cdef
[[
  const int InstructionType_Undefined;
  const int InstructionType_InterruptTrap;
  const int InstructionType_Privileged;
  const int InstructionType_Nop;
  const int InstructionType_Stop;
  const int InstructionType_Call;
  const int InstructionType_Jump;
  const int InstructionType_ConditionalCall;
  const int InstructionType_ConditionalJump;
  const int InstructionType_Push;
  const int InstructionType_Pop;
  const int InstructionType_Add;
  const int InstructionType_Sub;
  const int InstructionType_Mul;
  const int InstructionType_Div;
  const int InstructionType_Mod;
  const int InstructionType_AddCarry;
  const int InstructionType_SubCarry;
  const int InstructionType_Asl;
  const int InstructionType_Asr;
  const int InstructionType_And;
  const int InstructionType_Or;
  const int InstructionType_Xor;
  const int InstructionType_Not;
  const int InstructionType_Lsl;
  const int InstructionType_Lsr;
  const int InstructionType_Rol;
  const int InstructionType_Ror;
  const int InstructionType_RolCarry;
  const int InstructionType_RorCarry;
  const int InstructionType_In;
  const int InstructionType_Out;
]]

local C = ffi.C
local InstructionType = { Undefined       = C.InstructionType_Undefined,
                          InterruptTrap   = C.InstructionType_InterruptTrap,
                          Privileged      = C.InstructionType_Privileged,
                          Nop             = C.InstructionType_Nop,
                          Stop            = C.InstructionType_Stop,
                          Call            = C.InstructionType_Call,
                          Jump            = C.InstructionType_Jump,
                          ConditionalCall = C.InstructionType_ConditionalCall,
                          ConditionalJump = C.InstructionType_ConditionalJump,
                          Push            = C.InstructionType_Push,
                          Pop             = C.InstructionType_Pop,
                          Add             = C.InstructionType_Add,
                          Sub             = C.InstructionType_Sub,
                          Mul             = C.InstructionType_Mul,
                          Div             = C.InstructionType_Div,
                          Mod             = C.InstructionType_Mod,
                          AddCarry        = C.InstructionType_AddCarry,
                          SubCarry        = C.InstructionType_SubCarry,
                          Asl             = C.InstructionType_Asl,
                          Asr             = C.InstructionType_Asr,
                          And             = C.InstructionType_And,
                          Or              = C.InstructionType_Or,
                          Xor             = C.InstructionType_Xor,
                          Not             = C.InstructionType_Not,
                          Lsl             = C.InstructionType_Lsl,
                          Lsr             = C.InstructionType_Lsr,
                          Rol             = C.InstructionType_Rol,
                          Ror             = C.InstructionType_Ror,
                          RolCarry        = C.InstructionType_RolCarry,
                          RorCarry        = C.InstructionType_RorCarry,
                          In              = C.InstructionType_In,
                          Out             = C.InstructionType_Out }

return InstructionType
