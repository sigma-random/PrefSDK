local oop = require("sdk.lua.oop")
local Numerics = require("sdk.math.numerics")
local DataType = require("sdk.types.datatype")
local ProcessorDefinition = require("sdk.disassembler.processor.processordefinition")
local ReferenceType = require("sdk.disassembler.crossreference.referencetype")
local InstructionFeatures = require("sdk.disassembler.instructionfeatures")
local OperandType = require("sdk.disassembler.operandtype")

local MC68HC05Mnemonics = { [0x00] = "BRSET0", [0x01] = "BRCLR0", [0x02] = "BRSET1", [0x03] = "BRCLR1", [0x04] = "BRSET2", [0x05] = "BRCLR2", [0x06] = "BRSET3", [0x07] = "BRCLR3", [0x08] = "BRSET4", [0x09] = "BRCLR4", [0x0A] = "BRSET5", [0x0B] = "BRCLR5", [0x0C] = "BRSET6", [0x0D] = "BRCLR6", [0x0E] = "BRSET7", [0x0F] = "BRCLR7",
                            [0x10] = "BSET0",  [0x11] = "BCLR0",  [0x12] = "BSET1",  [0x13] = "BCLR1",  [0x14] = "BSET2",  [0x15] = "BCLR2",  [0x16] = "BSET3",  [0x17] = "BCLR3",  [0x18] = "BSET4",  [0x19] = "BCLR4",  [0x1A] = "BSET5",  [0x1B] = "BCLR5",  [0x1C] = "BSET6",  [0x1D] = "BCLR6",  [0x1E] = "BSET7",  [0x1F] = "BCLR7",
                            [0x20] = "BRA",    [0x21] = "BRN",    [0x22] = "BHI",    [0x23] = "BLS",    [0x24] = "BCC",    [0x25] = "BCS",    [0x26] = "BNE",    [0x27] = "BEQ",    [0x28] = "BHCC",   [0x29] = "BHCS",   [0x2A] = "BPL",    [0x2B] = "BMI",    [0x2C] = "BMC",    [0x2D] = "BMS",    [0x2E] = "BIL",    [0x2F] = "BIH",
                            [0x30] = "NEG",    [0x33] = "COM",    [0x34] = "LSR",    [0x36] = "ROR",    [0x37] = "ASR",    [0x38] = "ASL",    [0x39] = "ROL",    [0x3A] = "DEC",    [0x3C] = "INC",    [0x3D] = "TST",    [0x3F] = "CLR", 
                            [0x40] = "NEGA",   [0x42] = "MUL",    [0x43] = "COMA",   [0x44] = "LSRA",   [0x46] = "RORA",   [0x47] = "ASRA",   [0x48] = "ASLA",   [0x49] = "ROLA",   [0x4A] = "DECA",   [0x4C] = "INCA",   [0x4D] = "TSTA",   [0x4F] = "CLRA",
                            [0x50] = "NEGX",   [0x53] = "COMX",   [0x54] = "LSRX",   [0x56] = "RORX",   [0x57] = "ASRX",   [0x58] = "ASLX",   [0x59] = "ROLX",   [0x5A] = "DECX",   [0x5C] = "INCX",   [0x5D] = "TSTX",   [0x5F] = "CLRX",
                            [0x60] = "NEG",    [0x63] = "COM",    [0x64] = "LSR",    [0x66] = "ROR",    [0x67] = "ASR",    [0x68] = "ASL",    [0x69] = "ROL",    [0x6A] = "DEC",    [0x6C] = "INC",    [0x6D] = "TST",    [0x6F] = "CLR",
                            [0x70] = "NEG",    [0x73] = "COM",    [0x74] = "LSR",    [0x76] = "ROR",    [0x77] = "ASR",    [0x78] = "ASL",    [0x79] = "ROL",    [0x7A] = "DEC",    [0x7C] = "INC",    [0x7D] = "TST",    [0x7F] = "CLR",
                            [0x80] = "RTI",    [0x81] = "RTS",    [0x83] = "SWI",    [0x8E] = "STOP",   [0x8F] = "WAIT",
                            [0x97] = "TAX",    [0x98] = "CLC",    [0x99] = "SEC",    [0x9A] = "CLI",    [0x9B] = "SEI",    [0x9C] = "RSP",    [0x9D] = "NOP",    [0x9F] = "TXA",
                            [0xA0] = "SUB",    [0xA1] = "CMP",    [0xA2] = "SBC",    [0xA3] = "CPX",    [0xA4] = "AND",    [0xA5] = "BIT",    [0xA6] = "LDA",    [0xA8] = "EOR",    [0xA9] = "ADC",    [0xAA] = "ORA",    [0xAB] = "ADD",    [0xAD] = "BSR",    [0xAE] = "LDX",
                            [0xB0] = "SUB",    [0xB1] = "CMP",    [0xB2] = "SBC",    [0xB3] = "CPX",    [0xB4] = "AND",    [0xB5] = "BIT",    [0xB6] = "LDA",    [0xB7] = "STA",    [0xB8] = "EOR",    [0xB9] = "ADC",    [0xBA] = "ORA",    [0xBB] = "ADD",    [0xBC] = "JMP",    [0xBD] = "JSR",    [0xBE] = "LDX",    [0xBF] = "STX",
                            [0xC0] = "SUB",    [0xC1] = "CMP",    [0xC2] = "SBC",    [0xC3] = "CPX",    [0xC4] = "AND",    [0xC5] = "BIT",    [0xC6] = "LDA",    [0xC7] = "STA",    [0xC8] = "EOR",    [0xC9] = "ADC",    [0xCA] = "ORA",    [0xCB] = "ADD",    [0xCC] = "JMP",    [0xCD] = "JSR",    [0xCE] = "LDX",    [0xCF] = "STX",
                            [0xD0] = "SUB",    [0xD1] = "CMP",    [0xD2] = "SBC",    [0xD3] = "CPX",    [0xD4] = "AND",    [0xD5] = "BIT",    [0xD6] = "LDA",    [0xD7] = "STA",    [0xD8] = "EOR",    [0xD9] = "ADC",    [0xDA] = "ORA",    [0xDB] = "ADD",    [0xDC] = "JMP",    [0xDD] = "JSR",    [0xDE] = "LDX",    [0xDF] = "STX",
                            [0xE0] = "SUB",    [0xE1] = "CMP",    [0xE2] = "SBC",    [0xE3] = "CPX",    [0xE4] = "AND",    [0xE5] = "BIT",    [0xE6] = "LDA",    [0xE7] = "STA",    [0xE8] = "EOR",    [0xE9] = "ADC",    [0xEA] = "ORA",    [0xEB] = "ADD",    [0xEC] = "JMP",    [0xED] = "JSR",    [0xEE] = "LDX",    [0xEF] = "STX",
                            [0xF0] = "SUB",    [0xF1] = "CMP",    [0xF2] = "SBC",    [0xF3] = "CPX",    [0xF4] = "AND",    [0xF5] = "BIT",    [0xF6] = "LDA",    [0xF7] = "STA",    [0xF8] = "EOR",    [0xF9] = "ADC",    [0xFA] = "ORA",    [0xFB] = "ADD",    [0xFC] = "JMP",    [0xFD] = "JSR",    [0xFE] = "LDX",    [0xFF] = "STX" }

