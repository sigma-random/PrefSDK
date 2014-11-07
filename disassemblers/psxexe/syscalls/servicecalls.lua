-- From: http://problemkaputt.de/psx-spx.htm 

local ServiceCalls = { }

ServiceCalls[0x00] = "NoFunction"
ServiceCalls[0x01] = "EnterCriticalSection"
ServiceCalls[0x02] = "ExitCriticalSection"
ServiceCalls[0x03] = "ChangeThreadSubFunction"
ServiceCalls[0x04] = "DeliverEvent"

return ServiceCalls