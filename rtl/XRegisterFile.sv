module XRegisterFile
(
    input  logic               clk,         // apply register writes if any on rising edge
    input  logic               writeEnable, // enable writing on clock edge
    input  rvDefs::xreg_addr_t read1Reg,    // address of register to send to read port 1
    input  rvDefs::xreg_addr_t read2Reg,    // address of register to send to read port 2
    input  rvDefs::xreg_addr_t writeReg,    // address of register to write to
    input  rvDefs::xreg_t      writeData,   // data to write to register
    output rvDefs::xreg_t      read1Data,   // data read from read1Reg
    output rvDefs::xreg_t      read2Data    // data read from read2Reg
);

    rvDefs::xreg_t registers [1 : rvDefs::XREG_COUNT - 1]; // x[0] doesnt actually need to exist (hardwired)

    always_ff @(posedge clk) begin
        if (writeEnable && (writeReg != rvDefs::xreg_addr_t'(0))) // cant write to register x0
            registers[writeReg] <= writeData;
    end

    assign read1Data = (read1Reg == rvDefs::xreg_addr_t'(0)) ? (rvDefs::xreg_t'(0)) : (registers[read1Reg]);
    assign read2Data = (read2Reg == rvDefs::xreg_addr_t'(0)) ? (rvDefs::xreg_t'(0)) : (registers[read2Reg]);

endmodule
