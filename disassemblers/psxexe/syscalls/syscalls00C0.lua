-- From: 
-- http://problemkaputt.de/psx-spx.htm#biosfunctionsummary
-- https://pcsxr.codeplex.com/SourceControl/latest#pcsxr/libpcsxcore/psxbios.h
-- https://pcsxr.codeplex.com/SourceControl/latest#pcsxr/libpcsxcore/psxbios.c

local SysCalls00C0 = { }

SysCalls00C0[0x00] = "InitRCnt"
SysCalls00C0[0x01] = "InitException"
SysCalls00C0[0x02] = "SysEnqIntRP"
SysCalls00C0[0x03] = "SysDeqIntRP"
SysCalls00C0[0x04] = "get_free_EvCB_slot"
SysCalls00C0[0x05] = "get_free_TCB_slot"
SysCalls00C0[0x06] = "ExceptionHandler"
SysCalls00C0[0x07] = "InstallExeptionHandler"
SysCalls00C0[0x08] = "SysInitMemory"
SysCalls00C0[0x09] = "SysInitKMem"
SysCalls00C0[0x0A] = "ChangeClearRCnt"
SysCalls00C0[0x0B] = "SystemError"
SysCalls00C0[0x0C] = "InitDefInt"
SysCalls00C0[0x0D] = "sys_c0_0d"
SysCalls00C0[0x0E] = "sys_c0_0e"
SysCalls00C0[0x0F] = "sys_c0_0f"
SysCalls00C0[0x10] = "sys_c0_10"
SysCalls00C0[0x11] = "sys_c0_11"
SysCalls00C0[0x12] = "InstallDevices"
SysCalls00C0[0x13] = "FlushStfInOutPut"
SysCalls00C0[0x14] = "sys_c0_14"
SysCalls00C0[0x15] = "_cdevinput"
SysCalls00C0[0x16] = "_cdevscan"
SysCalls00C0[0x17] = "_circgetc"
SysCalls00C0[0x18] = "_circputc"
SysCalls00C0[0x19] = "ioabort"
SysCalls00C0[0x1A] = "sys_c0_1a"
SysCalls00C0[0x1B] = "KernelRedirect"
SysCalls00C0[0x1C] = "PatchAOTable"

return SysCalls00C0