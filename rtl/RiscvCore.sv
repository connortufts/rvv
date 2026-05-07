import rvDefs::*;
module RiscvCore
(
    input  logic                 clk,                // system clock
    input  logic                 resetN,             // system reset (for PC)
    input  instruction_t instruction,        // instruction value from imem
    output mem_addr_t    instructionAddress, // instruction address to imem
    output mem_addr_t    memAddress,         // address to memory space
    input  word_t        memReadData,        // data read in from memory
    output word_t        memWriteData,       // data to write to memory
    output logic                 memRead,            // issue a memory read op
    output logic                 memWrite,           // issue a memory write op
    output logic [2 : 0]         memSize,            // byte mask for writing
    input  logic                 stall               // if the core should stall
);

    /******************************
     * control values
     ******************************/
    // logic stall;
        // while stalling, the clock should still go, but no state change should happen
        // 1. the program counter should not increment
        // 2. no registers should be updated
        // 3. the instruction that caused the stall should not retire until the stall requirement is completed
        // currently only one reason for a stall: waiting for bus transfers
        // reads will likely always stall, and writes will stall if the bus request buffer is full (too many writes at once)
        // stall bit is set, core freezes, bus action may release stall, core unfreezes on next rising edge to latch data from bus if any
    logic branchPass; // if the program counter should be updated because of a branch

    /******************************
     * instruction decoder values
     ******************************/
    xreg_addr_t      rs1;                    // operand register 1
    xreg_addr_t      rs2;                    // operand register 2
    xreg_addr_t      rd;                     // destination register
    logic                    xaluArithmeticFlag;     // integer arithmetic operation alternate flag
    xalu_op_t        xaluOp;                 // integer arithmetic operation
    logic                    zeroXaluPrimary;        // integer ALU primary input as 0s
    logic                    pcXaluPrimary;          // integer ALU primary input as PC value
    logic                    immediateXaluSecondary; // integer ALU secondary input as immediate value
    memory_op_size_t memoryOpSize;           // operand size of memory instruction (B, HW, W), or none at all
    logic                    unsignedLoad;           // load instruction uses unsigned data
    logic                    storeLoad;              // if memory instruction is a store or a load
    branch_op_t      branchOp;               // type of branch operation, or none at all
    logic                    branchNegate;           // if the branch test should be negated
    logic                    jump;                   // jump instruction
    write_src_t      writeSource;            // where to write integer registers from, or none at all

    /******************************
     * register file values
     ******************************/
    xreg_t read1Data; // data in register selected with rs1
    xreg_t read2Data; // data in register selected with rs2
    word_t registerWriteData; // data to go into register selected with rd

    /******************************
     * other values
     ******************************/
    word_t memToRegData;  // data to be written to integer registers from read
    word_t immediate; // word of immediate data from instruction
    word_t aluResult; // result of integer ALU operation

    /******************************
     * modules
     ******************************/
    ProgramCounter programCounter(
        .clk(clk),
        .resetN(resetN),
        .enable(~stall),
        .load(jump | branchPass),
        .addrLoad(aluResult),
        .addrOut(instructionAddress)
    );

    ImmediateGenerator immediateGenerator(
        .instruction(instruction),
        .immediate(immediate)
    );

    InstructionDecoder instructionDecoder(
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .xaluArithmeticFlag(xaluArithmeticFlag),
        .xaluOp(xaluOp),
        .zeroXaluPrimary(zeroXaluPrimary),
        .pcXaluPrimary(pcXaluPrimary),
        .immediateXaluSecondary(immediateXaluSecondary),
        .memoryOpSize(memoryOpSize),
        .unsignedLoad(unsignedLoad),
        .storeLoad(storeLoad),
        .branchOp(branchOp),
        .branchNegate(branchNegate),
        .jump(jump),
        .writeSource(writeSource)
    );

    XRegisterFile xRegisterFile(
        .clk(clk),
        .writeEnable((writeSource != WRITE_SRC_NONE) && ~stall),
        .read1Reg(zeroXaluPrimary ? xreg_addr_t'(0) : rs1),
        .read2Reg(rs2),
        .writeReg(rd),
        .read1Data(read1Data),
        .read2Data(read2Data),
        .writeData(registerWriteData)
    );

    XALU xAlu(
        .inputPrimary(pcXaluPrimary ? instructionAddress : read1Data),
        .inputSecondary(immediateXaluSecondary ? immediate : read2Data),
        .operation(xaluOp),
        .arithmeticFlag(xaluArithmeticFlag),
        .result(aluResult)
    );

    LSU lsu(
        .memoryOpSize(memoryOpSize),
        .unsignedLoad(unsignedLoad),
        .storeLoad(storeLoad),
        .address(memAddress),
        .readData(memReadData),
        .memWrite(memWrite),
        .memRead(memRead),
        .memSize(memSize),
        .memToRegData(memToRegData)
    );

    /******************************
     * branch logic
     ******************************/
    always_comb begin
        case (branchOp)
            BRANCH_OP_EQ:
                branchPass = ((read1Data == read2Data) ^ branchNegate);
            BRANCH_OP_LT:
                branchPass = (($signed(read1Data) < $signed(read2Data)) ^ branchNegate);
            BRANCH_OP_LTU:
                branchPass = ((read1Data < read2Data) ^ branchNegate);
            default: branchPass = 0;
        endcase
    end

    /******************************
     * integer register write logic
     ******************************/
    always_comb begin
        case (writeSource)
            WRITE_SRC_ALU:
                registerWriteData = aluResult;
            WRITE_SRC_MEM:
                registerWriteData = memToRegData;
            WRITE_SRC_PC:
                registerWriteData = instructionAddress + word_t'(3'd4);
            default:
                registerWriteData = 0;
        endcase
    end
    
    /******************************
     * memory logic
     ******************************/
    assign memAddress = aluResult;
    assign memWriteData = read2Data;
endmodule
