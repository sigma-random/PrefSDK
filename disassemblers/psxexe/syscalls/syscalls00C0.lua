-- From: http://problemkaputt.de/psx-spx.htm#biosfunctionsummary

local SysCallsC0 = { }

SysCallsC0[0x00000000] = "EnqueueTimerAndVblankIrqs"
SysCallsC0[0x00000001] = "EnqueueSyscallHandler"
SysCallsC0[0x00000002] = "SysEnqIntRP"
SysCallsC0[0x00000003] = "SysDeqIntRP"
SysCallsC0[0x00000004] = "get_free_EvCB_slot"
SysCallsC0[0x00000005] = "get_free_TCB_slot"
SysCallsC0[0x00000006] = "ExceptionHandler"
SysCallsC0[0x00000007] = "InstallExceptionHandlers"
SysCallsC0[0x00000008] = "SysInitMemory"
SysCallsC0[0x00000009] = "SysInitKernelVariables"
SysCallsC0[0x0000000A] = "ChangeClearRCnt"
SysCallsC0[0x0000000B] = "SystemError"               -- PS2: return 0
SysCallsC0[0x0000000C] = "InitDefInt"
SysCallsC0[0x0000000D] = "SetIrqAutoAck"
-- SysCallsC0[0x0000000E] = "return 0"               -- DTL-H2000: dev_sio_init
-- SysCallsC0[0x0000000F] = "return 0"               -- DTL-H2000: dev_sio_open
-- SysCallsC0[0x00000010] = "return 0"               -- DTL-H2000: dev_sio_in_out
-- SysCallsC0[0x00000011] = "return 0"               -- DTL-H2000: dev_sio_ioctl
SysCallsC0[0x00000012] = "InstallDevices"
SysCallsC0[0x00000013] = "FlushStdInOutPut"
-- SysCallsC0[0x00000014] = "return 0"               -- DTL-H2000: SystemError
SysCallsC0[0x00000015] = "tty_cdevinput"
SysCallsC0[0x00000016] = "tty_cdevscan"
SysCallsC0[0x00000017] = "tty_circgetc"
SysCallsC0[0x00000018] = "tty_circputc"
SysCallsC0[0x00000019] = "ioabort"
SysCallsC0[0x0000001A] = "set_card_find_mode"
SysCallsC0[0x0000001B] = "KernelRedirect"
SysCallsC0[0x0000001C] = "AdjustA0Table"
SysCallsC0[0x0000001D] = "get_card_find_mode"
-- SysCallsC0[0x0000001Eh..7F] = "N/A" -- jump_to_00000000h
-- SysCallsC0[0x00000080] = "N/A" -- mirrors to B(00h.....)

return SysCallsC0
