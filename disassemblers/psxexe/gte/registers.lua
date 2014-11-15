-- GTE Documentation From: https://code.google.com/p/pops-gte/source/browse/trunk/docs/gte.txt

local GTERegisters = { } -- PSX's COP2 Coprocessor is the GTE

GTERegisters.control = { [0] = "R11R12",  [1]  = "R13R21", [2]  = "R22R23", [3]  = "R31R32", [4]  = "R33",    [5]  = "TRX",
                         [6] = "TRY",     [7]  = "TRZ",    [8]  = "L11L12", [9]  = "L13L21", [10] = "L22L23", [11] = "L31L32",
                         [12] = "L33",    [13] = "RBK",    [14] = "GBK",    [15] = "BBK",    [16] = "LR1LR2", [17] = "LR3LG1",
                         [18] = "LG2LG3", [19] = "LB1LB2", [20] = "LB3",    [21] = "RFC",    [22] = "GFC",    [23] = "BFC",
                         [24] = "OFX",    [25] = "OFY",    [26] = "H",      [27] = "DQA",    [28] = "DQB",    [29] = "ZSF3", 
                         [30] = "ZSF4",   [31] = "FLAG" }

GTERegisters.data = { [0] = "VXY0",  [1]  = "VZ0",  [2]  = "VXY1", [3]  = "VZ1",  [4]  = "VXY2", [5]  = "VZ2",  [6]  = "RGB",  [7]  = "OTZ",
                      [8] = "IR0",   [9]  = "IR1",  [10] = "IR2",  [11] = "IR3",  [12] = "SXY0", [13] = "SXY1", [14] = "SXY2", [15] = "SXYP",
                      [16] = "SZ0",  [17] = "SZ1",  [18] = "SZ2",  [19] = "SZ3",  [20] = "RGB0", [21] = "RGB1", [22] = "RGB2", [23] = "RES1",
                      [24] = "MAC0", [25] = "MAC1", [26] = "MAC2", [27] = "MAC3", [28] = "IRGB", [29] = "ORGB", [30] = "LZCS", [31] = "LZCR" }

return GTERegisters