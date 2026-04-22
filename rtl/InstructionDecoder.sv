module InstructionDecoder
(
    input  rvDefs::instruction_t    instruction,            // value of instruction to decode
    output rvDefs::xreg_addr_t      rs1,                    // rs1 field
    output rvDefs::xreg_addr_t      rs2,                    // rs2 field
    output rvDefs::xreg_addr_t      rd,                     // rd field
    output logic                    xaluArithmeticFlag,     // arithmetic (HI) vs logical (LO) shift flag (doubles as sub (HI) vs add (LO) flag) 
    output rvDefs::xalu_op_t        xaluOp,                 // operation to perform in XALU
    output logic                    zeroXaluPrimary,        // select x[0] instead of x[rs1] for primary input
    output logic                    pcXaluPrimary,          // select program counter instead of x[rs1] for primary input
    output logic                    immediateXaluSecondary, // select immediate instead of x[rs2] for secondary input
    output rvDefs::memory_op_size_t memoryOpSize,           // for memory operations, size of data being moved and also doubles as not a memory op signal
    output logic                    unsignedLoad,           // load operation value is sign extended into x[rd]
    output logic                    storeLoad,              // memory operation is a store (HI) or a load (LO)
    output rvDefs::branch_op_t      branchOp,               // for branch operations, comparison to look at and also doubles as not a branch op signal
    output logic                    branchNegate,           // if the branch test should be negated
    output logic                    jump,                   // signals jump operation
    output rvDefs::write_src_t      writeSource,            // where to take writes from to set x[rd]
    output logic                    mret,                   // exception return signal
    output logic                    ecall,                  // exception call signal
    output logic                    ebreak                  // exception debug signal
);

    // notes for XALU:
    // shamt field of SLLI, SRLI, SRAI = x[rs2]
    // for store and load, x[rs1] is ALWAYS the base that is added to the immediate value

    rvDefs::opcode_t opcode;
    logic [2 : 0] funct3;
    logic funct7_5;
    logic [11:0] funct12;

    assign opcode =   rvDefs::opcode_t'(instruction[6 : 0]);
    assign funct3 =   instruction[14 : 12];
    assign funct7_5 = instruction[30];
    assign funct12 =  instruction[31:20];
    assign rs1 =      rvDefs::xreg_addr_t'(instruction[19 : 15]);
    assign rs2 =      rvDefs::xreg_addr_t'(instruction[24 : 20]);
    assign rd =       rvDefs::xreg_addr_t'(instruction[11 : 7]);

    assign zeroXaluPrimary = (opcode == rvDefs::OPCODE_LUI); // so that we can just access the immediate value from the XALU result
    assign pcXaluPrimary = ( // to mux in program counter value
        (opcode == rvDefs::OPCODE_AUIPC) ||
        (opcode == rvDefs::OPCODE_JAL) ||
        (opcode == rvDefs::OPCODE_BRANCH)
    );

    assign immediateXaluSecondary = ( // all of these opcodes need something done with an immediate value
        (opcode == rvDefs::OPCODE_LUI) ||
        (opcode == rvDefs::OPCODE_AUIPC) ||
        (opcode == rvDefs::OPCODE_JAL) ||
        (opcode == rvDefs::OPCODE_JALR) ||
        (opcode == rvDefs::OPCODE_BRANCH) ||
        (opcode == rvDefs::OPCODE_LOAD) ||
        (opcode == rvDefs::OPCODE_STORE) ||
        (opcode == rvDefs::OPCODE_OP_IMM)
    );

    assign xaluArithmeticFlag = (opcode == rvDefs::OPCODE_OP && funct7_5); // when to use subtraction instead of addition and arithmetic instead of logical shift
    assign unsignedLoad = funct3[2]; // when doing a load, this bit says if it is unsigned or not
    assign storeLoad = (opcode == rvDefs::OPCODE_STORE); // if a memory op is a store vs a load
    assign branchOp = rvDefs::branch_op_t'(opcode == rvDefs::OPCODE_BRANCH ? funct3[2 : 1] : rvDefs::BRANCH_OP_NONE); // what to check for
    assign branchNegate = funct3[0]; // when branching, this bit says if the condition is to be reversed/negated
    assign jump = ( // if the program counter should unconditionally load an offset because of a jump
        (opcode == rvDefs::OPCODE_JAL) ||
        (opcode == rvDefs::OPCODE_JALR)
    );
    assign memoryOpSize = (
        ((opcode == rvDefs::OPCODE_LOAD) || (opcode == rvDefs::OPCODE_STORE)) ?
            (rvDefs::memory_op_size_t'(funct3[1 : 0])) :
            (rvDefs::MEMORY_OP_SIZE_NONE)
    );

    assign mret   = (opcode == rvDefs::OPCODE_SYSTEM) && (funct3 == 3'b000) && (funct12 == 12'h302);
    assign ecall  = (opcode == rvDefs::OPCODE_SYSTEM) && (funct3 == 3'b000) && (funct12 == 12'h000);
    assign ebreak = (opcode == rvDefs::OPCODE_SYSTEM) && (funct3 == 3'b000) && (funct12 == 12'h001);

    always_comb begin
        case (opcode)
            rvDefs::OPCODE_LUI,
            rvDefs::OPCODE_AUIPC,
            rvDefs::OPCODE_OP_IMM,
            rvDefs::OPCODE_OP:
                writeSource = rvDefs::WRITE_SRC_ALU;
            rvDefs::OPCODE_JAL,
            rvDefs::OPCODE_JALR:
                writeSource = rvDefs::WRITE_SRC_PC;
            rvDefs::OPCODE_LOAD:
                writeSource = rvDefs::WRITE_SRC_MEM;
            rvDefs::OPCODE_SYSTEM:
                writeSource = (funct3 != 3'b000) ? rvDefs::WRITE_SRC_CSR : rvDefs::WRITE_SRC_NONE;
            default:
                writeSource = rvDefs::WRITE_SRC_NONE;
        endcase
    end

    always_comb begin
        case (opcode)
            rvDefs::OPCODE_OP_IMM,
            rvDefs::OPCODE_OP:
                xaluOp = rvDefs::xalu_op_t'(funct3);
            default:
                xaluOp = rvDefs::XALU_OP_SUM;
        endcase
    end

endmodule
