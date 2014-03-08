local PdfTypes = require("formats.pdf.pdftypes")

local PdfDebug = { }

function PdfDebug.pdfTypeName(pdftype)
  if pdftype == PdfTypes.PdfUnknown then
    return "PdfUnknown"
  elseif pdftype == PdfTypes.PdfWhitespace then
    return "PdfWhitespace"
  elseif pdftype == PdfTypes.PdfComment then
    return "PdfComment"
  elseif pdftype == PdfTypes.PdfObject then
    return "PdfObject"
  elseif pdftype == PdfTypes.PdfHeader then
    return "PdfHeader"
  elseif pdftype == PdfTypes.PdfXRef then
    return "PdfXRef"
  elseif pdftype == PdfTypes.PdfTrailer then
    return "PdfTrailer"
  end

  return "???"
end

function PdfDebug.printObjectTable(objtable)
  for i,v in ipairs(objtable) do
    print(PdfDebug.pdfTypeName(v.type) .. ": " .. v.startpos .. " -> " .. v.endpos)
  end
end 

return PdfDebug