local MC68HC05Features = { [0x00] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x01] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2),[0x02] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x03] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x04] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x05] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x06] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x07] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x08] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x09] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x0A] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x0B] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x0C] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x0D] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x0E] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2), [0x0F] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1,InstructionFeatures.Use2),
                           [0x10] = InstructionFeatures.Use1, [0x11] = InstructionFeatures.Use1, [0x12] = InstructionFeatures.Use1, [0x13] = InstructionFeatures.Use1, [0x14] = InstructionFeatures.Use1, [0x15] = InstructionFeatures.Use1, [0x16] = InstructionFeatures.Use1, [0x17] = InstructionFeatures.Use1, [0x18] = InstructionFeatures.Use1, [0x19] = InstructionFeatures.Use1, [0x1A] = InstructionFeatures.Use1, [0x1B] = InstructionFeatures.Use1, [0x1C] = InstructionFeatures.Use1, [0x1D] = InstructionFeatures.Use1, [0x1E] = InstructionFeatures.Use1, [0x1F] = InstructionFeatures.Use1,
                           [0x20] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x21] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x22] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x23] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x24] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x25] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x26] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x27] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x28] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x29] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x2A] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x2B] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x2C] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x2D] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x2E] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1), [0x2F] = bit.bor(InstructionFeatures.Jump,InstructionFeatures.Use1),
                           [0x30] = InstructionFeatures.Use1, [0x33] = InstructionFeatures.Use1, [0x34] = InstructionFeatures.Use1, [0x36] = InstructionFeatures.Use1, [0x37] = InstructionFeatures.Use1, [0x38] = InstructionFeatures.Use1, [0x39] = InstructionFeatures.Use1, [0x3A] = InstructionFeatures.Use1, [0x3C] = InstructionFeatures.Use1, [0x3D] = InstructionFeatures.Use1, [0x3F] = InstructionFeatures.Use1,
                           [0x40] = 0, [0x42] = 0, [0x43] = 0, [0x44] = 0, [0x46] = 0, [0x47] = 0, [0x48] = 0, [0x49] = 0, [0x4A] = 0, [0x4C] = 0, [0x4D] = 0, [0x4F] = 0,
                           [0x50] = 0, [0x53] = 0,[0x54] = 0, [0x56] = 0, [0x57] = 0, [0x58] = 0, [0x59] = 0, [0x5A] = 0, [0x5C] = 0, [0x5D] = 0, [0x5F] = 0,
                           [0x60] = InstructionFeatures.Use1, [0x63] = InstructionFeatures.Use1, [0x64] = InstructionFeatures.Use1, [0x66] = InstructionFeatures.Use1, [0x67] = InstructionFeatures.Use1, [0x68] = InstructionFeatures.Use1, [0x69] = InstructionFeatures.Use1, [0x6A] = InstructionFeatures.Use1, [0x6C] = InstructionFeatures.Use1, [0x6D] = InstructionFeatures.Use1, [0x6F] = InstructionFeatures.Use1,
                           [0x70] = 0, [0x73] = 0, [0x74] = 0, [0x76] = 0, [0x77] = 0, [0x78] = 0, [0x79] = 0, [0x7A] = 0, [0x7C] = 0, [0x7D] = 0, [0x7F] = 0,
                           [0x80] = InstructionFeatures.Stop, [0x81] = InstructionFeatures.Stop, [0x83] = 0, [0x8E] = 0, [0x8F] = 0, 
                           [0x97] = 0, [0x98] = 0, [0x99] = 0, [0x9A] = 0, [0x9B] = 0, [0x9C] = 0, [0x9D] = 0, [0x9F] = 0,
                           [0xA0] = InstructionFeatures.Use1, [0xA1] = InstructionFeatures.Use1, [0xA2] = InstructionFeatures.Use1, [0xA3] = InstructionFeatures.Use1, [0xA4] = InstructionFeatures.Use1, [0xA5] = InstructionFeatures.Use1, [0xA6] = InstructionFeatures.Use1, [0xA8] = InstructionFeatures.Use1, [0xA9] = InstructionFeatures.Use1, [0xAA] = InstructionFeatures.Use1, [0xAB] = InstructionFeatures.Use1, [0xAD] = bit.bor(InstructionFeatures.Call,InstructionFeatures.Use1), [0xAE] = InstructionFeatures.Use1,
                           [0xB0] = InstructionFeatures.Use1, [0xB1] = InstructionFeatures.Use1, [0xB2] = InstructionFeatures.Use1, [0xB3] = InstructionFeatures.Use1, [0xB4] = InstructionFeatures.Use1, [0xB5] = InstructionFeatures.Use1, [0xB6] = InstructionFeatures.Use1, [0xB7] = InstructionFeatures.Use1, [0xB8] = InstructionFeatures.Use1, [0xB9] = InstructionFeatures.Use1, [0xBA] = InstructionFeatures.Use1, [0xBB] = InstructionFeatures.Use1, [0xBC] = bit.bor(InstructionFeatures.Jump, InstructionFeatures.Use1), [0xBD] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1), [0xBE] = InstructionFeatures.Use1, [0xBF] = InstructionFeatures.Use1, 
                           [0xC0] = InstructionFeatures.Use1, [0xC1] = InstructionFeatures.Use1, [0xC2] = InstructionFeatures.Use1, [0xC3] = InstructionFeatures.Use1, [0xC4] = InstructionFeatures.Use1, [0xC5] = InstructionFeatures.Use1, [0xC6] = InstructionFeatures.Use1, [0xC7] = InstructionFeatures.Use1, [0xC8] = InstructionFeatures.Use1, [0xC9] = InstructionFeatures.Use1, [0xCA] = InstructionFeatures.Use1, [0xCB] = InstructionFeatures.Use1, [0xCC] = bit.bor(InstructionFeatures.Jump, InstructionFeatures.Use1), [0xCD] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1), [0xCE] = InstructionFeatures.Use1, [0xCF] = InstructionFeatures.Use1,
                           [0xD0] = InstructionFeatures.Use1, [0xD1] = InstructionFeatures.Use1, [0xD2] = InstructionFeatures.Use1, [0xD3] = InstructionFeatures.Use1, [0xD4] = InstructionFeatures.Use1, [0xD5] = InstructionFeatures.Use1, [0xD6] = InstructionFeatures.Use1, [0xD7] = InstructionFeatures.Use1, [0xD8] = InstructionFeatures.Use1, [0xD9] = InstructionFeatures.Use1, [0xDA] = InstructionFeatures.Use1, [0xDB] = InstructionFeatures.Use1, [0xDC] = bit.bor(InstructionFeatures.Jump, InstructionFeatures.Use1), [0xDD] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1), [0xDE] = InstructionFeatures.Use1, [0xDF] = InstructionFeatures.Use1,
                           [0xE0] = InstructionFeatures.Use1, [0xE1] = InstructionFeatures.Use1, [0xE2] = InstructionFeatures.Use1, [0xE3] = InstructionFeatures.Use1, [0xE4] = InstructionFeatures.Use1, [0xE5] = InstructionFeatures.Use1,[0xE6] = InstructionFeatures.Use1, [0xE7] = InstructionFeatures.Use1, [0xE8] = InstructionFeatures.Use1, [0xE9] = InstructionFeatures.Use1, [0xEA] = InstructionFeatures.Use1, [0xEB] = InstructionFeatures.Use1, [0xEC] = bit.bor(InstructionFeatures.Jump, InstructionFeatures.Use1), [0xED] = bit.bor(InstructionFeatures.Call, InstructionFeatures.Use1), [0xEE] = InstructionFeatures.Use1, [0xEF] = InstructionFeatures.Use1,
                           [0xF0] = 0, [0xF1] = 0, [0xF2] = 0, [0xF3] = 0, [0xF4] = 0, [0xF5] = 0, [0xF6] = 0, [0xF7] = 0, [0xF8] = 0, [0xF9] = 0, [0xFA] = 0, [0xFB] = 0, [0xFC] = 0, [0xFD] = InstructionFeatures.Call, [0xFE] = 0, [0xFF] = 0 }

