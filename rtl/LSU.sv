module LSU (
    input logic  [1:0] memoryOpSize,
    input logic  [31:0] RegtoMemData,
    input logic unsignedLoad,
    input logic storeLoad,
    input logic  [31:0] address,
    input logic  [7:0] readData [4],
    output logic memWrite,
    output logic memRead,
    output logic [7:0] writeData [4],
    output logic [3:0] byteWriteEnable,
    output logic [31:0] MemtoRegData,
    output logic [31:0] effectiveAddress
);
    logic [1:0] byteOffset;

    localparam unsigned [23:0] ByteZero     = 24'h000000;
    localparam unsigned [23:0] ByteOne      = 24'hFFFFFF;
    localparam unsigned [15:0] HalfWordZero = 16'h0000;
    localparam unsigned [15:0] HalfWordOne  = 16'hFFFF;

    assign byteOffset = address[1:0];
	assign effectiveAddress = address & 32'hFFFFFFFC;
    assign memWrite = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) && (storeLoad == 1'b1);
    assign memRead = (memoryOpSize != rvDefs::MEMORY_OP_SIZE_NONE) && (storeLoad == 1'b0);

    always_comb begin
        byteWriteEnable = 4'b0000;
        writeData[0] = 8'h0;
        writeData[1] = 8'h0;
        writeData[2] = 8'h0;
        writeData[3] = 8'h0;

        if (storeLoad == 1'b1) begin
            case (memoryOpSize)
                rvDefs::MEMORY_OP_SIZE_BYTE: begin
                    byteWriteEnable = 4'b0001 << byteOffset;
                    writeData[byteOffset] = RegtoMemData[7:0];
                end
                rvDefs::MEMORY_OP_SIZE_HALF: begin
                    byteWriteEnable = 4'b0011 << byteOffset;
                    writeData[byteOffset]   = RegtoMemData[7:0];
                    writeData[byteOffset+1] = RegtoMemData[15:8];
                end
                rvDefs::MEMORY_OP_SIZE_WORD: begin
                    byteWriteEnable = 4'b1111;
                    writeData[0] = RegtoMemData[7:0];
                    writeData[1] = RegtoMemData[15:8];
                    writeData[2] = RegtoMemData[23:16];
                    writeData[3] = RegtoMemData[31:24];
                end
                default: byteWriteEnable = 4'b0000;
            endcase
        end

        if (storeLoad == 1'b0) begin
            case (memoryOpSize)
                rvDefs::MEMORY_OP_SIZE_BYTE: begin
                    if (unsignedLoad) begin
                        MemtoRegData[31:8] = ByteZero;
                        MemtoRegData[7:0]  = readData[byteOffset];
                    end else begin
                        if (readData[byteOffset][7] == 1'b0) begin
                            MemtoRegData[31:8] = ByteZero;
                            MemtoRegData[7:0]  = readData[byteOffset];
                        end else begin
                            MemtoRegData[31:8] = ByteOne;
                            MemtoRegData[7:0]  = readData[byteOffset];
                        end
                    end
                end
                rvDefs::MEMORY_OP_SIZE_HALF: begin
                    if (unsignedLoad) begin
                        MemtoRegData[31:16] = HalfWordZero;
                        MemtoRegData[15:8]  = readData[byteOffset+1];
                        MemtoRegData[7:0]   = readData[byteOffset];
                    end else begin
                        if (readData[byteOffset+1][7] == 1'b0) begin
                            MemtoRegData[31:16] = HalfWordZero;
                            MemtoRegData[15:8]  = readData[byteOffset+1];
                            MemtoRegData[7:0]   = readData[byteOffset];
                        end else begin
                            MemtoRegData[31:16] = HalfWordOne;
                            MemtoRegData[15:8]  = readData[byteOffset+1];
                            MemtoRegData[7:0]   = readData[byteOffset];
                        end
                    end
                end
                rvDefs::MEMORY_OP_SIZE_WORD: begin
                    MemtoRegData[31:24] = readData[3];
                    MemtoRegData[23:16] = readData[2];
                    MemtoRegData[15:8]  = readData[1];
                    MemtoRegData[7:0]   = readData[0];
                end
                default: MemtoRegData = 32'h0;
            endcase
        end
    end 
endmodule