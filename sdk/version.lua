SDKVersion = { Major    = 1, 
               Minor    = 1, 
               Revision = 0, 
               Custom   = "" }

function sdkVersion()
  local ver = SDKVersion.Major.."."..SDKVersion.Minor
      
  if SDKVersion.Revision > 0 then
    ver = ver.."."..SDKVersion.Revision
  end
  
  if #SDKVersion.Custom > 0 then
    ver = ver.." "..SDKVersion.Custom
  end
  
  return ver
end