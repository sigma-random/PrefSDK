local Address = { }

function Address.rebaseaddress(address, oldbase, newbase)
  return (address - oldbase) + newbase
end

return Address
