module MemoryModule
#(
    parameter ADDR_BITS = 16
)
(
	input  logic [ADDR_BITS - 1 : 0] address,
	input  rvDefs::word_t writeData,
	input  logic memWrite,
	input  logic clk,
	input  logic [3:0] byteWriteEnable, 				// Byte Write Enable
	output rvDefs::word_t readData
);
	rvDefs::word_t memory [1 << ADDR_BITS];
    assign readData = memory[address];

    // write
    rvDefs::word_t mask;
    assign mask = { {8{byteWriteEnable[3]}}, {8{byteWriteEnable[2]}}, {8{byteWriteEnable[1]}}, {8{byteWriteEnable[0]}} };
	always_ff @(posedge clk) begin
		if (memWrite) begin
            memory[address] <= (mask & writeData) | (~mask & memory[address]);
		end
	end
endmodule

