local oop = require("sdk.lua.oop")
local TableWidget = require("sdk.ui.tablewidget")

local SectionTableView = oop.class(TableWidget)

function SectionTableView:__ctor(formattree)
  TableWidget.__ctor(self, "Section Table")
  
  local ntheaders = formattree.NtHeaders
  local sectiontable = formattree.SectionTable
  local numberofsections = ntheaders.FileHeader.NumberOfSections:value()
  
  self:setColumnCount(6)
  self:setRowCount(numberofsections)
  self:setHeaderItems({"Name", "VirtualAddress", "VirtualSize", "PointerToRawData", "SizeOfRawData", "Characteristics"})
  
  for i = 1, numberofsections do
    local section = sectiontable["Section" .. i]
     
    self:setItem(i, 1, section.Name:value())
    self:setItem(i, 2, string.format("%08X", tonumber(section.VirtualAddress:value())))
    self:setItem(i, 3, string.format("%08X", tonumber(section.VirtualSize:value())))
    self:setItem(i, 4, string.format("%08X", tonumber(section.PointerToRawData:value())))
    self:setItem(i, 5, string.format("%08X", tonumber(section.SizeOfRawData:value())))
    self:setItem(i, 6, string.format("%08X", tonumber(section.Characteristics:value())))
  end
end

return SectionTableView