local getinfo, error, rawset, rawget = debug.getinfo, error, rawset, rawget

local mt = getmetatable(_G)

if mt == nil then
  mt = { }
  setmetatable(_G, mt)
end

mt.__declared = { }

local function what()
  local d = getinfo(3, "S")
  return d and d.what or "C"
end
  
function mt.__newindex(t, n, v)
  if not mt.__declared[n] then
    local w = what()
    
    if w ~= "main" and w ~= "C" then
      error("assign to undeclared variable '"..n.."'", 2)
    end
    
  mt.__declared[n] = true
  end
  
  rawset(t, n, v)
end

function mt.__index(t, n)
  if not mt.__declared[n] and what() ~= "C" then
    error("variable '"..n.."' is not declared", 2)
  end
  
  return rawget(t, n)
end