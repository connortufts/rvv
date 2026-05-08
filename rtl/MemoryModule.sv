`timescale 1ns/1ps
module MemoryModule
#(
    parameter ADDR_BITS = 16
)
(
	input  rvDefs::mem_addr_t address,
	input  rvDefs::word_t writeData,
	input  logic memWrite,
	input  logic clk,
	input  logic [2:0] memSize,
	output rvDefs::word_t readData
);
	rvDefs::word_t memory [1 << (ADDR_BITS - 2)];
    assign readData = memory[address];

    // write
    rvDefs::word_t mask;
    always_comb begin
        case (memSize)
            3'b000: mask = 32'hFF << {address[1 : 0], 3'b0};
            3'b001: mask = 32'hFFFF << {address[1], 4'b0};
            3'b010: mask = 32'hFFFFFFFF;
            default: mask = 32'b0;
        endcase
    end
	always_ff @(posedge clk) begin
		if (memWrite) begin
            memory[address[ADDR_BITS - 1 : 2]] <= (mask & writeData) | (~mask & memory[address[ADDR_BITS - 1 : 2]]);
		end
	end
endmodule
