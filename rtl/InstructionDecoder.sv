import rvDefs::*;

module InstructionDecoder
(
    input  instruction_t    instruction,            // value of instruction to decode
    output xreg_addr_t      rs1,                    // rs1 field
    output xreg_addr_t      rs2,                    // rs2 field
    output xreg_addr_t      rd,                     // rd field
    output logic                    xaluArithmeticFlag,     // arithmetic (HI) vs logical (LO) shift flag (doubles as sub (HI) vs add (LO) flag) 
    output xalu_op_t        xaluOp,                 // operation to perform in XALU
    output logic                    zeroXaluPrimary,        // select x[0] instead of x[rs1] for primary input
    output logic                    pcXaluPrimary,          // select program counter instead of x[rs1] for primary input
    output logic                    immediateXaluSecondary, // select immediate instead of x[rs2] for secondary input
    output memory_op_size_t memoryOpSize,           // for memory operations, size of data being moved and also doubles as not a memory op signal
    output logic                    unsignedLoad,           // load operation value is sign extended into x[rd]
    output logic                    storeLoad,              // memory operation is a store (HI) or a load (LO)
    output branch_op_t      branchOp,               // for branch operations, comparison to look at and also doubles as not a branch op signal
    output logic                    branchNegate,           // if the branch test should be negated
    output logic                    jump,                   // signals jump operation
    output write_src_t      writeSource             // where to take writes from to set x[rd]
);

    // notes for XALU:
    // shamt field of SLLI, SRLI, SRAI = x[rs2]
    // for store and load, x[rs1] is ALWAYS the base that is added to the immediate value

    opcode_t opcode;
    logic [2 : 0] funct3;
    logic funct7_5;

    assign opcode =   opcode_t'(instruction[6 : 0]);
    assign funct3 =   instruction[14 : 12];
    assign funct7_5 = instruction[30];
    assign rs1 =      xreg_addr_t'(instruction[19 : 15]);
    assign rs2 =      xreg_addr_t'(instruction[24 : 20]);
    assign rd =       xreg_addr_t'(instruction[11 : 7]);
    assign zeroXaluPrimary = (opcode == OPCODE_LUI); // so that we can just access the immediate value from the XALU result
    assign pcXaluPrimary = ( // to mux in program counter value
        (opcode == OPCODE_AUIPC) ||
        (opcode == OPCODE_JAL) ||
        (opcode == OPCODE_BRANCH)
    );
    assign immediateXaluSecondary = ( // all of these opcodes need something done with an immediate value
        (opcode == OPCODE_LUI) ||
        (opcode == OPCODE_AUIPC) ||
        (opcode == OPCODE_JAL) ||
        (opcode == OPCODE_JALR) ||
        (opcode == OPCODE_BRANCH) ||
        (opcode == OPCODE_LOAD) ||
        (opcode == OPCODE_STORE) ||
        (opcode == OPCODE_OP_IMM)
    );
    assign xaluArithmeticFlag = (opcode == OPCODE_OP && funct7_5); // when to use subtraction instead of addition and arithmetic instead of logical shift
    assign unsignedLoad = funct3[2]; // when doing a load, this bit says if it is unsigned or not
    assign storeLoad = (opcode == OPCODE_STORE); // if a memory op is a store vs a load
    //assign branchOp = branch_op_t'(opcode == OPCODE_BRANCH ? funct3[2 : 1] : BRANCH_OP_NONE); // what to check for
    always_comb begin
        branchOp = BRANCH_OP_NONE;

        if (opcode == OPCODE_BRANCH)
            branchOp = branch_op_t'(funct3[2:1]);
    end
    assign branchNegate = funct3[0]; // when branching, this bit says if the condition is to be reversed/negated
    assign jump = ( // if the program counter should unconditionally load an offset because of a jump
        (opcode == OPCODE_JAL) ||
        (opcode == OPCODE_JALR)
    );
    always_comb begin
        memoryOpSize = MEMORY_OP_SIZE_NONE;

        if (opcode == OPCODE_LOAD || opcode == OPCODE_STORE)
            memoryOpSize = memory_op_size_t'(funct3[1:0]);
    end

    always_comb begin
        case (opcode)
            OPCODE_LUI,
            OPCODE_AUIPC,
            OPCODE_OP_IMM,
            OPCODE_OP:
                writeSource = WRITE_SRC_ALU;
            OPCODE_JAL,
            OPCODE_JALR:
                writeSource = WRITE_SRC_PC;
            OPCODE_LOAD:
                writeSource = WRITE_SRC_MEM;
            default:
                writeSource = WRITE_SRC_NONE;
        endcase
    end

    always_comb begin
        case (opcode)
            OPCODE_OP_IMM,
            OPCODE_OP:
                xaluOp = xalu_op_t'(funct3);
            default:
                xaluOp = XALU_OP_SUM;
        endcase
    end

endmodule
