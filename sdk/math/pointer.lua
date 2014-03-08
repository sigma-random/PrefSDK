local Pointer = { }

function Pointer:new(value, datatype, buffer)
  local o = setmetatable({ }, Pointer)
  
  rawset(o, "value", value)
  rawset(o, "ptype", datatype)
  rawset(o, "buffer", buffer)
  return o
end

function Pointer.__tostring(table)
  return string.format("%X", rawget(table, "value"))
end

function Pointer.__len(table)
  return DataType.sizeOf(rawget(table, "ptype"))
end

function Pointer.__index(table, key)
  assert(type(key) == "number", "Pointer[i] expects a number")
  
  local value = rawget(table, "value") + (key * DataType.sizeOf(rawget(table, "ptype")))
  return rawget(table, "buffer"):readType(value, rawget(table, "ptype"))
end

function Pointer.__newindex(table, key, value)
  assert((type(key) == "number") and (type(value) == "number"), "Pointer[i] = j expects a number")
  
  local value = rawget(table, "value") + (key * DataType.sizeOf(rawget(table, "ptype")))
  rawget(table, "buffer"):write(value, rawget(table, "ptype"), value)
end

function Pointer.__add(table, base, span)
  assert((type(base) == "number") and (type(span) == "number"), "Pointer[i] = j expects a number")
  
  local value = base + (span * DataType.sizeOf(rawget(table, "ptype")))
  rawset(table, "value", value)
  return table
end

function Pointer.__sub(table, base, span)
  assert((type(base) == "number") and (type(span) == "number"), "Pointer[i] = j expects a number")
  
  local value = base - (span * DataType.sizeOf(rawget(table, "ptype")))
  rawset(table, "value", value)
  return table
end

return Pointer