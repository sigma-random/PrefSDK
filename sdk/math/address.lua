local Address = { }

function Address.rebase(address, oldbase, newbase)
  return (address - oldbase) + newbase
end

return Address
