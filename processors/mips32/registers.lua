local pref = require("pref")

local Mips32Registers = pref.disassembler.createregisterset(pref.datatype.UInt32)

Mips32Registers[0] = "zero"
Mips32Registers[1] = "at"
Mips32Registers[2] = "v0"
Mips32Registers[3] = "v1"
Mips32Registers[4] = "a0"
Mips32Registers[5] = "a1"
Mips32Registers[6] = "a2"
Mips32Registers[7] = "a3"
Mips32Registers[8] = "t0"
Mips32Registers[9] = "t1"
Mips32Registers[10] = "t2"
Mips32Registers[11] = "t3"
Mips32Registers[12] = "t4"
Mips32Registers[13] = "t5"
Mips32Registers[14] = "t6"
Mips32Registers[15] = "t7"
Mips32Registers[16] = "s0"
Mips32Registers[17] = "s1"
Mips32Registers[18] = "s2"
Mips32Registers[19] = "s3"
Mips32Registers[20] = "s4"
Mips32Registers[21] = "s5"
Mips32Registers[22] = "s6"
Mips32Registers[23] = "s7"
Mips32Registers[24] = "t8"
Mips32Registers[25] = "t9"
Mips32Registers[26] = "k0"
Mips32Registers[27] = "k1"
Mips32Registers[28] = "gp"
Mips32Registers[29] = "sp"
Mips32Registers[30] = "fp"
Mips32Registers[31] = "ra"

return Mips32Registers