local ffi = require("ffi")

ffi.cdef
[[
  const int InstructionFeatures_Stop;
  const int InstructionFeatures_Call;
  const int InstructionFeatures_Change1;
  const int InstructionFeatures_Change2;
  const int InstructionFeatures_Change3;
  const int InstructionFeatures_Change4;
  const int InstructionFeatures_Change5;
  const int InstructionFeatures_Change6;
  const int InstructionFeatures_Use1;
  const int InstructionFeatures_Use2;
  const int InstructionFeatures_Use3;
  const int InstructionFeatures_Use4;
  const int InstructionFeatures_Use5;
  const int InstructionFeatures_Use6;
  const int InstructionFeatures_Jump;
  const int InstructionFeatures_Shift;
]]

local C = ffi.C
local InstructionFeatures = { Stop    = C.InstructionFeatures_Stop,
                              Call    = C.InstructionFeatures_Call,
                              Change1 = C.InstructionFeatures_Change1,
                              Change2 = C.InstructionFeatures_Change2,
                              Change3 = C.InstructionFeatures_Change3,
                              Change4 = C.InstructionFeatures_Change4,
                              Change5 = C.InstructionFeatures_Change5,
                              Change6 = C.InstructionFeatures_Change6,
                              Use1    = C.InstructionFeatures_Use1,
                              Use2    = C.InstructionFeatures_Use2,
                              Use3    = C.InstructionFeatures_Use3,
                              Use4    = C.InstructionFeatures_Use4,
                              Use5    = C.InstructionFeatures_Use5,
                              Use6    = C.InstructionFeatures_Use6,
                              Jump    = C.InstructionFeatures_Jump,
                              Shift   = C.InstructionFeatures_Shift }

return InstructionFeatures