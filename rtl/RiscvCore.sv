module RiscvCore
(
    input  logic                 clk,                // system clock
    input  logic                 resetN,             // system reset (for PC)
    input  rvDefs::instruction_t instruction,        // instruction value from imem
    output rvDefs::mem_addr_t    instructionAddress, // instruction address to imem
    output logic [29 : 0]        memoryAddress,      // address to memory space TODO
    input  rvDefs::word_t        readData,           // data read in from memory TODO
    output rvDefs::word_t        writeData,          // data to write to memory TODO
    output logic                 memRead,            // issue a memory read op TODO
    output logic                 memWrite,           // issue a memory write op TODO
    output logic [3 : 0]         writeMask,          // byte mask for writing TODO
    input  logic                 stall               // if the core should stall TODO
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
    rvDefs::xreg_addr_t      rs1;                    // operand register 1
    rvDefs::xreg_addr_t      rs2;                    // operand register 2
    rvDefs::xreg_addr_t      rd;                     // destination register
    logic                    xaluArithmeticFlag;     // integer arithmetic operation alternate flag
    rvDefs::xalu_op_t        xaluOp;                 // integer arithmetic operation
    logic                    zeroXaluPrimary;        // integer ALU primary input as 0s
    logic                    pcXaluPrimary;          // integer ALU primary input as PC value
    logic                    immediateXaluSecondary; // integer ALU secondary input as immediate value
    rvDefs::memory_op_size_t memoryOpSize;           // operand size of memory instruction (B, HW, W), or none at all
    logic                    unsignedLoad;           // load instruction uses unsigned data
    logic                    storeLoad;              // if memory instruction is a store or a load
    rvDefs::branch_op_t      branchOp;               // type of branch operation, or none at all
    logic                    branchNegate;           // if the branch test should be negated
    logic                    jump;                   // jump instruction
    rvDefs::write_src_t      writeSource;            // where to write integer registers from, or none at all

    /******************************
     * register file values
     ******************************/
    rvDefs::xreg_t read1Data; // data in register selected with rs1
    rvDefs::xreg_t read2Data; // data in register selected with rs2
    rvDefs::word_t registerWriteData; // data to go into register selected with rd

    /******************************
     * other values
     ******************************/
    rvDefs::word_t memToRegData;  // data to be written to integer registers from read
    rvDefs::word_t immediate; // word of immediate data from instruction
    rvDefs::word_t aluResult; // result of integer ALU operation

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

    ImmediateGenerator immedaiteGenerator(
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
        .writeEnable((writeSource != rvDefs::WRITE_SRC_NONE) && ~stall),
        .read1Reg(zeroXaluPrimary ? rvDefs::xreg_addr_t'(0) : rs1),
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
        .regToMemData(read2Data),
        .unsignedLoad(unsignedLoad),
        .storeLoad(storeLoad),
        .address(aluResult),
        .readData(readData),
        .memWrite(memWrite),
        .memRead(memRead),
        .writeData(writeData),
        .byteWriteEnable(writeMask),
        .memToRegData(memToRegData),
        .effectiveAddress(memoryAddress)
    );

    /******************************
     * branch logic
     ******************************/
    always_comb begin
        case (branchOp)
            rvDefs::BRANCH_OP_EQ:
                branchPass = ((read1Data == read2Data) ^ branchNegate);
            rvDefs::BRANCH_OP_LT:
                branchPass = (($signed(read1Data) < $signed(read2Data)) ^ branchNegate);
            rvDefs::BRANCH_OP_LTU:
                branchPass = ((read1Data < read2Data) ^ branchNegate);
            default: branchPass = 0;
        endcase
    end

    /******************************
     * integer register write logic
     ******************************/
    always_comb begin
        case (writeSource)
            rvDefs::WRITE_SRC_ALU:
                registerWriteData = aluResult;
            rvDefs::WRITE_SRC_MEM:
                registerWriteData = memToRegData;
            rvDefs::WRITE_SRC_PC:
                registerWriteData = instructionAddress + rvDefs::word_t'(3'd4);
            default:
                registerWriteData = 0;
        endcase
    end
endmodule
