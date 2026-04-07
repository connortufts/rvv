module LSU (
    input logic  [2:0] memoryOpSize,
    input logic  [31:0] RegtoMemData,
    input logic unsignedLoad,
    input logic storeLoad,
    input logic  [31:0] Address,
    input logic  [7:0] ReadData [4],
    output logic MemWrite,
    output logic MemRead,
    output logic [7:0] WriteData [4],
    output logic [3:0] BWE,
    output logic [31:0] MemtoRegData,
    output logic [31:0] EffectiveAddress
);
    logic [1:0] ByteOffset;

    localparam unsigned [23:0] ByteZero     = 24'h000000;
    localparam unsigned [23:0] ByteOne      = 24'hFFFFFF;
    localparam unsigned [15:0] HalfWordZero = 16'h0000;
    localparam unsigned [15:0] HalfWordOne  = 16'hFFFF;

    assign ByteOffset = Address[1:0];
	assign EffectiveAddress = Address & 32'hFFFFFFFC;
    assign MemWrite = (memoryOpSize != 3'b011) && (storeLoad == 1'b1);
    assign MemRead = (memoryOpSize != 3'b011) && (storeLoad == 1'b0);

    always_comb begin
        BWE = 4'b0000;
        WriteData[0] = 8'h0;
        WriteData[1] = 8'h0;
        WriteData[2] = 8'h0;
        WriteData[3] = 8'h0;

        if (storeLoad == 1'b1) begin
            case (memoryOpSize)
                3'b000: begin
                    BWE = 4'b0001 << ByteOffset;
                    WriteData[ByteOffset] = RegtoMemData[7:0];
                end
                3'b001: begin
                    BWE = 4'b0011 << ByteOffset;
                    WriteData[ByteOffset]   = RegtoMemData[7:0];
                    WriteData[ByteOffset+1] = RegtoMemData[15:8];
                end
                3'b010: begin
                    BWE = 4'b1111;
                    WriteData[0] = RegtoMemData[7:0];
                    WriteData[1] = RegtoMemData[15:8];
                    WriteData[2] = RegtoMemData[23:16];
                    WriteData[3] = RegtoMemData[31:24];
                end
                default: BWE = 4'b0000;
            endcase
        end

        if (storeLoad == 1'b0) begin
            case (memoryOpSize)
                3'b000: begin
                    if (unsignedLoad) begin
                        MemtoRegData[31:8] = ByteZero;
                        MemtoRegData[7:0]  = ReadData[ByteOffset];
                    end else begin
                        if (ReadData[ByteOffset][7] == 1'b0) begin
                            MemtoRegData[31:8] = ByteZero;
                            MemtoRegData[7:0]  = ReadData[ByteOffset];
                        end else begin
                            MemtoRegData[31:8] = ByteOne;
                            MemtoRegData[7:0]  = ReadData[ByteOffset];
                        end
                    end
                end
                3'b001: begin
                    if (unsignedLoad) begin
                        MemtoRegData[31:16] = HalfWordZero;
                        MemtoRegData[15:8]  = ReadData[ByteOffset+1];
                        MemtoRegData[7:0]   = ReadData[ByteOffset];
                    end else begin
                        if (ReadData[ByteOffset+1][7] == 1'b0) begin
                            MemtoRegData[31:16] = HalfWordZero;
                            MemtoRegData[15:8]  = ReadData[ByteOffset+1];
                            MemtoRegData[7:0]   = ReadData[ByteOffset];
                        end else begin
                            MemtoRegData[31:16] = HalfWordOne;
                            MemtoRegData[15:8]  = ReadData[ByteOffset+1];
                            MemtoRegData[7:0]   = ReadData[ByteOffset];
                        end
                    end
                end
                3'b010: begin
                    MemtoRegData[31:24] = ReadData[3];
                    MemtoRegData[23:16] = ReadData[2];
                    MemtoRegData[15:8]  = ReadData[1];
                    MemtoRegData[7:0]   = ReadData[0];
                end
                default: MemtoRegData = 32'h0;
            endcase
        end
    end 
endmodule