local pref = require("pref")
local ffi = require("ffi")

ffi.cdef
[[
  typedef size_t csh;
  
  typedef enum cs_arch {
    CS_ARCH_ARM = 0,
    CS_ARCH_ARM64,
    CS_ARCH_MIPS,
    CS_ARCH_X86,
    CS_ARCH_PPC,
    CS_ARCH_SPARC,
    CS_ARCH_SYSZ,
    CS_ARCH_XCORE,
    CS_ARCH_MAX,
    CS_ARCH_ALL = 0xFFFF,
  } cs_arch;
  
  typedef enum cs_mode {
    CS_MODE_LITTLE_ENDIAN = 0,
    CS_MODE_ARM = 0,
    CS_MODE_16 = 1 << 1,
    CS_MODE_32 = 1 << 2,
    CS_MODE_64 = 1 << 3,
    CS_MODE_THUMB = 1 << 4,
    CS_MODE_MCLASS = 1 << 5,
    CS_MODE_V8 = 1 << 6,
    CS_MODE_MICRO = 1 << 4,
    CS_MODE_MIPS3 = 1 << 5,
    CS_MODE_MIPS32R6 = 1 << 6,
    CS_MODE_MIPSGP64 = 1 << 7,
    CS_MODE_V9 = 1 << 4,
    CS_MODE_BIG_ENDIAN = 1 << 31,
    CS_MODE_MIPS32 = CS_MODE_32,
    CS_MODE_MIPS64 = CS_MODE_64,
  } cs_mode;
  
  typedef void* (*cs_malloc_t)(size_t size);
  typedef void* (*cs_calloc_t)(size_t nmemb, size_t size);
  typedef void* (*cs_realloc_t)(void *ptr, size_t size);
  typedef void (*cs_free_t)(void *ptr);
  typedef int (*cs_vsnprintf_t)(char *str, size_t size, const char *format, va_list ap);
  
  typedef struct cs_opt_mem {
    cs_malloc_t malloc;
    cs_calloc_t calloc;
    cs_realloc_t realloc;
    cs_free_t free;
    cs_vsnprintf_t vsnprintf;
  } cs_opt_mem;
  
  typedef enum cs_opt_type {
    CS_OPT_SYNTAX = 1,
    CS_OPT_DETAIL,
    CS_OPT_MODE,
    CS_OPT_MEM,
    CS_OPT_SKIPDATA,
    CS_OPT_SKIPDATA_SETUP,
  } cs_opt_type;
  
  typedef enum cs_opt_value {
    CS_OPT_OFF = 0,
    CS_OPT_ON = 3,
    CS_OPT_SYNTAX_DEFAULT = 0,
    CS_OPT_SYNTAX_INTEL,
    CS_OPT_SYNTAX_ATT,
    CS_OPT_SYNTAX_NOREGNAME,
  } cs_opt_value;
  
  typedef enum cs_op_type {
    CS_OP_INVALID = 0,
    CS_OP_REG,
    CS_OP_IMM,
    CS_OP_MEM,
    CS_OP_FP,
  } cs_op_type;
  
  typedef enum cs_group_type {
    CS_GRP_INVALID = 0,
    CS_GRP_JUMP,
    CS_GRP_CALL,
    CS_GRP_RET,
    CS_GRP_INT,
    CS_GRP_IRETm
  } cs_group_type;
  
  typedef size_t (*cs_skipdata_cb_t)(const uint8_t *code, size_t code_size, size_t offset, void *user_data);
  
  typedef struct cs_opt_skipdata {
    const char *mnemonic;
    cs_skipdata_cb_t callback;
    void *user_data;
  } cs_opt_skipdata;
]]

require("sdk.modules.capstone.ffi.arm")
require("sdk.modules.capstone.ffi.arm64")
require("sdk.modules.capstone.ffi.mips")
require("sdk.modules.capstone.ffi.ppc")
require("sdk.modules.capstone.ffi.sparc")
require("sdk.modules.capstone.ffi.systemz")
require("sdk.modules.capstone.ffi.x86")
require("sdk.modules.capstone.ffi.xcore")

ffi.cdef
[[
  typedef struct cs_detail {
    uint8_t regs_read[12];
    uint8_t regs_read_count;
    uint8_t regs_write[20];
    uint8_t regs_write_count;
    uint8_t groups[8];
    uint8_t groups_count;

    union {
      cs_x86 x86;
      cs_arm64 arm64;
      cs_arm arm;
      cs_mips mips;
      cs_ppc ppc;
      cs_sparc sparc;
      cs_sysz sysz;
      cs_xcore xcore;
    };
  } cs_detail;
  
  typedef struct cs_insn {
    unsigned int id;
    uint64_t address;
    uint16_t size;
    uint8_t bytes[16];
    char mnemonic[32];
    char op_str[160];
    cs_detail *detail;
  } cs_insn;
  
  typedef enum cs_err {
    CS_ERR_OK = 0,
    CS_ERR_MEM,
    CS_ERR_ARCH,
    CS_ERR_HANDLE,
    CS_ERR_CSH,
    CS_ERR_MODE,
    CS_ERR_OPTION,
    CS_ERR_DETAIL,
    CS_ERR_MEMSETUP,
    CS_ERR_VERSION,
    CS_ERR_DIET,
    CS_ERR_SKIPDATA,
    CS_ERR_X86_ATT,
    CS_ERR_X86_INTEL,
  } cs_err;

  unsigned int cs_version(int *major, int *minor);
  bool cs_support(int query);
  cs_err cs_open(cs_arch arch, cs_mode mode, csh *handle);
  cs_err cs_close(csh *handle);
  cs_err cs_option(csh handle, cs_opt_type type, size_t value);
  cs_err cs_errno(csh handle);
  const char *cs_strerror(cs_err code);
  size_t cs_disasm(csh handle, const uint8_t *code, size_t code_size, uint64_t address, size_t count, cs_insn **insn);
  void cs_free(cs_insn *insn, size_t count);
  cs_insn *cs_malloc(csh handle);
  bool cs_disasm_iter(csh handle, const uint8_t **code, size_t *size, uint64_t *address, cs_insn *insn);
  const char *cs_reg_name(csh handle, unsigned int reg_id);
  const char *cs_insn_name(csh handle, unsigned int insn_id);
  const char *cs_group_name(csh handle, unsigned int group_id);
  bool cs_insn_group(csh handle, const cs_insn *insn, unsigned int group_id);
  bool cs_reg_read(csh handle, const cs_insn *insn, unsigned int reg_id);
  bool cs_reg_write(csh handle, const cs_insn *insn, unsigned int reg_id);
  int cs_op_count(csh handle, const cs_insn *insn, unsigned int op_type);
  int cs_op_index(csh handle, const cs_insn *insn, unsigned int op_type, unsigned int position);
]]

local CapstoneLib = { }

function CapstoneLib.load()
  local path = pref.modulePath(((ffi.os == "Windows") and "libcapstone.dll" or "libcapstone.so"))
  return ffi.load(path)
end

return CapstoneLib