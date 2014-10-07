local pref = require("pref")
local PdfTypes = require("formats.pdf.pdftypes")

local PdfFunctions = { filepos = 0, errorstate = false }

function PdfFunctions.findAllKeywords(formatdefinition, buffer)
  local objtable = { }
  local i = 1
  
  PdfFunctions.filepos = 0 -- Reset File Cursor
  PdfFunctions.errorstate = false
  
  while (not PdfFunctions.errorstate) and (PdfFunctions.filepos < buffer.length) do
    local ch = string.char(buffer[PdfFunctions.filepos])
    local t = nil -- Single PdfObject (if any)
    
    if PdfFunctions.isWhitespace(ch) then
      t = PdfFunctions.createWhitespaceObj(buffer)
    elseif (ch == '%') then
      t = PdfFunctions.createCommentObj(buffer)
    elseif (ch >= '0') and (ch <= '9') then
      t = PdfFunctions.createObjObj(formatdefinition, buffer)
    elseif (ch == 'x') and (buffer:readString(PdfFunctions.filepos, 4) == "xref") then
      t = PdfFunctions.createXRefObj(formatdefinition, buffer)
    else
      formatdefinition:error("Unknown Character: '" .. ch .. "' at offset: " .. tostring(PdfFunctions.filepos))
    end
    
    if t ~= nil then
      objtable[i] = t
      i = i + 1
    end
  end
  
  return objtable
end

function PdfFunctions.createPdfObject(objtype, objpos)
  return { type = objtype, startpos = objpos, endpos = objpos }
end

function PdfFunctions.indexOfEol(buffer, startpos)
  local cr = buffer:indexOf("\r", startpos)
  local lf = buffer:indexOf("\n", startpos)
      
  if cr ~= -1 and lf ~= -1 then
    return math.min(cr, lf)
  elseif cr == -1 and lf ~= -1 then
    return lf
  elseif cr ~= -1 and lf == -1 then
    return cr
  end
  
  return -1
end

function PdfFunctions.isWhitespace(ch)
  if type(ch) ~= "string" then
    ch = string.char(ch)
  end
  
  return ((ch == '\r') or (ch == '\n') or (ch == '\t') or (ch == ' '))
end

function PdfFunctions.eatWhitespaces(buffer)
  while (PdfFunctions.filepos < buffer.length) and PdfFunctions.isWhitespace(buffer[PdfFunctions.filepos]) do
    PdfFunctions.filepos = PdfFunctions.filepos + 1
  end
end

function PdfFunctions.createWhitespaceObj(buffer)
  local obj = PdfFunctions.createPdfObject(PdfTypes.PdfWhitespace, PdfFunctions.filepos)
  
  PdfFunctions.eatWhitespaces(buffer)
  obj.endpos = PdfFunctions.filepos
  return obj
end

function PdfFunctions.createCommentObj(buffer)
  local obj = PdfFunctions.createPdfObject(PdfTypes.PdfComment, PdfFunctions.filepos)
  
  if buffer:readString(PdfFunctions.filepos, 4) == "%PDF" then
    obj.type = PdfTypes.PdfHeader
  elseif buffer:readString(PdfFunctions.filepos, 5) == "%%EOF" then
    obj.type = PdfTypes.PdfTrailer
  end
  
  PdfFunctions.filepos = PdfFunctions.indexOfEol(buffer, PdfFunctions.filepos) -- Eat Comment Line
  
  if PdfFunctions.isWhitespace(buffer[PdfFunctions.filepos]) then
    PdfFunctions.filepos = PdfFunctions.filepos + 1 -- Eat Single NewLine Char
  end
  
  obj.endpos = PdfFunctions.filepos
  return obj
end

function PdfFunctions.createObjObj(formatdefinition, buffer)
  local objpos = buffer:indexOf("obj", PdfFunctions.filepos)
  local endobjpos = buffer:indexOf("endobj", PdfFunctions.filepos)
  
  if (objpos == -1) or (endobjpos == -1) then
    formatdefinition:error("Wrong PdfObject at: " .. tostring(PdfFunctions.filepos))
    PdfFunctions.errorstate = true
    return
  end
  
  local obj = PdfFunctions.createPdfObject(PdfTypes.PdfObject, PdfFunctions.filepos)
  PdfFunctions.filepos = endobjpos + string.len("endobj") -- Eat Entire PdfObject
  PdfFunctions.eatWhitespaces(buffer)
  
  obj.endpos = PdfFunctions.filepos
  return obj
end

function PdfFunctions.createXRefObj(formatdefinition, buffer)
  local startxrefpos = buffer:indexOf("startxref", PdfFunctions.filepos)
  
  if startxrefpos == -1 then
    formatdefinition:error("Wrong PdfXRef at: " .. tostring(PdfFunctions.filepos))
    PdfFunctions.errorstate = true
    return
  end
  
  local obj = PdfFunctions.createPdfObject(PdfTypes.PdfXRef, PdfFunctions.filepos)
  
  PdfFunctions.filepos = startxrefpos + string.len("startxref") -- Eat Entire PdfXRef
  PdfFunctions.eatWhitespaces(buffer)
  PdfFunctions.filepos = PdfFunctions.filepos + string.len(buffer:readLine(PdfFunctions.filepos)) -- Eat XRef Offset
  PdfFunctions.eatWhitespaces(buffer)
  
  obj.endpos = PdfFunctions.filepos
  return obj
end

function PdfFunctions.getObjectName(objstruct, formattree)
  local buffer, offset = formattree.buffer, objstruct.offset
  local objpos = buffer:indexOf("obj", offset)
  
  return "Object(Number, Revision): " .. buffer:readString(offset, (objpos - offset) - 1)
end

function PdfFunctions.createPdfWhitespaceStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFWHITESPACE", obj.startpos)
  pdfobj:addField(pref.datatype.Blob, "Whitespace", obj.endpos - obj.startpos)
end

function PdfFunctions.createPdfCommentStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFCOMMENT", obj.startpos)
  pdfobj:addField(pref.datatype.Blob, "Comment", obj.endpos - obj.startpos)
end

function PdfFunctions.createPdfObjectStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFOBJECT", obj.startpos):dynamicInfo(PdfFunctions.getObjectName)
  pdfobj:addField(pref.datatype.Blob, "Data", obj.endpos - obj.startpos)
end

function PdfFunctions.createPdfHeaderStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFHEADER", obj.startpos)
  pdfobj:addField(pref.datatype.Character, "Header", obj.endpos - obj.startpos)
end

function PdfFunctions.createPdfXRefStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFXREF", obj.startpos)
  pdfobj:addField(pref.datatype.Blob, "Data", obj.endpos - obj.startpos)
end

function PdfFunctions.createPdfTrailerStruct(formattree, obj)
  local pdfobj = formattree:addStructure("PDFTRAILER", obj.startpos)
  pdfobj:addField(pref.datatype.Character, "Trailer", obj.endpos - obj.startpos)
end

return PdfFunctions