local MC68HC05OpCodes = { Dir_BRSET0 = 0x00, Dir_BRCLR0 = 0x01, Dir_BRSET1 = 0x02, Dir_BRCLR1 = 0x03, Dir_BRSET2 = 0x04, Dir_BRCLR2 = 0x05, Dir_BRSET3 = 0x06, Dir_BRCLR3 = 0x07, Dir_BRSET4 = 0x08, Dir_BRCLR4 = 0x09, Dir_BRSET5 = 0x0A, Dir_BRCLR5 = 0x0B, Dir_BRSET6 = 0x0C, Dir_BRCLR6 = 0x0D, Dir_BRSET7 = 0x0E, Dir_BRCLR7 = 0x0F,
                          Dir_BSET0  = 0x10, Dir_BCLR0  = 0x11, Dir_BSET1  = 0x12, Dir_BCLR1  = 0x13, Dir_BSET2  = 0x14, Dir_BCLR2  = 0x15, Dir_BSET3  = 0x16, Dir_BCLR3  = 0x17, Dir_BSET4  = 0x18, Dir_BCLR4  = 0x19, Dir_BSET5  = 0x1A, Dir_BCLR5  = 0x1B, Dir_BSET6  = 0x1C, Dir_BCLR6  = 0x1D, Dir_BSET7  = 0x1E, Dir_BCLR7  = 0x1F, Rel_BRA  = 0x20, Rel_BRN  = 0x21, Rel_BHI  = 0x22, Rel_BLS  = 0x23, Rel_BCC  = 0x24, Rel_BCS  = 0x25, Rel_BNE  = 0x26, Rel_BEQ = 0x27, Rel_BHCC = 0x28, Rel_BHCS = 0x29, Rel_BPL = 0x2A, Rel_BMI = 0x2B, Rel_BMC = 0x2C, Rel_BMS = 0x2D, Rel_BIL = 0x2E, Rel_BIH = 0x2F,
                          Dir_NEG    = 0x30, Dir_COM    = 0x33, Dir_LSR    = 0x34, Dir_ROR    = 0x36, Dir_ASR    = 0x37, Dir_ASL    = 0x38, Dir_ROL    = 0x39, Dir_DEC    = 0x3A, Dir_INC    = 0x3C, Dir_TST    = 0x3D, Dir_CLR    = 0x3F,
                          Inh_NEGA   = 0x40, Inh_MUL    = 0x42, Inh_COMA   = 0x43, Inh_LSRA   = 0x44, Inh_RORA   = 0x46, Inh_ASRA   = 0x47, Inh_ASLA   = 0x48, Inh_ROLA   = 0x49, Inh_DECA   = 0x4A, Inh_INCA   = 0x4C, Inh_TSTA   = 0x4D, Inh_CLRA   = 0x4F, Inh_NEGX   = 0x50, Inh_COMX   = 0x53, Inh_LSRX   = 0x54, Inh_RORX   = 0x56, Inh_ASRX = 0x57, Inh_ASLX = 0x58, Inh_ROLX = 0x59, Inh_DECX = 0x5A, Inh_INCX = 0x5C, Inh_TSTX = 0x5D, Inh_CLRX = 0x5F,
                          Ix1_NEG    = 0x60, Ix1_COM    = 0x63, Ix1_LSR    = 0x64, Ix1_ROR    = 0x66, Ix1_ASR    = 0x67, Ix1_ASL    = 0x68, Ix1_ROL    = 0x69, Ix1_DEC    = 0x6A, Ix1_INC    = 0x6C, Ix1_TST    = 0x6D, Ix1_CLR    = 0x6F,
                          Ix_NEG     = 0x70, Ix_COM     = 0x73, Ix_LSR     = 0x74, Ix_ROR     = 0x76, Ix_ASR     = 0x77, Ix_ASL     = 0x78, Ix_ROL     = 0x79, Ix_DEC     = 0x7A, Ix_INC     = 0x7C, Ix_TST     = 0x7D, Ix_CLR     = 0x7F,
                          Inh_RTI    = 0x80, Inh_RTS    = 0x81, Inh_SWI    = 0x83, Inh_STOP   = 0x8E, Inh_WAIT   = 0x8F,
                          Inh_TAX    = 0x97, Inh_CLC    = 0x98, Inh_SEC    = 0x99, Inh_CLI    = 0x9A, Inh_SEI    = 0x9B, Inh_RSP    = 0x9C, Inh_NOP    = 0x9D, Inh_TXA    = 0x9F,
                          Imm_SUB    = 0xA0, Imm_CMP    = 0xA1, Imm_SBC    = 0xA2, Imm_CPX    = 0xA3, Imm_AND    = 0xA4, Imm_BIT    = 0xA5, Imm_LDA    = 0xA6, Imm_EOR    = 0xA8, Imm_ADC    = 0xA9, Imm_ORA    = 0xAA, Imm_ADD    = 0xAB, Imm_BSR   = 0xAD, Imm_LDX     = 0xAE,
                          Dir_SUB    = 0xB0, Dir_CMP    = 0xB1, Dir_SBC    = 0xB2, Dir_CPX    = 0xB3, Dir_AND    = 0xB4, Dir_BIT    = 0xB5, Dir_LDA    = 0xB6, Dir_STA    = 0xB7, Dir_EOR    = 0xB8, Dir_ADC    = 0xB9, Dir_ORA    = 0xBA, Dir_ADD   = 0xBB, Dir_JMP     = 0xBC, Dir_JSR    = 0xBD, Dir_LDX    = 0xBE, Dir_STX    = 0xBF,
                          Ext_SUB    = 0xC0, Ext_CMP    = 0xC1, Ext_SBC    = 0xC2, Ext_CPX    = 0xC3, Ext_AND    = 0xC4, Ext_BIT    = 0xC5, Ext_LDA    = 0xC6, Ext_STA    = 0xC7, Ext_EOR    = 0xC8, Ext_ADC    = 0xC9, Ext_ORA    = 0xCA, Ext_ADD   = 0xCB, Ext_JMP     = 0xCC, Ext_JSR    = 0xCD, Ext_LDX    = 0xCE, Ext_STX    = 0xCF,
                          Ix2_SUB    = 0xD0, Ix2_CMP    = 0xD1, Ix2_SBC    = 0xD2, Ix2_CPX    = 0xD3, Ix2_AND    = 0xD4, Ix2_BIT    = 0xD5, Ix2_LDA    = 0xD6, Ix2_STA    = 0xD7, Ix2_EOR    = 0xD8, Ix2_ADC    = 0xD9, Ix2_ORA    = 0xDA, Ix2_ADD   = 0xDB, Ix2_JMP     = 0xDC, Ix2_JSR    = 0xDD, Ix2_LDX    = 0xDE, Ix2_STX    = 0xDF,
                          Ix1_SUB    = 0xE0, Ix1_CMP    = 0xE1, Ix1_SBC    = 0xE2, Ix1_CPX    = 0xE3, Ix1_AND    = 0xE4, Ix1_BIT    = 0xE5, Ix1_LDA    = 0xE6, Ix1_STA    = 0xE7, Ix1_EOR    = 0xE8, Ix1_ADC    = 0xE9, Ix1_ORA    = 0xEA, Ix1_ADD   = 0xEB, Ix1_JMP     = 0xEC, Ix1_JSR    = 0xED, Ix1_LDX    = 0xEE, Ix1_STX    = 0xEF,
                          Ix_SUB     = 0xF0, Ix_CMP     = 0xF1, Ix_SBC     = 0xF2, Ix_CPX     = 0xF3, Ix_AND     = 0xF4, Ix_BIT     = 0xF5, Ix_LDA     = 0xF6, Ix_STA     = 0xF7, Ix_EOR     = 0xF8, Ix_ADC     = 0xF9, Ix_ORA     = 0xFA, Ix_ADD    = 0xFB, Ix_JMP      = 0xFC, Ix_JSR     = 0xFD, Ix_LDX     = 0xFE, Ix_STX     = 0xFF }

