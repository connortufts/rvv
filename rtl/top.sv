module top
(
    input  logic sysclk,
    input  logic sysreset,
    input  logic cpu_enable,
    output rvDefs::mem_addr_t instructionAddr,
    input  rvDefs::instruction_t instruction,
    // output rvDefs::word_t dmemview,
    // input  rvDefs::mem_addr_t viewaddr
    output logic [31:0] dmem_addr,
    output logic [7:0] dmem_wdata [4],
    output logic dmem_write,
    output logic dmem_read,
    output logic [3:0] dmem_byte_write_enable,
    input  logic [7:0] dmem_rdata [4]
);

    // rvDefs::word_t dmem [0 : 15];
    // assign dmemview = dmem[viewaddr];
    // always_ff @(posedge sysclk) begin
    //     if ((memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) & storeLoad) begin
    //         dmem[aluResult] <= (read2Data & memoryMask);
    //     end
    // end
    // DMEM interface
    // address from ALU
    assign dmem_addr = aluResult;

    //write enable to store instructions
    assign dmem_write = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) & storeLoad;

    // read enable for loading
    assign dmem_read = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) & ~storeLoad;

    // split register into the bytes
    assign dmem_wdata[0] = read2Data[7:0]; //data to store
    assign dmem_wdata[1] = read2Data[15:8];
    assign dmem_wdata[2] = read2Data[23:16];
    assign dmem_wdata[3] = read2Data[31:24];

    // generate byte write enable from the size
    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE: dmem_byte_write_enable = 4'b0001;
            rvDefs::MEMORY_OP_SIZE_HALF: dmem_byte_write_enable = 4'b0011;
            rvDefs::MEMORY_OP_SIZE_WORD: dmem_byte_write_enable = 4'b1111;
            default: dmem_byte_write_enable = 4'b0000;
        endcase
    end

    // combine the bytes from memory and handle sign extend
    logic [31:0] dmem_rdata_word;
    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE:
                dmem_rdata_word = unsignedLoad ? 
                    {24'b0, dmem_rdata[0]} : 
                    {{24{dmem_rdata[0][7]}}, dmem_rdata[0]};
            rvDefs::MEMORY_OP_SIZE_HALF:
                dmem_rdata_word = unsignedLoad ?
                    {16'b0, dmem_rdata[1], dmem_rdata[0]} :
                    {{16{dmem_rdata[1][7]}}, dmem_rdata[1], dmem_rdata[0]};
            default:
                dmem_rdata_word = {dmem_rdata[3], dmem_rdata[2], 
                                   dmem_rdata[1], dmem_rdata[0]};
        endcase
    end

    ProgramCounter programCounter(
        .clk(sysclk),
        .resetN(sysreset),
        // .enable(1'b1),
        .enable(cpu_enable),
        .load(jump | branchPass),
        .addrLoad(aluResult),
        .addrOut(instructionAddr)
    );

    logic branchPass;
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

    rvDefs::word_t immediate;
    ImmediateGenerator immedaiteGenerator(
        .instruction(instruction),
        .immediate(immediate)
    );

    rvDefs::xreg_addr_t rs1;
    rvDefs::xreg_addr_t rs2;
    rvDefs::xreg_addr_t rd;
    logic xaluArithmeticFlag;
    rvDefs::xalu_op_t xaluOp;
    logic zeroXaluPrimary;
    logic pcXaluPrimary;
    logic immediateXaluSecondary;
    rvDefs::memory_op_size_t memoryOpSize;
    logic unsignedLoad;
    logic storeLoad;
    rvDefs::branch_op_t branchOp;
    logic branchNegate;
    logic jump;
    rvDefs::write_src_t writeSource;

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

    rvDefs::word_t memoryMask;
    always_comb begin
        case (memoryOpSize)
            rvDefs::MEMORY_OP_SIZE_BYTE:
                memoryMask = rvDefs::word_t'(8'hFF);
            rvDefs::MEMORY_OP_SIZE_HALF:
                memoryMask = rvDefs::word_t'(16'hFFFF);
            rvDefs::MEMORY_OP_SIZE_WORD:
                memoryMask = rvDefs::word_t'(32'hFFFFFFFF);
            rvDefs::MEMORY_OP_SIZE_NONE:
                memoryMask = rvDefs::word_t'(0);
        endcase
    end

    rvDefs::xreg_t read1Data;
    rvDefs::xreg_t read2Data;
    rvDefs::word_t writeData;
    always_comb begin
        case (writeSource)
            rvDefs::WRITE_SRC_ALU:
                writeData = aluResult;
            rvDefs::WRITE_SRC_MEM:
                writeData = dmem_rdata_word; //dmem[aluResult] & memoryMask;
            rvDefs::WRITE_SRC_PC:
                writeData = instructionAddr + rvDefs::word_t'(3'd4);
            default:
                writeData = 0;
        endcase
    end
    XRegisterFile xRegisterFile(
        .clk(sysclk),
        .writeEnable((writeSource != rvDefs::WRITE_SRC_NONE)& cpu_enable),
        .read1Reg(zeroXaluPrimary ? rvDefs::xreg_addr_t'(0) : rs1),
        .read2Reg(rs2),
        .writeReg(rd),
        .read1Data(read1Data),
        .read2Data(read2Data),
        .writeData(writeData)
    );
    
    rvDefs::word_t aluResult;
    XALU xAlu(
        .inputPrimary(pcXaluPrimary ? instructionAddr : read1Data),
        .inputSecondary(immediateXaluSecondary ? immediate : read2Data),
        .operation(xaluOp),
        .arithmeticFlag(xaluArithmeticFlag),
        .result(aluResult)
    );

endmodule
