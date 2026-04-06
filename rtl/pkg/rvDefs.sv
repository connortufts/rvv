package rvDefs;

// RV32I constants
localparam int XLEN =       32; // the width of an x integer register in bits
localparam int XREG_COUNT = 32; // number of x integer registers
localparam int IALIGN =     32; // bits of instruction alignment boundary in memory
localparam int ILEN =       32; // bits of instruction length

//localparam int ADDRSPACE_LENGTH = 2 ** XLEN;

localparam int BYTE_BITS = 8;
typedef logic [BYTE_BITS - 1 : 0]     byte_t;
typedef logic [BYTE_BITS * 2 - 1 : 0] halfword_t;
typedef logic [BYTE_BITS * 4 - 1 : 0] word_t;

typedef logic [ILEN - 1 : 0] instruction_t;
typedef logic [XLEN - 1 : 0] xreg_t;
typedef logic [4 : 0]        xreg_addr_t;
typedef xreg_t               mem_addr_t;

endpackage
