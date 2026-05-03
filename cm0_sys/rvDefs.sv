package rvDefs;

// RV32I constants
localparam int XLEN =       32; // the width of an x integer register in bits
localparam int XREG_COUNT = 32; // number of x integer registers
localparam int IALIGN =     32; // bits of instruction alignment boundary in memory
localparam int ILEN =       32; // bits of instruction length

//localparam int ADDRSPACE_LENGTH = 2 ** XLEN;

localparam int BYTE_BITS = 8;
localparam int HALFWORD_BITS = BYTE_BITS * 2;
localparam int WORD_BITS = BYTE_BITS * 4;
typedef logic [BYTE_BITS - 1 : 0]     byte_t;
typedef logic [HALFWORD_BITS - 1 : 0] halfword_t;
typedef logic [WORD_BITS - 1 : 0]     word_t;

typedef logic [ILEN - 1 : 0] instruction_t;
typedef logic [XLEN - 1 : 0] xreg_t;
typedef logic [4 : 0]        xreg_addr_t;
typedef word_t               mem_addr_t;

// instruction opcode values
// see table 72
typedef enum logic [6 : 0] {
    OPCODE_LOAD =      7'b0000011,
    OPCODE_LOAD_FP =   7'b0000111,
    OPCODE_CUSTOM_0 =  7'b0001011,
    OPCODE_MISC_MEM =  7'b0001111,
    OPCODE_OP_IMM =    7'b0010011,
    OPCODE_AUIPC =     7'b0010111,
    OPCODE_OP_IMM_32 = 7'b0011011,
    // reserved        7'b0011111
    OPCODE_STORE =     7'b0100011,
    OPCODE_STORE_FP =  7'b0100111,
    OPCODE_CUSTOM_1 =  7'b0101011,
    OPCODE_AM0 =       7'b0101111,
    OPCODE_OP =        7'b0110011,
    OPCODE_LUI =       7'b0110111,
    OPCODE_OP_32 =     7'b0111011,
    // reserved        7'b0111111,
    OPCODE_MADD =      7'b1000011,
    OPCODE_MSUB =      7'b1000111,
    OPCODE_NMSUB =     7'b1001011,
    OPCODE_NMADD =     7'b1001111,
    OPCODE_OP_FP =     7'b1010011,
    OPCODE_OP_V =      7'b1010111,
    OPCODE_CUSTOM_2 =  7'b1011011,
    // reserved        7'b1011111
    OPCODE_BRANCH =    7'b1100011,
    OPCODE_JALR =      7'b1100111,
    OPCODE_RESERVED =  7'b1101011,
    OPCODE_JAL =       7'b1101111,
    OPCODE_SYSTEM =    7'b1110011,
    OPCODE_OP_VE =     7'b1110111,
    OPCODE_CUSTOM_3 =  7'b1111011
    // reserved        7'b1111111
} opcode_t;

// operations the x register ALU supports
typedef enum logic [2 : 0] {
    XALU_OP_SUM =  3'b000,
    XALU_OP_SLL =  3'b001,
    XALU_OP_SLT =  3'b010,
    XALU_OP_SLTU = 3'b011,
    XALU_OP_XOR =  3'b100,
    XALU_OP_SR =   3'b101,
    XALU_OP_OR =   3'b110,
    XALU_OP_AND =  3'b111
} xalu_op_t;

typedef enum logic [1 : 0] {
    MEMORY_OP_SIZE_BYTE = 2'b00,
    MEMORY_OP_SIZE_HALF = 2'b01,
    MEMORY_OP_SIZE_WORD = 2'b10,
    MEMORY_OP_SIZE_NONE = 2'b11
} memory_op_size_t;

typedef enum logic [1 : 0] {
    BRANCH_OP_EQ = 2'b00,
    BRANCH_OP_LT = 2'b10,
    BRANCH_OP_LTU = 2'b11,
    BRANCH_OP_NONE = 2'b01
} branch_op_t;

typedef enum logic [1 : 0] {
    WRITE_SRC_NONE = 2'b00,
    WRITE_SRC_PC = 2'b01,
    WRITE_SRC_MEM = 2'b10,
    WRITE_SRC_ALU = 2'b11
} write_src_t;

endpackage

