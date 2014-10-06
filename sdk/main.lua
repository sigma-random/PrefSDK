require("sdk.strict")
require("sdk.lua.table") -- Add Table Enhancements

local pref = require("pref")

-- Notify PrefSDK's version.
pref.setSdkVersion(1, 5, 0)

-- function Sdk.errorDialog(obj)
--   if type(obj) == "string" then
--     C.Debug_showDialog(obj)
--   elseif type(obj) == "number" then
--     C.Debug_showDialog(tostring(obj))
--   elseif type(obj) == "table" then
--     local tableoutput = "Table:\n"
--     
--     for k,v in pairs(obj) do
--       tableoutput = tableoutput .. string.format("%s = %s", k, v)
--     end
--     
--     C.Debug_showDialog(tableoutput)
--   else
--     C.Debug_showDialog("Unupported Type: '" .. type(obj) .. "'")
--   end
-- end