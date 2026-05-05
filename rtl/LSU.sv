module LSU (
    input  rvDefs::memory_op_size_t memoryOpSize,
    input  rvDefs::xreg_t           regToMemData,
    input  logic                    unsignedLoad,
    input  logic                    storeLoad,
    input  rvDefs::mem_addr_t       address,
    input  rvDefs::word_t           readData,
    output logic                    memWrite,
    output logic                    memRead,
    output rvDefs::word_t           writeData,
    output logic [3:0]              byteWriteEnable,
    output rvDefs::word_t           memToRegData,
    output rvDefs::mem_addr_t           effectiveAddress
);

	assign effectiveAddress = address;
    assign memWrite = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) && (storeLoad == 1'b1);
    assign memRead = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) && (storeLoad == 1'b0);

    always_comb begin
        if (storeLoad == 1'b1) begin // writing
            case (memoryOpSize)
                rvDefs::MEMORY_OP_SIZE_BYTE: begin
                    byteWriteEnable = 4'b1 << address[1:0];
                    writeData = ({24'b0, regToMemData[7:0]} << (8 * address[1:0]));
                end
                rvDefs::MEMORY_OP_SIZE_HALF: begin
                    byteWriteEnable = 4'b11 << {address[1], 1'b0};
                    writeData = ({16'b0, regToMemData[15:0]} << (16 * address[1]));
                end
                rvDefs::MEMORY_OP_SIZE_WORD: begin
                    byteWriteEnable = 4'b1111;
                    writeData = regToMemData;
                end
                default: begin
                    byteWriteEnable = 4'b0;
                    writeData = 32'b0;
                end
            endcase
        end else begin // reading
            case (memoryOpSize)
                rvDefs::MEMORY_OP_SIZE_BYTE: begin
                    memToRegData = {
                        unsignedLoad ? (24'b0) : ({24{{readData >> (8 * address[1 : 0])}[7]}}), // conditional sign extension
                        {readData >> (8 * address[1:0])}[7 : 0]
                    };
                end
                rvDefs::MEMORY_OP_SIZE_HALF: begin
                    memToRegData = {
                        unsignedLoad ? (16'b0) : ({16{{readData >> (16 * address[1])}[15]}}), // conditional sign extension
                        {readData >> (16 * address[1])}[15 : 0]
                    };
                end
                rvDefs::MEMORY_OP_SIZE_WORD: begin
                    memToRegData = readData;
                end
                default: memToRegData = 32'b0;
            endcase
        end
    end 
endmodule
