module InstructionMemory
#(
    parameter ADDR_BITS = 8
)
(
    input  rvDefs::mem_addr_t    address,
    output rvDefs::instruction_t instruction
);

    rvDefs::instruction_t memory [1 << ADDR_BITS];
    assign instruction = memory[address[ADDR_BITS + 1 : 2]]; // this drops byte offset from 32 bit address

    initial begin
        $readmemh("imem", memory);
    end

endmodule