local function outoperand(instructionprinter, operand)
  if operand.type == OperandType.Memory then
    instructionprinter:out(string.format("#%02X", operand.address))
  elseif operand.type == OperandType.Immediate then
    instructionprinter:out(string.format("#%02X", operand.value))
  elseif operand.type == OperandType.JumpNear then
    instructionprinter:outValue(operand.address, operand.type, true)
  end
end

local MC68HC05Processor = oop.class(ProcessorDefinition)

function MC68HC05Processor:__ctor()
  ProcessorDefinition.__ctor(self, "MC68HC05 MCU (Freescale)", MC68HC05Mnemonics, MC68HC05Features, outoperand)
end

function MC68HC05Processor:touchArg(addressqueue, referencetable, address, operand, iscall)
  if operand.type == OperandType.JumpNear then
    local reftype = ReferenceType.JumpNear
    
    if iscall then
      reftype = ReferenceType.CallNear
    end
        
    referencetable:makeReference(operand.address, address, reftype)
    -- FIXME: Genera Loop Infinito -> addressqueue:pushFront(operand.address)
  -- elseif operand.type == OperandType.Memory then
  end
end

function MC68HC05Processor:analyze(instruction)
  instruction.type = instruction:next(DataType.UInt8)
  
  if (instruction.type > 0xFF) or (self.mnemonics[instruction.type] == nil) then
    return 0
  end
  
  local highnibble = bit.rshift(instruction.type, 4)
  local lownibble = bit.band(instruction.type, 0x0F)
  
  if highnibble == 0x0 then
    instruction.operand1.type = OperandType.Memory
    instruction.operand1.datatype = DataType.UInt8
    instruction.operand1.address = instruction:next(DataType.UInt8)
    instruction.operand2.type = OperandType.JumpNear
    instruction.operand2.datatype = DataType.UInt8
    instruction.operand2.address = instruction.address + 3 + Numerics.compl2(instruction:next(DataType.UInt8), DataType.sizeOf(DataType.UInt8))
  elseif (highnibble == 0x1) or (highnibble == 0x3) or (highnibble == 0xB) or (highnibble == 0xE) then
    if (highnibble == 0xB) and (lownibble == 0xC) then
      instruction.operand1.type = OperandType.JumpNear
    else
      instruction.operand1.type = OperandType.Memory
    end
    
    instruction.operand1.datatype = DataType.UInt8
    instruction.operand1.address = instruction:next(DataType.UInt8)
  elseif highnibble == 0x2 then
    instruction.operand1.type = OperandType.JumpNear
    instruction.operand1.datatype = DataType.UInt8
    instruction.operand1.address = instruction.address + 2 + Numerics.compl2(instruction:next(DataType.UInt8), DataType.sizeOf(DataType.UInt8))
  elseif (highnibble == 0x4) or (highnibble == 0x5) or (highnibble == 0x7) or (highnibble == 0x8) or (highnibble == 0x9) or (highnibble == 0xF) then
    instruction.operand1.type = OperandType.Void
  elseif highnibble == 0x6 then
    instruction.operand1.type = OperandType.Memory
    instruction.operand1.datatype = DataType.UInt8
    instruction.operand1.address = instruction:next(DataType.UInt8)
  elseif (highnibble == 0xA) then
    instruction.operand1.datatype = DataType.UInt8
    
    if lownibble == 0xD then
      instruction.operand1.type = OperandType.JumpNear
      instruction.operand1.address = instruction.address + 2 + instruction:next(DataType.UInt8)
    else
      instruction.operand1.type = OperandType.Immediate
      instruction.operand1.value = instruction:next(DataType.UInt8)
    end
  elseif (highnibble == 0xC) or (highnibble == 0xD) then
     if (highnibble == 0xC) and ((lownibble == 0xC) or (lownibble == 0xD)) then
       instruction.operand1.type = OperandType.JumpNear
     else
       instruction.operand1.type = OperandType.Memory
     end
    
    instruction.operand1.datatype = DataType.UInt16
    instruction.operand1.address = instruction:next(DataType.UInt16)
  end
  
  return instruction.size
