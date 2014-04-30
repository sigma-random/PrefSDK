local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Widget = require("sdk.ui.widget")

ffi.cdef
[[
  void* TableWidget_create();
  void TableWidget_setColumnCount(void* __this, int count);
  void TableWidget_setRowCount(void* __this, int count);
  void TableWidget_setHeaderItem(void *__this, int column, const char* text);
  void TableWidget_setItem(void*__this, int row, int column, const char* text);
]]

local C = ffi.C
local TableWidget = oop.class(Widget)

function TableWidget:__ctor()
  Widget.__ctor(self, C.TableWidget_create())
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
