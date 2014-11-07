local oop = require("oop")
local Instruction = require("sdk.disassembler.instruction")

local MacroInstruction = oop.class(Instruction)

function MacroInstruction:__ctor(address, mnemonic, type, isjump, iscall)
  self:__super(address, mnemonic, type, isjump, iscall)
  self.ismacro = true
end

return MacroInstruction
