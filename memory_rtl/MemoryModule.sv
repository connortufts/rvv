module MemoryModule(
	input logic [31:0] Address, 
	input logic [7:0] WriteData [4],
	input logic MemWrite,
	input logic MemRead,
	input logic CLK,
	input logic [3:0] BWE, 								// Byte Write Enable
	output logic [7:0] ReadData [4],
	output logic OOBRead,
	output logic OOBWrite,
	output logic [32*4-1:0] debug_mem_contents_low, 	// Debug Mem(15 to 0)
	output logic [32*4-1:0] debug_mem_contents_high 	// Debug Mem(32 to 16)
);
    localparam int MemorySize = 16384;					// 16 KB of memory
	localparam int ZeroLocation = 16381;				// Highest location
	localparam int Word = 4;							

	// Memory controller with 3 bits for the max of 8 word reads/write

	initial begin
		for (int i = 0; i < MemorySize; i++) begin
			MemoryBytes[i] = 8'h0;
		end
	end	

	always_ff @(posedge CLK) begin
		OOBWrite <= 1'b0;
		OOBRead  <= 1'b0;

		// write to memory logic
		if (MemWrite && ~MemRead)	begin
			if (Address <= MemorySize - Word) begin
				if (BWE[3] == 1'b1) MemoryBytes[Address+3] <= WriteData[3];
				if (BWE[2] == 1'b1) MemoryBytes[Address+2] <= WriteData[2];
				if (BWE[1] == 1'b1) MemoryBytes[Address+1] <= WriteData[1];
				if (BWE[0] == 1'b1) MemoryBytes[Address] <= WriteData[0];
			end else begin
				OOBWrite <= 1'b1;
			end
		end

		// read memory logic
		if (MemRead && ~MemWrite) begin
			if (Address <= MemorySize - Word) begin
				ReadData[3] <= MemoryBytes[Address + 3];
				ReadData[2] <= MemoryBytes[Address + 2];
				ReadData[1] <= MemoryBytes[Address + 1];
				ReadData[0] <= MemoryBytes[Address];
				OOBRead <= 1'b0;
			end else begin
				OOBRead <= 1'b1;
				ReadData[3] <= 8'h0;
				ReadData[2] <= 8'h0;
				ReadData[1] <= 8'h0;
				ReadData[0] <= 8'h0;
			end
		end

		if ((~MemRead) || (MemRead && MemWrite)) begin
			ReadData[3] <= 8'h0;
			ReadData[2] <= 8'h0;
			ReadData[1] <= 8'h0;
			ReadData[0] <= 8'h0;
		end
	end

	always_comb begin
		for (int i = 0; i < 16; i++) begin
			debug_mem_contents_low[i*8 +: 8]  = MemoryBytes[i];
			debug_mem_contents_high[i*8 +: 8] = MemoryBytes[i+16];
		end
	end
endmodule
