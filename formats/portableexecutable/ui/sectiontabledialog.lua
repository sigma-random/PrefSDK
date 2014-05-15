local oop = require("sdk.lua.oop")
local Dialog = require("sdk.ui.dialog")
local TableWidget = require("sdk.ui.tablewidget")
local VerticalLayout = require("sdk.ui.layout.verticallayout")

local SectionTableDialog = oop.class(Dialog)

function SectionTableDialog:__ctor(formattree)
  Dialog.__ctor(self, "Section Table")
  
  local ntheaders = formattree.NtHeaders
  local sectiontable = formattree.SectionTable
  local numberofsections = ntheaders.FileHeader.NumberOfSections:value()
  
  local vlayout = VerticalLayout()
  local tablewidget = TableWidget(numberofsections, 6)
  tablewidget:setHeaderItems({"Name", "VirtualAddress", "VirtualSize", "PointerToRawData", "SizeOfRawData", "Characteristics"})
  
  for i = 1, numberofsections do
    local section = sectiontable["Section" .. i]

    tablewidget:setItem(i, 1, section.Name)
    tablewidget:setItem(i, 2, section.VirtualAddress)
    tablewidget:setItem(i, 3, section.VirtualSize)
    tablewidget:setItem(i, 4, section.PointerToRawData)
    tablewidget:setItem(i, 5, section.SizeOfRawData)
    tablewidget:setItem(i, 6, section.Characteristics)
  end
  
  vlayout:setMargins(4, 4, 4, 4)
  vlayout:addWidget(tablewidget)
  self:setLayout(vlayout)
  self:resize(550, 300)
end

return SectionTableDialog