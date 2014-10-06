local pref = require("pref")

local PointerMeta = { }

function PointerMeta.__tostring(table)
  return string.format("%X", rawget(table, "address"))
end

function PointerMeta.__len(table)
  return pref.datatype.sizeof(rawget(table, "datatype"))
end

function PointerMeta.__index(table, key)
  assert(type(key) == "number", "j = Pointer[i] expects a number")
  
  local address = rawget(table, "address") + (key * pref.datatype.sizeof(rawget(table, "datatype")))
  return rawget(table, "databuffer"):readType(address, rawget(table, "datatype"))
end

function PointerMeta.__newindex(table, key, value)
  assert((type(key) == "number") and (type(value) == "number"), "Pointer[i] = j expects a number")
  
  local address = rawget(table, "address") + (key * pref.datatype.sizeof(rawget(table, "datatype")))
  rawget(table, "databuffer"):writeType(address, rawget(table, "datatype"), value)
end

function PointerMeta.__add(table, base, span)
  assert((type(base) == "number") and (type(span) == "number"), "Pointer[i] += j expects a number")
  
  local address = base + (span * pref.datatype.sizeof(rawget(table, "datatype")))
  rawset(table, "address", address)
  return table
end

function PointerMeta.__sub(table, base, span)
  assert((type(base) == "number") and (type(span) == "number"), "Pointer[i] -= j expects a number")
  
  local address = base - (span * pref.datatype.sizeof(rawget(table, "datatype")))
  rawset(table, "address", address)
  return table
end

function Pointer(address, datatype, databuffer)
  local o = setmetatable({ }, PointerMeta)
  
  rawset(o, "address", address)
  rawset(o, "datatype", datatype)
  rawset(o, "databuffer", databuffer)
  rawset(o, "value", function(self) return self[0] end) -- Syntax Sugar
    
  return o
end

return Pointer