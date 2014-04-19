local CType = { }

function CType.isAscii(ch)
  if (ch >= 0x00) and (ch <= 0x7F) then
    return true
  end
  
  return false
end

function CType.isGraph(ch)
  if (ch >= 0x21) and (ch <= 0x7E) then
    return true
  end
  
  return false
end

function CType.isPunct(ch)
  if ((ch >= 0x21) and (ch <= 0x2D)) or ((ch >= 0x3A) and (ch <= 0x40)) or ((ch >= 0x5B) and (ch <= 0x60)) or ((ch >= 0x7B) and (ch <= 0x7E))then
    return true
  end
  
  return false
end

function CType.isAlpha(ch)
  if ((ch >= 0x41) and (ch <= 0x5A)) or ((ch >= 0x61) and (ch <= 0x7A)) then
    return true
  end
  
  return false
end

function CType.isDigit(ch)
  if (ch >= 0x30) and (ch <= 0x39) then
    return true
  end
  
  return false
end

function CType.isAlnum(ch)
  if isAlpha(ch) or isDigit(ch) then
    return true
  end
  
  return false
end

function CType.isGraph(ch)
  if (ch >= 0x21) and (ch <= 0x7E) then
    return true
  end
  
  return false
end

function CType.isWhite(ch)
  if (ch == 0x20) or (ch == 0x09) or (ch == 0x0D) or (ch == 0x0A) then
    return true
  end
  
  return false
end

function CType.isPrint(ch)
  if CType.isAlnum(ch) or CType.isPunct(ch) or CType.isWhite(ch) then
    return true
  end
  
  return false
end

return CType