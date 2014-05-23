local oop = require("sdk.lua.oop")
local Dialog = require("sdk.ui.dialog")
local TableWidget = require("sdk.ui.tablewidget")
local VerticalLayout = require("sdk.ui.layout.verticallayout")

local ExportTableDialog = oop.class(Dialog)

function ExportTableDialog:__ctor(exportdirectory, formattree)
  Dialog.__ctor(self, "Export Table")
  
  local ntheaders = formattree.NtHeaders
  local exportedfunctions = formattree.ExportedFunctions
  
  for i = 1, exportedfunctions:fieldCount() do
    
  end
  
end