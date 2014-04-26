local DataType = require("sdk.types.datatype")

local PointerMeta = { }

function PointerMeta.__tostring(table)
  return string.format("%X", rawget(table, "address"))
end

function PointerMeta.__len(table)
  return DataType.sizeOf(rawget(table, "datatype"))
end

function PointerMeta.__index(table, key)
  assert(type(key) == "number", "j = Pointer[i] expects a number")
  
  local address = rawget(table, "address") + (key * DataType.sizeOf(rawget(table, "datatype")))
  return rawget(table, "databuffer"):readType(address, rawget(table, "datatype"))
end

function PointerMeta.__newindex(table, key, value)
  assert((type(key) == "number") and (type(value) == "number"), "Pointer[i] = j expects a number")
  
  local address = rawget(table, "address") + (key * DataType.sizeOf(rawget(table, "datatype")))
  rawget(table, "databuffer"):writeType(address, rawget(table, "datatype"), value)
end

function PointerMeta.__add(table, base, span)
  assert((type(base) == "number") and (type(span) == "number"), "Pointer[i] += j expects a number")
  
  local address = base + (span * DataType.sizeOf(rawget(table, "datatype")))
  rawset(table, "address", address)
  return table
end

function PointerMeta.__sub(table, base, span)
  assert((type(base) == "number") and (type(span) == "number"), "Pointer[i] -= j expects a number")
  
  local address = base - (span * DataType.sizeOf(rawget(table, "datatype")))
  rawset(table, "address", address)
  return table
end

function Pointer(address, datatype, databuffer)
  local self = setmetatable({ }, PointerMeta)
  
  rawset(self, "address", address)
  rawset(self, "datatype", datatype)
  rawset(self, "databuffer", databuffer)
  
  return self
end

return Pointer