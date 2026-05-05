module MemoryModule
#(
    parameter ADDR_BITS = 16
)
(
	input  logic [ADDR_BITS - 1: 0] address,
	input  rvDefs::word_t writeData,
	input  logic memWrite,
	input  logic clk,
	input  logic [1:0] byteWriteEnable,
	output rvDefs::word_t readData,
    output rvDefs::word_t debugword
);
	rvDefs::word_t memory [1 << (ADDR_BITS-2)];
    assign readData = memory[address[ADDR_BITS-1:2]];
    assign debugword = memory[0];

    // write
    rvDefs::word_t mask;
    logic [3 : 0] bytemask;
    always_comb begin
        case (byteWriteEnable)
            2'b00: bytemask = (4'b1 << address[1:0]);
            2'b01: begin
                if(address[1]) bytemask = 4'b1100;
                else bytemask = 4'b0011;
            end
            2'b10: bytemask = 4'b1111;
    end
    assign mask = { {8{bytemask[3]}}, {8{bytemask[2]}}, {8{bytemask[1]}}, {8{bytemask[0]}} };
	always_ff @(posedge clk) begin
		if (memWrite) begin
            memory[address[ADDR_BITS-1:2]] <= (mask & writeData) | (~mask & memory[address[ADDR_BITS-1:2]]);
		end
	end
endmodule
