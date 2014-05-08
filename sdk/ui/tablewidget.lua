local ffi = require("ffi")
local oop = require("sdk.lua.oop")
local Widget = require("sdk.ui.widget")

ffi.cdef
[[
  void* TableWidget_create(int rows, int columns);
  void TableWidget_setHeaderItem(void*__this, int column, const char* text);
  void TableWidget_setItemElement(void*__this, int row, int column, void* element);
  void TableWidget_setItemString(void*__this, int row, int column, const char* s);
]]

local C = ffi.C
local TableWidget = oop.class(Widget)

function TableWidget:__ctor(rows, columns)
  Widget.__ctor(self, C.TableWidget_create(rows, columns))
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

function TableWidget:setItem(row, column, item)
  if type(item) == "string" then
    C.TableWidget_setItemString(self.cthis, row - 1, column - 1, item)
  elseif type(item) == "table" then
    C.TableWidget_setItemElement(self.cthis, row - 1, column - 1, item._cthis)
  else
    error("TableWidget:setItem(): Unsupported Type")
  end
end

return TableWidget
