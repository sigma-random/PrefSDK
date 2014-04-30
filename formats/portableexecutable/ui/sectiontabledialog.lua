local oop = require("sdk.lua.oop")
local Dialog = require("sdk.ui.dialog")
local TableWidget = require("sdk.ui.tablewidget")
local VerticalLayout = require("sdk.ui.layout.verticallayout")

local SectionTableDialog = oop.class(Dialog)

function SectionTableDialog:__ctor(formattree)
  Dialog.__ctor(self, "Section Table")

  local vlayout = VerticalLayout()
  local tablewidget = TableWidget()  
  
  local ntheaders = formattree.NtHeaders
  local sectiontable = formattree.SectionTable
  local numberofsections = ntheaders.FileHeader.NumberOfSections:value()
  
  tablewidget:setColumnCount(6)
  tablewidget:setRowCount(numberofsections)
  tablewidget:setHeaderItems({"Name", "VirtualAddress", "VirtualSize", "PointerToRawData", "SizeOfRawData", "Characteristics"})
  
  for i = 1, numberofsections do
    local section = sectiontable["Section" .. i]
    
    tablewidget:setItem(i, 1, section.Name:value())
    tablewidget:setItem(i, 2, string.format("%08X", tonumber(section.VirtualAddress:value())))
    tablewidget:setItem(i, 3, string.format("%08X", tonumber(section.VirtualSize:value())))
    tablewidget:setItem(i, 4, string.format("%08X", tonumber(section.PointerToRawData:value())))
    tablewidget:setItem(i, 5, string.format("%08X", tonumber(section.SizeOfRawData:value())))
    tablewidget:setItem(i, 6, string.format("%08X", tonumber(section.Characteristics:value())))
  end
  
  vlayout:setMargins(0, 0, 0, 0)
  vlayout:addWidget(tablewidget)
  self:setLayout(vlayout)
  self:resize(540, 330)
end

return SectionTableDialog