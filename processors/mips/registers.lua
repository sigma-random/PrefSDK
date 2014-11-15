local MipsGPR = { [0]  = "zero", [1]  = "at", [2]  = "v0", [3]  = "v1", [4]  = "a0", [5]  = "a1",
                  [6]  = "a2",   [7]  = "a3", [8]  = "t0", [9]  = "t1", [10] = "t2", [11] = "t3",
                  [12] = "t4",   [13] = "t5", [14] = "t6", [15] = "t7", [16] = "s0", [17] = "s1", 
                  [18] = "s2",   [19] = "s3", [20] = "s4", [21] = "s5", [22] = "s6", [23] = "s7", 
                  [24] = "t8",   [25] = "t9", [26] = "k0", [27] = "k1", [28] = "gp", [29] = "sp",
                  [30] = "fp",   [31] = "ra" }

local Cop0Registers = { [0]  = "Index",    [1]  = "Random",   [2]  = "EntryLo0", [3]  = "EntryLo1",
                        [4]  = "Context",  [5]  = "PageMask", [6]  = "Wired",    [7]  = "DcIc", 
                        [8]  = "BadVaddr", [9]  = "Count",    [10] = "EntryHi",  [11] = "Compare",
                        [12] = "Status",   [13] = "Cause",    [14] = "ExceptPC", [15] = "PrevID",
                        [16] = "Config",   [17] = "LLAddr",   [18] = "WatchLo",  [19] = "WatchHi",
                        [20] = "XContext", [21] = "Res1",     [22] = "Res2",     [23] = "Res3",
                        [24] = "Res4",     [25] = "Res5",     [26] = "PErr",     [27] = "CacheErr",
                        [28] = "TagLo",    [29] = "TagHi",    [30] = "ErrorEPC", [31] = "Res6" }
                  
return { gpr = MipsGPR, cop0 = Cop0Registers }