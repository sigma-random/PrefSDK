local PeConstants = { NumberOfDirectoryEntries = 15,
                      ImageResourceNameIsString = { [32] = 0x80000000, [64] = 0x8000000000000000 },
                      ImageResourceDataIsDirectory = { [32] = 0x80000000, [64] = 0x8000000000000000 },
                      ImageOrdinalFlag = { [32] = 0x80000000, [64] = 0x8000000000000000 },
                      ImageOptionalHeaderMagic = { [0x10B] = "32 Bit PE", [0x20B] = "64 Bit PE", [0x107] = "ROM" }, 
                      
                      Section = { Code = 0x00000020, InitializedData = 0x00000040, UninitializedData = 0x00000080, 
                                  Shared = 0x10000000, Execute = 0x20000000, Read = 0x40000000, Write = 0x80000000 },
                        
                      DirectoryNames = { [1]  = "ExportDirectory",    [2]  = "ImportDirectory",             [3]  = "ResourceDirectory",
                                         [4]  = "ExceptionDirectory", [5]  = "SecurityDirectory",           [6]  = "BaseRelocationDirectory",
                                         [7]  = "DebugDirectory",     [8]  = "ArchDataDirectory",           [9]  = "GlobalPtrDirectory",
                                         [10] = "TlsDirectory",       [11] = "LoadConfigurationDirectory",  [12] = "BoundImportTableDirectory",
                                         [13] = "IatDirectory",       [14] = "DelayImportDirectory",        [15] = "ComDirectory" }, 

                      ImageFileMachine = { [0x14C] = "Intel i386",           [0x160] = "MIPS (Big Endian)",           [0x162] = "MIPS (Little Endian)",
                                           [0x166] = "MIPS (Little Endian)", [0x168] = "MIPS (Little Endian)",        [0x169] = "MIPS (Little Endian) WCE v2",  
                                           [0x184] = "Alpha",                [0x1F0] = "IBM PowerPC (Little Endian)", [0x1A2] = "SH3 (Little Endian)",
                                           [0x1A4] = "SH3E (Little Endian)", [0x1A6] = "SH4 (Little Endian)",         [0x1C0] = "ARM (Little Endian)", 
                                           [0x1C2] = "Thumb",                [0x200] = "Intel 64",                    [0x266] = "MIPS",  
                                           [0x366] = "MIPS",                 [0x466] = "MIPS",                        [0x284] = "Alpha 64" },

                      ResourceDirectoryId = { [1]  = "CURSORS",         [2]  = "BITMAPS",        [3]  = "ICONS",       [4]  = "MENUS",        [5]  = "DIALOGS",
                                              [6]  = "STRING TABLES",   [7]  = "FONT DIRECTORY", [8]  = "FONTS",       [9]  = "ACCELERATORS", [10] = "RCDATA",
                                              [11] = "MESSAGE TABLES",  [12] = "CURSOR GROUPS",  [14] = "ICON GROUPS", [16] = "VERSION INFO", [23] = "HTML PAGES", 
                                              [24] = "CONFIGURATION FILES" } }
                                   
return PeConstants