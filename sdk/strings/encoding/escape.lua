function unescape(ch, str)
  str = string.gsub(str, ch .. "(%x%x)", function(hexchar) return string.char(tonumber(hexchar, 16)) end)
  return str
end