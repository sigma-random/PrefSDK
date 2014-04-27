local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local PrefWidget = require("sdk.ui.prefwidget")

ffi.cdef
[[
  void* PrefUI_createTableWidget(const char* title);
  void TableWidget_setColumnCount(void* __this, int count);
  void TableWidget_setRowCount(void* __this, int count);
  void TableWidget_setHeaderItem(void *__this, int column, const char* text);
  void TableWidget_setItem(void*__this, int row, int column, const char* text);
]]

local C = ffi.C
local TableWidget = oop.class(PrefWidget)

function TableWidget:__ctor(title)
  PrefWidget.__ctor(self, C.PrefUI_createTableWidget(title))
end

function TableWidget:setColumnCount(count)
  C.TableWidget_setColumnCount(self.cthis, count)
end

function TableWidget:setRowCount(count)
  C.TableWidget_setRowCount(self.cthis, count)
end

function TableWidget:setHeaderItems(values)
  for i,v in ipairs(values) do
    self:setHeaderItem(i, v)
  end
end

function TableWidget:setHeaderItem(column, value)
  C.TableWidget_setHeaderItem(self.cthis, column - 1, value)
end

function TableWidget:setItems(row, values)
  for i,v in ipairs(values) do
    self:setItem(row, i, v)
  end
end

function TableWidget:setItem(row, column, value)
  C.TableWidget_setItem(self.cthis, row - 1, column - 1, value)
end

return TableWidget
