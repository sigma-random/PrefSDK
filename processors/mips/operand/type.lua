local oop = require("oop")

local OperandType = { Undefined = 0, Immediate = 1, Address = 2, Offset = 3, Memory = 4, BaseIndex = 5,
                      Register = 6, FPURegister = 7, COP0Register = 8, COP2DataRegister = 9, COP2ControlRegister = 10,
                      Code = 11 }

return OperandType