end

function MC68HC05Processor:emulate(addressqueue, referencetable, instruction)  
  if self.features[instruction.type] ~= InstructionFeatures.Stop then
    local features = self.features[instruction.type]
        
    if bit.band(features, InstructionFeatures.Use1) then
      self:touchArg(addressqueue, referencetable, instruction.address, instruction.operand1, bit.band(features, InstructionFeatures.Call) ~= 0)
    end
    
    if bit.band(features, InstructionFeatures.Use2) then
      self:touchArg(addressqueue, referencetable, instruction.address, instruction.operand2, bit.band(features, InstructionFeatures.Call) ~= 0)
    end
    
    addressqueue:pushFront(instruction.address + instruction.size)
  end
end

function MC68HC05Processor:output(loader, instructionprinter, instruction)
  instructionprinter:outAddress(loader:segmentName(instruction.address), string.format("%08X", tonumber(instruction.address)))
  instructionprinter:outHexDump(instruction.address, instruction.size)
  instructionprinter:outMnemonic(0, instruction)
  
  if instruction.operand1.type ~= OperandType.Void then
    instructionprinter:outnOperand(1, instruction)
    
    if instruction.operand2.type ~= OperandType.Void then
      instructionprinter:out(", ")
      instructionprinter:outnOperand(2, instruction)
    end
  end
end

return MC68HC05Processor