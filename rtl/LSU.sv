import rvDefs::*;
module LSU (
    input  memory_op_size_t memoryOpSize,
    input  logic                    unsignedLoad,
    input  logic                    storeLoad,
    input  mem_addr_t       address,
    input  word_t           readData,
    output logic                    memWrite,
    output logic                    memRead,
    output logic [2:0]              memSize,
    output word_t           memToRegData
);

    assign memWrite = (memoryOpSize != MEMORY_OP_SIZE_NONE) && (storeLoad == 1'b1);
    assign memRead = (memoryOpSize != MEMORY_OP_SIZE_NONE) && (storeLoad == 1'b0);

    always_comb begin
        case (memoryOpSize)
            MEMORY_OP_SIZE_BYTE: memSize = 3'b000;
            MEMORY_OP_SIZE_HALF: memSize = 3'b001;
            MEMORY_OP_SIZE_WORD: memSize = 3'b010;
            default: memSize = 3'b111;
        endcase
        case (memoryOpSize)
            MEMORY_OP_SIZE_BYTE: begin
                memToRegData = {
                    unsignedLoad ? (24'b0) : ({24{{readData >> (8 * address[1 : 0])}[7]}}), // conditional sign extension
                    {readData >> (8 * address[1:0])}[7 : 0]
                };
            end
            MEMORY_OP_SIZE_HALF: begin
                memToRegData = {
                    unsignedLoad ? (16'b0) : ({16{{readData >> (16 * address[1])}[15]}}), // conditional sign extension
                    {readData >> (16 * address[1])}[15 : 0]
                };
            end
            MEMORY_OP_SIZE_WORD: begin
                memToRegData = readData;
            end
            default: memToRegData = 32'b0;
        endcase
    end 
endmodule
