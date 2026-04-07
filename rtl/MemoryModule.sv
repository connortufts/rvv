module MemoryModule(
	input logic [31:0] address, 
	input logic [7:0] writeData [4],
	input logic memWrite,
	input logic memRead,
	input logic clk,
	input logic [3:0] byteWriteEnable, 								// Byte Write Enable
	output logic [7:0] readData [4],
	output logic OOBRead,
	output logic OOBWrite,
	output logic [32*4-1:0] debug_mem_contents_low, 	// Debug Mem(15 to 0)
	output logic [32*4-1:0] debug_mem_contents_high 	// Debug Mem(32 to 16)
);
    localparam int MemorySize = 16384;					// 16 KB of memory
	localparam int ZeroLocation = 16381;				// Highest location
	localparam int Word = 4;

	logic [7:0] memoryBytes [MemorySize];							

	// Memory controller with 3 bits for the max of 8 word reads/write

	initial begin
		for (int i = 0; i < MemorySize; i++) begin
			memoryBytes[i] = 8'h0;
		end
	end	

	always_ff @(posedge clk) begin
		OOBWrite <= 1'b0;
		OOBRead  <= 1'b0;

		// write to memory logic
		if (memWrite && ~memRead)	begin
			if (address <= MemorySize - Word) begin
				if (byteWriteEnable[3] == 1'b1) memoryBytes[address+3] <= writeData[3];
				if (byteWriteEnable[2] == 1'b1) memoryBytes[address+2] <= writeData[2];
				if (byteWriteEnable[1] == 1'b1) memoryBytes[address+1] <= writeData[1];
				if (byteWriteEnable[0] == 1'b1) memoryBytes[address] <= writeData[0];
			end else begin
				OOBWrite <= 1'b1;
			end
		end

		// read memory logic
		if (memRead && ~memWrite) begin
			if (address <= MemorySize - Word) begin
				readData[3] <= memoryBytes[address + 3];
				readData[2] <= memoryBytes[address + 2];
				readData[1] <= memoryBytes[address + 1];
				readData[0] <= memoryBytes[address];
				OOBRead <= 1'b0;
			end else begin
				OOBRead <= 1'b1;
				readData[3] <= 8'h0;
				readData[2] <= 8'h0;
				readData[1] <= 8'h0;
				readData[0] <= 8'h0;
			end
		end

		if ((~memRead) || (memRead && memWrite)) begin
			readData[3] <= 8'h0;
			readData[2] <= 8'h0;
			readData[1] <= 8'h0;
			readData[0] <= 8'h0;
		end
	end

	always_comb begin
		for (int i = 0; i < 16; i++) begin
			debug_mem_contents_low[i*8 +: 8]  = memoryBytes[i];
			debug_mem_contents_high[i*8 +: 8] = memoryBytes[i+16];
		end
	end
endmodule
