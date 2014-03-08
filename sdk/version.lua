SDKVersion = { Major = 1, 
	       Minor = 0, 
	       Revision = 0, 
	       Extra = "" }

function sdkVersion()
  return SDKVersion.Major.."."..SDKVersion.Minor.."."..SDKVersion.Revision.." "..SDKVersion.Extra
end