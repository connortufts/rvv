module CSR (
    input  logic              clk,
    input  logic              rstn,
    input  logic              writeEnable,
    input  rvDefs::csr_addr_t addr,
    input  rvDefs::word_t     writeData,
    output rvDefs::word_t     readData
);

    // RO
    //0xF11
    rvDefs::word_t mvendorid;
    assign mvendorid = 32'd0;
    //0xF12
    rvDefs::word_t marchid;
    assign marchid = 32'd0;
    //0xF13
    rvDefs::word_t mimpid;
    assign mimpid = 32'd0;
    //0xF14
    rvDefs::word_t mhartid;
    assign mhartid = 32'd0;
    //0xF15
    rvDefs::word_t mconfigptr;
    assign mconfigptr = 32'd0;

    // RW
    //0x300
    rvDefs::word_t mstatus;
    //0x301
    rvDefs::word_t misa;
    assign misa = 32'b01000000001000000000000100000000;
    //0x302
    rvDefs::word_t medeleg;
    assign medeleg = 32'd0;
    //0x303
    rvDefs::word_t mideleg;
    assign mideleg = 32'd0;
    //0x304
    rvDefs::word_t mie;
    //0x305
    rvDefs::word_t mtvec;
    //0x310
    rvDefs::word_t mstatush;
    //0x312
    rvDefs::word_t medelegh;
    assign medelegh = 32'b0;

    // RW
    //0x340
    rvDefs::word_t mscratch;
    //0x341
    rvDefs::word_t mepc;
    //0x342
    rvDefs::word_t mcause;
    //0x343
    rvDefs::word_t mtval;
    assign mtval = 32'd0;
    //0x344
    rvDefs::word_t mip;
    assign mip = 32'd0;

    // RW
    //0xB00
    rvDefs::doubleword_t mcyclef;
    rvDefs::word_t mcycle;
    assign mcycle = mcyclef[31 : 0];
    //0xB02
    rvDefs::doubleword_t minstretf;
    rvDefs::word_t minstret;
    assign minstret = minstretf[31 : 0];
    //0xB03
    rvDefs::doubleword_t mhpmcounter3f;
    rvDefs::word_t mhpmcounter3;
    assign mhpmcounter3 = mhpmcounter3f[31 : 0];
    //0xB04
    rvDefs::doubleword_t mhpmcounter4f;
    rvDefs::word_t mhpmcounter4;
    assign mhpmcounter4 = mhpmcounter4f[31 : 0];
    //0xB05
    rvDefs::doubleword_t mhpmcounter5f;
    rvDefs::word_t mhpmcounter5;
    assign mhpmcounter5 = mhpmcounter5f[31 : 0];
    //0xB06
    rvDefs::doubleword_t mhpmcounter6f;
    rvDefs::word_t mhpmcounter6;
    assign mhpmcounter6 = mhpmcounter6f[31 : 0];
    //0xB07
    rvDefs::doubleword_t mhpmcounter7f;
    rvDefs::word_t mhpmcounter7;
    assign mhpmcounter7 = mhpmcounter7f[31 : 0];
    //0xB08
    rvDefs::doubleword_t mhpmcounter8f;
    rvDefs::word_t mhpmcounter8;
    assign mhpmcounter8 = mhpmcounter8f[31 : 0];
    //0xB09
    rvDefs::doubleword_t mhpmcounter9f;
    rvDefs::word_t mhpmcounter9;
    assign mhpmcounter9 = mhpmcounter9f[31 : 0];
    //0xB0A
    rvDefs::doubleword_t mhpmcounter10f;
    rvDefs::word_t mhpmcounter10;
    assign mhpmcounter10 = mhpmcounter10f[31 : 0];
    //0xB0B
    rvDefs::doubleword_t mhpmcounter11f;
    rvDefs::word_t mhpmcounter11;
    assign mhpmcounter11 = mhpmcounter11f[31 : 0];
    //0xB0C
    rvDefs::doubleword_t mhpmcounter12f;
    rvDefs::word_t mhpmcounter12;
    assign mhpmcounter12 = mhpmcounter12f[31 : 0];
    //0xB0D
    rvDefs::doubleword_t mhpmcounter13f;
    rvDefs::word_t mhpmcounter13;
    assign mhpmcounter13 = mhpmcounter13f[31 : 0];
    //0xB0E
    rvDefs::doubleword_t mhpmcounter14f;
    rvDefs::word_t mhpmcounter14;
    assign mhpmcounter14 = mhpmcounter14f[31 : 0];
    //0xB0F
    rvDefs::doubleword_t mhpmcounter15f;
    rvDefs::word_t mhpmcounter15;
    assign mhpmcounter15 = mhpmcounter15f[31 : 0];
    //0xB10
    rvDefs::doubleword_t mhpmcounter16f;
    rvDefs::word_t mhpmcounter16;
    assign mhpmcounter16 = mhpmcounter16f[31 : 0];
    //0xB11
    rvDefs::doubleword_t mhpmcounter17f;
    rvDefs::word_t mhpmcounter17;
    assign mhpmcounter17 = mhpmcounter17f[31 : 0];
    //0xB12
    rvDefs::doubleword_t mhpmcounter18f;
    rvDefs::word_t mhpmcounter18;
    assign mhpmcounter18 = mhpmcounter18f[31 : 0];
    //0xB13
    rvDefs::doubleword_t mhpmcounter19f;
    rvDefs::word_t mhpmcounter19;
    assign mhpmcounter19 = mhpmcounter19f[31 : 0];
    //0xB14
    rvDefs::doubleword_t mhpmcounter20f;
    rvDefs::word_t mhpmcounter20;
    assign mhpmcounter20 = mhpmcounter20f[31 : 0];
    //0xB15
    rvDefs::doubleword_t mhpmcounter21f;
    rvDefs::word_t mhpmcounter21;
    assign mhpmcounter21 = mhpmcounter21f[31 : 0];
    //0xB16
    rvDefs::doubleword_t mhpmcounter22f;
    rvDefs::word_t mhpmcounter22;
    assign mhpmcounter22 = mhpmcounter22f[31 : 0];
    //0xB17
    rvDefs::doubleword_t mhpmcounter23f;
    rvDefs::word_t mhpmcounter23;
    assign mhpmcounter23 = mhpmcounter23f[31 : 0];
    //0xB18
    rvDefs::doubleword_t mhpmcounter24f;
    rvDefs::word_t mhpmcounter24;
    assign mhpmcounter24 = mhpmcounter24f[31 : 0];
    //0xB19
    rvDefs::doubleword_t mhpmcounter25f;
    rvDefs::word_t mhpmcounter25;
    assign mhpmcounter25 = mhpmcounter25f[31 : 0];
    //0xB1A
    rvDefs::doubleword_t mhpmcounter26f;
    rvDefs::word_t mhpmcounter26;
    assign mhpmcounter26 = mhpmcounter26f[31 : 0];
    //0xB1B
    rvDefs::doubleword_t mhpmcounter27f;
    rvDefs::word_t mhpmcounter27;
    assign mhpmcounter27 = mhpmcounter27f[31 : 0];
    //0xB1C
    rvDefs::doubleword_t mhpmcounter28f;
    rvDefs::word_t mhpmcounter28;
    assign mhpmcounter28 = mhpmcounter28f[31 : 0];
    //0xB1D
    rvDefs::doubleword_t mhpmcounter29f;
    rvDefs::word_t mhpmcounter29;
    assign mhpmcounter29 = mhpmcounter29f[31 : 0];
    //0xB1E
    rvDefs::doubleword_t mhpmcounter30f;
    rvDefs::word_t mhpmcounter30;
    assign mhpmcounter30 = mhpmcounter30f[31 : 0];
    //0xB1F
    rvDefs::doubleword_t mhpmcounter31f;
    rvDefs::word_t mhpmcounter31;
    assign mhpmcounter31 = mhpmcounter31f[31 : 0];
    //0xB80
    rvDefs::word_t mcycleh;
    assign mcycleh = mcyclef[63 : 32];
    //0xB82
    rvDefs::word_t minstreth;
    assign minstreth = minstretf[63 : 32];
    //0xB83
    rvDefs::word_t mhpmcounter3h;
    assign mhpmcounter3h = mhpmcounter3f[63 : 32];
    //0xB84
    rvDefs::word_t mhpmcounter4h;
    assign mhpmcounter4h = mhpmcounter4f[63 : 32];
    //0xB85
    rvDefs::word_t mhpmcounter5h;
    assign mhpmcounter5h = mhpmcounter5f[63 : 32];
    //0xB86
    rvDefs::word_t mhpmcounter6h;
    assign mhpmcounter6h = mhpmcounter6f[63 : 32];
    //0xB87
    rvDefs::word_t mhpmcounter7h;
    assign mhpmcounter7h = mhpmcounter7f[63 : 32];
    //0xB88
    rvDefs::word_t mhpmcounter8h;
    assign mhpmcounter8h = mhpmcounter8f[63 : 32];
    //0xB89
    rvDefs::word_t mhpmcounter9h;
    assign mhpmcounter9h = mhpmcounter9f[63 : 32];
    //0xB8A
    rvDefs::word_t mhpmcounter10h;
    assign mhpmcounter10h = mhpmcounter10f[63 : 32];
    //0xB8B
    rvDefs::word_t mhpmcounter11h;
    assign mhpmcounter11h = mhpmcounter11f[63 : 32];
    //0xB8C
    rvDefs::word_t mhpmcounter12h;
    assign mhpmcounter12h = mhpmcounter12f[63 : 32];
    //0xB8D
    rvDefs::word_t mhpmcounter13h;
    assign mhpmcounter13h = mhpmcounter13f[63 : 32];
    //0xB8E
    rvDefs::word_t mhpmcounter14h;
    assign mhpmcounter14h = mhpmcounter14f[63 : 32];
    //0xB8F
    rvDefs::word_t mhpmcounter15h;
    assign mhpmcounter15h = mhpmcounter15f[63 : 32];
    //0xB90
    rvDefs::word_t mhpmcounter16h;
    assign mhpmcounter16h = mhpmcounter16f[63 : 32];
    //0xB91
    rvDefs::word_t mhpmcounter17h;
    assign mhpmcounter17h = mhpmcounter17f[63 : 32];
    //0xB92
    rvDefs::word_t mhpmcounter18h;
    assign mhpmcounter18h = mhpmcounter18f[63 : 32];
    //0xB93
    rvDefs::word_t mhpmcounter19h;
    assign mhpmcounter19h = mhpmcounter19f[63 : 32];
    //0xB94
    rvDefs::word_t mhpmcounter20h;
    assign mhpmcounter20h = mhpmcounter20f[63 : 32];
    //0xB95
    rvDefs::word_t mhpmcounter21h;
    assign mhpmcounter21h = mhpmcounter21f[63 : 32];
    //0xB96
    rvDefs::word_t mhpmcounter22h;
    assign mhpmcounter22h = mhpmcounter22f[63 : 32];
    //0xB97
    rvDefs::word_t mhpmcounter23h;
    assign mhpmcounter23h = mhpmcounter23f[63 : 32];
    //0xB98
    rvDefs::word_t mhpmcounter24h;
    assign mhpmcounter24h = mhpmcounter24f[63 : 32];
    //0xB99
    rvDefs::word_t mhpmcounter25h;
    assign mhpmcounter25h = mhpmcounter25f[63 : 32];
    //0xB9A
    rvDefs::word_t mhpmcounter26h;
    assign mhpmcounter26h = mhpmcounter26f[63 : 32];
    //0xB9B
    rvDefs::word_t mhpmcounter27h;
    assign mhpmcounter27h = mhpmcounter27f[63 : 32];
    //0xB9C
    rvDefs::word_t mhpmcounter28h;
    assign mhpmcounter28h = mhpmcounter28f[63 : 32];
    //0xB9D
    rvDefs::word_t mhpmcounter29h;
    assign mhpmcounter29h = mhpmcounter29f[63 : 32];
    //0xB9E
    rvDefs::word_t mhpmcounter30h;
    assign mhpmcounter30h = mhpmcounter30f[63 : 32];
    //0xB9F
    rvDefs::word_t mhpmcounter31h;
    assign mhpmcounter31h = mhpmcounter31f[63 : 32];

    //RW
    //0x320
    rvDefs::word_t mcountinhibit;
    //0x323
    rvDefs::doubleword_t mhpmevent3f;
    rvDefs::word_t mhpmevent3;
    assign mhpmevent3 = mhpmevent3f[31 : 0];
    //0x324
    rvDefs::doubleword_t mhpmevent4f;
    rvDefs::word_t mhpmevent4;
    assign mhpmevent4 = mhpmevent4f[31 : 0];
    //0x325
    rvDefs::doubleword_t mhpmevent5f;
    rvDefs::word_t mhpmevent5;
    assign mhpmevent5 = mhpmevent5f[31 : 0];
    //0x326
    rvDefs::doubleword_t mhpmevent6f;
    rvDefs::word_t mhpmevent6;
    assign mhpmevent6 = mhpmevent6f[31 : 0];
    //0x327
    rvDefs::doubleword_t mhpmevent7f;
    rvDefs::word_t mhpmevent7;
    assign mhpmevent7 = mhpmevent7f[31 : 0];
    //0x328
    rvDefs::doubleword_t mhpmevent8f;
    rvDefs::word_t mhpmevent8;
    assign mhpmevent8 = mhpmevent8f[31 : 0];
    //0x329
    rvDefs::doubleword_t mhpmevent9f;
    rvDefs::word_t mhpmevent9;
    assign mhpmevent9 = mhpmevent9f[31 : 0];
    //0x32A
    rvDefs::doubleword_t mhpmevent10f;
    rvDefs::word_t mhpmevent10;
    assign mhpmevent10 = mhpmevent10f[31 : 0];
    //0x32B
    rvDefs::doubleword_t mhpmevent11f;
    rvDefs::word_t mhpmevent11;
    assign mhpmevent11 = mhpmevent11f[31 : 0];
    //0x32C
    rvDefs::doubleword_t mhpmevent12f;
    rvDefs::word_t mhpmevent12;
    assign mhpmevent12 = mhpmevent12f[31 : 0];
    //0x32D
    rvDefs::doubleword_t mhpmevent13f;
    rvDefs::word_t mhpmevent13;
    assign mhpmevent13 = mhpmevent13f[31 : 0];
    //0x32E
    rvDefs::doubleword_t mhpmevent14f;
    rvDefs::word_t mhpmevent14;
    assign mhpmevent14 = mhpmevent14f[31 : 0];
    //0x32F
    rvDefs::doubleword_t mhpmevent15f;
    rvDefs::word_t mhpmevent15;
    assign mhpmevent15 = mhpmevent15f[31 : 0];
    //0x330
    rvDefs::doubleword_t mhpmevent16f;
    rvDefs::word_t mhpmevent16;
    assign mhpmevent16 = mhpmevent16f[31 : 0];
    //0x331
    rvDefs::doubleword_t mhpmevent17f;
    rvDefs::word_t mhpmevent17;
    assign mhpmevent17 = mhpmevent17f[31 : 0];
    //0x332
    rvDefs::doubleword_t mhpmevent18f;
    rvDefs::word_t mhpmevent18;
    assign mhpmevent18 = mhpmevent18f[31 : 0];
    //0x333
    rvDefs::doubleword_t mhpmevent19f;
    rvDefs::word_t mhpmevent19;
    assign mhpmevent19 = mhpmevent19f[31 : 0];
    //0x334
    rvDefs::doubleword_t mhpmevent20f;
    rvDefs::word_t mhpmevent20;
    assign mhpmevent20 = mhpmevent20f[31 : 0];
    //0x335
    rvDefs::doubleword_t mhpmevent21f;
    rvDefs::word_t mhpmevent21;
    assign mhpmevent21 = mhpmevent21f[31 : 0];
    //0x336
    rvDefs::doubleword_t mhpmevent22f;
    rvDefs::word_t mhpmevent22;
    assign mhpmevent22 = mhpmevent22f[31 : 0];
    //0x337
    rvDefs::doubleword_t mhpmevent23f;
    rvDefs::word_t mhpmevent23;
    assign mhpmevent23 = mhpmevent23f[31 : 0];
    //0x338
    rvDefs::doubleword_t mhpmevent24f;
    rvDefs::word_t mhpmevent24;
    assign mhpmevent24 = mhpmevent24f[31 : 0];
    //0x339
    rvDefs::doubleword_t mhpmevent25f;
    rvDefs::word_t mhpmevent25;
    assign mhpmevent25 = mhpmevent25f[31 : 0];
    //0x33A
    rvDefs::doubleword_t mhpmevent26f;
    rvDefs::word_t mhpmevent26;
    assign mhpmevent26 = mhpmevent26f[31 : 0];
    //0x33B
    rvDefs::doubleword_t mhpmevent27f;
    rvDefs::word_t mhpmevent27;
    assign mhpmevent27 = mhpmevent27f[31 : 0];
    //0x33C
    rvDefs::doubleword_t mhpmevent28f;
    rvDefs::word_t mhpmevent28;
    assign mhpmevent28 = mhpmevent28f[31 : 0];
    //0x33D
    rvDefs::doubleword_t mhpmevent29f;
    rvDefs::word_t mhpmevent29;
    assign mhpmevent29 = mhpmevent29f[31 : 0];
    //0x33E
    rvDefs::doubleword_t mhpmevent30f;
    rvDefs::word_t mhpmevent30;
    assign mhpmevent30 = mhpmevent30f[31 : 0];
    //0x33F
    rvDefs::doubleword_t mhpmevent31f;
    rvDefs::word_t mhpmevent31;
    assign mhpmevent31 = mhpmevent31f[31 : 0];
    //0x723
    rvDefs::word_t mhpmevent3h;
    assign mhpmevent3h = mhpmevent3f[63 : 32];
    //0x724
    rvDefs::word_t mhpmevent4h;
    assign mhpmevent4h = mhpmevent4f[63 : 32];
    //0x725
    rvDefs::word_t mhpmevent5h;
    assign mhpmevent5h = mhpmevent5f[63 : 32];
    //0x726
    rvDefs::word_t mhpmevent6h;
    assign mhpmevent6h = mhpmevent6f[63 : 32];
    //0x727
    rvDefs::word_t mhpmevent7h;
    assign mhpmevent7h = mhpmevent7f[63 : 32];
    //0x728
    rvDefs::word_t mhpmevent8h;
    assign mhpmevent8h = mhpmevent8f[63 : 32];
    //0x729
    rvDefs::word_t mhpmevent9h;
    assign mhpmevent9h = mhpmevent9f[63 : 32];
    //0x72A
    rvDefs::word_t mhpmevent10h;
    assign mhpmevent10h = mhpmevent10f[63 : 32];
    //0x72B
    rvDefs::word_t mhpmevent11h;
    assign mhpmevent11h = mhpmevent11f[63 : 32];
    //0x72C
    rvDefs::word_t mhpmevent12h;
    assign mhpmevent12h = mhpmevent12f[63 : 32];
    //0x72D
    rvDefs::word_t mhpmevent13h;
    assign mhpmevent13h = mhpmevent13f[63 : 32];
    //0x72E
    rvDefs::word_t mhpmevent14h;
    assign mhpmevent14h = mhpmevent14f[63 : 32];
    //0x72F
    rvDefs::word_t mhpmevent15h;
    assign mhpmevent15h = mhpmevent15f[63 : 32];
    //0x730
    rvDefs::word_t mhpmevent16h;
    assign mhpmevent16h = mhpmevent16f[63 : 32];
    //0x731
    rvDefs::word_t mhpmevent17h;
    assign mhpmevent17h = mhpmevent17f[63 : 32];
    //0x732
    rvDefs::word_t mhpmevent18h;
    assign mhpmevent18h = mhpmevent18f[63 : 32];
    //0x733
    rvDefs::word_t mhpmevent19h;
    assign mhpmevent19h = mhpmevent19f[63 : 32];
    //0x734
    rvDefs::word_t mhpmevent20h;
    assign mhpmevent20h = mhpmevent20f[63 : 32];
    //0x735
    rvDefs::word_t mhpmevent21h;
    assign mhpmevent21h = mhpmevent21f[63 : 32];
    //0x736
    rvDefs::word_t mhpmevent22h;
    assign mhpmevent22h = mhpmevent22f[63 : 32];
    //0x737
    rvDefs::word_t mhpmevent23h;
    assign mhpmevent23h = mhpmevent23f[63 : 32];
    //0x738
    rvDefs::word_t mhpmevent24h;
    assign mhpmevent24h = mhpmevent24f[63 : 32];
    //0x739
    rvDefs::word_t mhpmevent25h;
    assign mhpmevent25h = mhpmevent25f[63 : 32];
    //0x73A
    rvDefs::word_t mhpmevent26h;
    assign mhpmevent26h = mhpmevent26f[63 : 32];
    //0x73B
    rvDefs::word_t mhpmevent27h;
    assign mhpmevent27h = mhpmevent27f[63 : 32];
    //0x73C
    rvDefs::word_t mhpmevent28h;
    assign mhpmevent28h = mhpmevent28f[63 : 32];
    //0x73D
    rvDefs::word_t mhpmevent29h;
    assign mhpmevent29h = mhpmevent29f[63 : 32];
    //0x73E
    rvDefs::word_t mhpmevent30h;
    assign mhpmevent30h = mhpmevent30f[63 : 32];
    //0x73F
    rvDefs::word_t mhpmevent31h;
    assign mhpmevent31h = mhpmevent31f[63 : 32];

    // CSR write + hardware update logic
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mvendorid <= rvDefs::word_t'(0);
            marchid <= rvDefs::word_t'(0);
            mimpid <= rvDefs::word_t'(0);
            mhartid <= rvDefs::word_t'(0);
            mconfigptr <= rvDefs::word_t'(0);
            mstatus <= rvDefs::word_t'(0);
            misa <= rvDefs::word_t'(0);
            medeleg <= rvDefs::word_t'(0);
            mideleg <= rvDefs::word_t'(0);
            mie <= rvDefs::word_t'(0);
            mtvec <= rvDefs::word_t'(0);
            mstatush <= rvDefs::word_t'(0);
            medelegh <= rvDefs::word_t'(0);
            mscratch <= rvDefs::word_t'(0);
            mepc <= rvDefs::word_t'(0);
            mcause <= rvDefs::word_t'(0);
            mtval <= rvDefs::word_t'(0);
            mip <= rvDefs::word_t'(0);
            minstretf <= rvDefs::doubleword_t'(0);
            mhpmcounter3f <= rvDefs::doubleword_t'(0);
            mhpmcounter4f <= rvDefs::doubleword_t'(0);
            mhpmcounter5f <= rvDefs::doubleword_t'(0);
            mhpmcounter6f <= rvDefs::doubleword_t'(0);
            mhpmcounter7f <= rvDefs::doubleword_t'(0);
            mhpmcounter8f <= rvDefs::doubleword_t'(0);
            mhpmcounter9f <= rvDefs::doubleword_t'(0);
            mhpmcounter10f <= rvDefs::doubleword_t'(0);
            mhpmcounter11f <= rvDefs::doubleword_t'(0);
            mhpmcounter12f <= rvDefs::doubleword_t'(0);
            mhpmcounter13f <= rvDefs::doubleword_t'(0);
            mhpmcounter14f <= rvDefs::doubleword_t'(0);
            mhpmcounter15f <= rvDefs::doubleword_t'(0);
            mhpmcounter16f <= rvDefs::doubleword_t'(0);
            mhpmcounter17f <= rvDefs::doubleword_t'(0);
            mhpmcounter18f <= rvDefs::doubleword_t'(0);
            mhpmcounter19f <= rvDefs::doubleword_t'(0);
            mhpmcounter20f <= rvDefs::doubleword_t'(0);
            mhpmcounter21f <= rvDefs::doubleword_t'(0);
            mhpmcounter22f <= rvDefs::doubleword_t'(0);
            mhpmcounter23f <= rvDefs::doubleword_t'(0);
            mhpmcounter24f <= rvDefs::doubleword_t'(0);
            mhpmcounter25f <= rvDefs::doubleword_t'(0);
            mhpmcounter26f <= rvDefs::doubleword_t'(0);
            mhpmcounter27f <= rvDefs::doubleword_t'(0);
            mhpmcounter28f <= rvDefs::doubleword_t'(0);
            mhpmcounter29f <= rvDefs::doubleword_t'(0);
            mhpmcounter30f <= rvDefs::doubleword_t'(0);
            mhpmcounter31f <= rvDefs::doubleword_t'(0);
            mcyclef <= rvDefs::doubleword_t'(0);
            minstretf <= rvDefs::doubleword_t'(0);
            mcountinhibit <= rvDefs::word_t'(0);
            mhpmevent3f <= rvDefs::doubleword_t'(0);
            mhpmevent4f <= rvDefs::doubleword_t'(0);
            mhpmevent5f <= rvDefs::doubleword_t'(0);
            mhpmevent6f <= rvDefs::doubleword_t'(0);
            mhpmevent7f <= rvDefs::doubleword_t'(0);
            mhpmevent8f <= rvDefs::doubleword_t'(0);
            mhpmevent9f <= rvDefs::doubleword_t'(0);
            mhpmevent10f <= rvDefs::doubleword_t'(0);
            mhpmevent11f <= rvDefs::doubleword_t'(0);
            mhpmevent12f <= rvDefs::doubleword_t'(0);
            mhpmevent13f <= rvDefs::doubleword_t'(0);
            mhpmevent14f <= rvDefs::doubleword_t'(0);
            mhpmevent15f <= rvDefs::doubleword_t'(0);
            mhpmevent16f <= rvDefs::doubleword_t'(0);
            mhpmevent17f <= rvDefs::doubleword_t'(0);
            mhpmevent18f <= rvDefs::doubleword_t'(0);
            mhpmevent19f <= rvDefs::doubleword_t'(0);
            mhpmevent20f <= rvDefs::doubleword_t'(0);
            mhpmevent21f <= rvDefs::doubleword_t'(0);
            mhpmevent22f <= rvDefs::doubleword_t'(0);
            mhpmevent23f <= rvDefs::doubleword_t'(0);
            mhpmevent24f <= rvDefs::doubleword_t'(0);
            mhpmevent25f <= rvDefs::doubleword_t'(0);
            mhpmevent26f <= rvDefs::doubleword_t'(0);
            mhpmevent27f <= rvDefs::doubleword_t'(0);
            mhpmevent28f <= rvDefs::doubleword_t'(0);
            mhpmevent29f <= rvDefs::doubleword_t'(0);
            mhpmevent30f <= rvDefs::doubleword_t'(0);
            mhpmevent31f <= rvDefs::doubleword_t'(0);
        end
        else begin

            // Software CSR writes (from SYSTEM instruction path)
            if (writeEnable) begin
                case (addr)
                    rvDefs::CSR_MVENDORID: mvendorid <= writeData;
                    rvDefs::CSR_MARCHID: marchid <= writeData;
                    rvDefs::CSR_MIMPID: mimpid <= writeData;
                    rvDefs::CSR_MHARTID: mhartid <= writeData;
                    rvDefs::CSR_MCONFIGPTR: mconfigptr <= writeData;
                    rvDefs::CSR_MSTATUS: mstatus <= writeData;
                    rvDefs::CSR_MISA: misa <= writeData;
                    rvDefs::CSR_MEDELEG: medeleg <= writeData;
                    rvDefs::CSR_MIDELEG: mideleg <= writeData;
                    rvDefs::CSR_MIE: mie <= writeData;
                    rvDefs::CSR_MTVEC: mtvec <= writeData;
                    rvDefs::CSR_MSTATUSH: mstatush <= writeData;
                    rvDefs::CSR_MEDELEGH: medelegh <= writeData;
                    rvDefs::CSR_MSCRATCH: mscratch <= writeData;
                    rvDefs::CSR_MEPC: mepc <= writeData;
                    rvDefs::CSR_MCAUSE: mcause <= writeData;
                    rvDefs::CSR_MTVAL: mtval <= writeData;
                    rvDefs::CSR_MIP: mip <= writeData;
                    rvDefs::CSR_MCYCLE: mcyclef[31 : 0] <= writeData;
                    rvDefs::CSR_MINSTRET: minstretf[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER3: mhpmcounter3f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER4: mhpmcounter4f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER5: mhpmcounter5f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER6: mhpmcounter6f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER7: mhpmcounter7f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER8: mhpmcounter8f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER9: mhpmcounter9f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER10: mhpmcounter10f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER11: mhpmcounter11f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER12: mhpmcounter12f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER13: mhpmcounter13f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER14: mhpmcounter14f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER15: mhpmcounter15f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER16: mhpmcounter16f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER17: mhpmcounter17f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER18: mhpmcounter18f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER19: mhpmcounter19f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER20: mhpmcounter20f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER21: mhpmcounter21f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER22: mhpmcounter22f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER23: mhpmcounter23f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER24: mhpmcounter24f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER25: mhpmcounter25f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER26: mhpmcounter26f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER27: mhpmcounter27f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER28: mhpmcounter28f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER29: mhpmcounter29f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER30: mhpmcounter30f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER31: mhpmcounter31f[31 : 0] <= writeData;
                    rvDefs::CSR_MCYCLEH: mcyclef[63 : 32] <= writeData;
                    rvDefs::CSR_MINSTRETH: minstretf[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER3H: mhpmcounter3f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER4H: mhpmcounter4f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER5H: mhpmcounter5f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER6H: mhpmcounter6f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER7H: mhpmcounter7f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER8H: mhpmcounter8f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER9H: mhpmcounter9f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER10H: mhpmcounter10f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER11H: mhpmcounter11f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER12H: mhpmcounter12f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER13H: mhpmcounter13f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER14H: mhpmcounter14f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER15H: mhpmcounter15f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER16H: mhpmcounter16f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER17H: mhpmcounter17f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER18H: mhpmcounter18f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER19H: mhpmcounter19f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER20H: mhpmcounter20f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER21H: mhpmcounter21f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER22H: mhpmcounter22f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER23H: mhpmcounter23f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER24H: mhpmcounter24f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER25H: mhpmcounter25f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER26H: mhpmcounter26f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER27H: mhpmcounter27f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER28H: mhpmcounter28f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER29H: mhpmcounter29f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER30H: mhpmcounter30f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMCOUNTER31H: mhpmcounter31f[63 : 32] <= writeData;
                    rvDefs::CSR_MCOUNTINHIBIT: mcountinhibit <= writeData;
                    rvDefs::CSR_MHPMEVENT3: mhpmevent3f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT4: mhpmevent4f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT5: mhpmevent5f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT6: mhpmevent6f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT7: mhpmevent7f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT8: mhpmevent8f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT9: mhpmevent9f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT10: mhpmevent10f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT11: mhpmevent11f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT12: mhpmevent12f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT13: mhpmevent13f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT14: mhpmevent14f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT15: mhpmevent15f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT16: mhpmevent16f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT17: mhpmevent17f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT18: mhpmevent18f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT19: mhpmevent19f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT20: mhpmevent20f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT21: mhpmevent21f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT22: mhpmevent22f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT23: mhpmevent23f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT24: mhpmevent24f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT25: mhpmevent25f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT26: mhpmevent26f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT27: mhpmevent27f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT28: mhpmevent28f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT29: mhpmevent29f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT30: mhpmevent30f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT31: mhpmevent31f[63 : 32] <= writeData;
                    rvDefs::CSR_MHPMEVENT3H: mhpmevent3f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT4H: mhpmevent4f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT5H: mhpmevent5f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT6H: mhpmevent6f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT7H: mhpmevent7f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT8H: mhpmevent8f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT9H: mhpmevent9f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT10H: mhpmevent10f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT11H: mhpmevent11f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT12H: mhpmevent12f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT13H: mhpmevent13f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT14H: mhpmevent14f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT15H: mhpmevent15f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT16H: mhpmevent16f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT17H: mhpmevent17f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT18H: mhpmevent18f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT19H: mhpmevent19f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT20H: mhpmevent20f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT21H: mhpmevent21f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT22H: mhpmevent22f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT23H: mhpmevent23f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT24H: mhpmevent24f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT25H: mhpmevent25f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT26H: mhpmevent26f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT27H: mhpmevent27f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT28H: mhpmevent28f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT29H: mhpmevent29f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT30H: mhpmevent30f[31 : 0] <= writeData;
                    rvDefs::CSR_MHPMEVENT31H: mhpmevent31f[31 : 0] <= writeData;
                endcase
            end
        end
    end

    // CSR read logic
    always_comb begin
        case (addr)
            rvDefs::CSR_MVENDORID: readData = mvendorid;
            rvDefs::CSR_MARCHID: readData = marchid;
            rvDefs::CSR_MIMPID: readData = mimpid;
            rvDefs::CSR_MHARTID: readData = mhartid;
            rvDefs::CSR_MCONFIGPTR: readData = mconfigptr;
            rvDefs::CSR_MSTATUS: readData = mstatus;
            rvDefs::CSR_MISA: readData = misa;
            rvDefs::CSR_MEDELEG: readData = medeleg;
            rvDefs::CSR_MIDELEG: readData = mideleg;
            rvDefs::CSR_MIE: readData = mie;
            rvDefs::CSR_MTVEC: readData = mtvec;
            rvDefs::CSR_MSTATUSH: readData = mstatush;
            rvDefs::CSR_MEDELEGH: readData = medelegh;
            rvDefs::CSR_MSCRATCH: readData = mscratch;
            rvDefs::CSR_MEPC: readData = mepc;
            rvDefs::CSR_MCAUSE: readData = mcause;
            rvDefs::CSR_MTVAL: readData = mtval;
            rvDefs::CSR_MIP: readData = mip;
            rvDefs::CSR_MCYCLE: readData = mcycle;
            rvDefs::CSR_MINSTRET: readData = minstret;
            rvDefs::CSR_MHPMCOUNTER3: readData = mhpmcounter3;
            rvDefs::CSR_MHPMCOUNTER4: readData = mhpmcounter4;
            rvDefs::CSR_MHPMCOUNTER5: readData = mhpmcounter5;
            rvDefs::CSR_MHPMCOUNTER6: readData = mhpmcounter6;
            rvDefs::CSR_MHPMCOUNTER7: readData = mhpmcounter7;
            rvDefs::CSR_MHPMCOUNTER8: readData = mhpmcounter8;
            rvDefs::CSR_MHPMCOUNTER9: readData = mhpmcounter9;
            rvDefs::CSR_MHPMCOUNTER10: readData = mhpmcounter10;
            rvDefs::CSR_MHPMCOUNTER11: readData = mhpmcounter11;
            rvDefs::CSR_MHPMCOUNTER12: readData = mhpmcounter12;
            rvDefs::CSR_MHPMCOUNTER13: readData = mhpmcounter13;
            rvDefs::CSR_MHPMCOUNTER14: readData = mhpmcounter14;
            rvDefs::CSR_MHPMCOUNTER15: readData = mhpmcounter15;
            rvDefs::CSR_MHPMCOUNTER16: readData = mhpmcounter16;
            rvDefs::CSR_MHPMCOUNTER17: readData = mhpmcounter17;
            rvDefs::CSR_MHPMCOUNTER18: readData = mhpmcounter18;
            rvDefs::CSR_MHPMCOUNTER19: readData = mhpmcounter19;
            rvDefs::CSR_MHPMCOUNTER20: readData = mhpmcounter20;
            rvDefs::CSR_MHPMCOUNTER21: readData = mhpmcounter21;
            rvDefs::CSR_MHPMCOUNTER22: readData = mhpmcounter22;
            rvDefs::CSR_MHPMCOUNTER23: readData = mhpmcounter23;
            rvDefs::CSR_MHPMCOUNTER24: readData = mhpmcounter24;
            rvDefs::CSR_MHPMCOUNTER25: readData = mhpmcounter25;
            rvDefs::CSR_MHPMCOUNTER26: readData = mhpmcounter26;
            rvDefs::CSR_MHPMCOUNTER27: readData = mhpmcounter27;
            rvDefs::CSR_MHPMCOUNTER28: readData = mhpmcounter28;
            rvDefs::CSR_MHPMCOUNTER29: readData = mhpmcounter29;
            rvDefs::CSR_MHPMCOUNTER30: readData = mhpmcounter30;
            rvDefs::CSR_MHPMCOUNTER31: readData = mhpmcounter31;
            rvDefs::CSR_MCYCLEH: readData = mcycleh;
            rvDefs::CSR_MINSTRETH: readData = minstreth;
            rvDefs::CSR_MHPMCOUNTER3H: readData = mhpmcounter3h;
            rvDefs::CSR_MHPMCOUNTER4H: readData = mhpmcounter4h;
            rvDefs::CSR_MHPMCOUNTER5H: readData = mhpmcounter5h;
            rvDefs::CSR_MHPMCOUNTER6H: readData = mhpmcounter6h;
            rvDefs::CSR_MHPMCOUNTER7H: readData = mhpmcounter7h;
            rvDefs::CSR_MHPMCOUNTER8H: readData = mhpmcounter8h;
            rvDefs::CSR_MHPMCOUNTER9H: readData = mhpmcounter9h;
            rvDefs::CSR_MHPMCOUNTER10H: readData = mhpmcounter10h;
            rvDefs::CSR_MHPMCOUNTER11H: readData = mhpmcounter11h;
            rvDefs::CSR_MHPMCOUNTER12H: readData = mhpmcounter12h;
            rvDefs::CSR_MHPMCOUNTER13H: readData = mhpmcounter13h;
            rvDefs::CSR_MHPMCOUNTER14H: readData = mhpmcounter14h;
            rvDefs::CSR_MHPMCOUNTER15H: readData = mhpmcounter15h;
            rvDefs::CSR_MHPMCOUNTER16H: readData = mhpmcounter16h;
            rvDefs::CSR_MHPMCOUNTER17H: readData = mhpmcounter17h;
            rvDefs::CSR_MHPMCOUNTER18H: readData = mhpmcounter18h;
            rvDefs::CSR_MHPMCOUNTER19H: readData = mhpmcounter19h;
            rvDefs::CSR_MHPMCOUNTER20H: readData = mhpmcounter20h;
            rvDefs::CSR_MHPMCOUNTER21H: readData = mhpmcounter21h;
            rvDefs::CSR_MHPMCOUNTER22H: readData = mhpmcounter22h;
            rvDefs::CSR_MHPMCOUNTER23H: readData = mhpmcounter23h;
            rvDefs::CSR_MHPMCOUNTER24H: readData = mhpmcounter24h;
            rvDefs::CSR_MHPMCOUNTER25H: readData = mhpmcounter25h;
            rvDefs::CSR_MHPMCOUNTER26H: readData = mhpmcounter26h;
            rvDefs::CSR_MHPMCOUNTER27H: readData = mhpmcounter27h;
            rvDefs::CSR_MHPMCOUNTER28H: readData = mhpmcounter28h;
            rvDefs::CSR_MHPMCOUNTER29H: readData = mhpmcounter29h;
            rvDefs::CSR_MHPMCOUNTER30H: readData = mhpmcounter30h;
            rvDefs::CSR_MHPMCOUNTER31H: readData = mhpmcounter31h;
            rvDefs::CSR_MCOUNTINHIBIT: readData = mcountinhibit;
            rvDefs::CSR_MHPMEVENT3: readData = mhpmevent3;
            rvDefs::CSR_MHPMEVENT4: readData = mhpmevent4;
            rvDefs::CSR_MHPMEVENT5: readData = mhpmevent5;
            rvDefs::CSR_MHPMEVENT6: readData = mhpmevent6;
            rvDefs::CSR_MHPMEVENT7: readData = mhpmevent7;
            rvDefs::CSR_MHPMEVENT8: readData = mhpmevent8;
            rvDefs::CSR_MHPMEVENT9: readData = mhpmevent9;
            rvDefs::CSR_MHPMEVENT10: readData = mhpmevent10;
            rvDefs::CSR_MHPMEVENT11: readData = mhpmevent11;
            rvDefs::CSR_MHPMEVENT12: readData = mhpmevent12;
            rvDefs::CSR_MHPMEVENT13: readData = mhpmevent13;
            rvDefs::CSR_MHPMEVENT14: readData = mhpmevent14;
            rvDefs::CSR_MHPMEVENT15: readData = mhpmevent15;
            rvDefs::CSR_MHPMEVENT16: readData = mhpmevent16;
            rvDefs::CSR_MHPMEVENT17: readData = mhpmevent17;
            rvDefs::CSR_MHPMEVENT18: readData = mhpmevent18;
            rvDefs::CSR_MHPMEVENT19: readData = mhpmevent19;
            rvDefs::CSR_MHPMEVENT20: readData = mhpmevent20;
            rvDefs::CSR_MHPMEVENT21: readData = mhpmevent21;
            rvDefs::CSR_MHPMEVENT22: readData = mhpmevent22;
            rvDefs::CSR_MHPMEVENT23: readData = mhpmevent23;
            rvDefs::CSR_MHPMEVENT24: readData = mhpmevent24;
            rvDefs::CSR_MHPMEVENT25: readData = mhpmevent25;
            rvDefs::CSR_MHPMEVENT26: readData = mhpmevent26;
            rvDefs::CSR_MHPMEVENT27: readData = mhpmevent27;
            rvDefs::CSR_MHPMEVENT28: readData = mhpmevent28;
            rvDefs::CSR_MHPMEVENT29: readData = mhpmevent29;
            rvDefs::CSR_MHPMEVENT30: readData = mhpmevent30;
            rvDefs::CSR_MHPMEVENT31: readData = mhpmevent31;
            rvDefs::CSR_MHPMEVENT3H: readData = mhpmevent3h;
            rvDefs::CSR_MHPMEVENT4H: readData = mhpmevent4h;
            rvDefs::CSR_MHPMEVENT5H: readData = mhpmevent5h;
            rvDefs::CSR_MHPMEVENT6H: readData = mhpmevent6h;
            rvDefs::CSR_MHPMEVENT7H: readData = mhpmevent7h;
            rvDefs::CSR_MHPMEVENT8H: readData = mhpmevent8h;
            rvDefs::CSR_MHPMEVENT9H: readData = mhpmevent9h;
            rvDefs::CSR_MHPMEVENT10H: readData = mhpmevent10h;
            rvDefs::CSR_MHPMEVENT11H: readData = mhpmevent11h;
            rvDefs::CSR_MHPMEVENT12H: readData = mhpmevent12h;
            rvDefs::CSR_MHPMEVENT13H: readData = mhpmevent13h;
            rvDefs::CSR_MHPMEVENT14H: readData = mhpmevent14h;
            rvDefs::CSR_MHPMEVENT15H: readData = mhpmevent15h;
            rvDefs::CSR_MHPMEVENT16H: readData = mhpmevent16h;
            rvDefs::CSR_MHPMEVENT17H: readData = mhpmevent17h;
            rvDefs::CSR_MHPMEVENT18H: readData = mhpmevent18h;
            rvDefs::CSR_MHPMEVENT19H: readData = mhpmevent19h;
            rvDefs::CSR_MHPMEVENT20H: readData = mhpmevent20h;
            rvDefs::CSR_MHPMEVENT21H: readData = mhpmevent21h;
            rvDefs::CSR_MHPMEVENT22H: readData = mhpmevent22h;
            rvDefs::CSR_MHPMEVENT23H: readData = mhpmevent23h;
            rvDefs::CSR_MHPMEVENT24H: readData = mhpmevent24h;
            rvDefs::CSR_MHPMEVENT25H: readData = mhpmevent25h;
            rvDefs::CSR_MHPMEVENT26H: readData = mhpmevent26h;
            rvDefs::CSR_MHPMEVENT27H: readData = mhpmevent27h;
            rvDefs::CSR_MHPMEVENT28H: readData = mhpmevent28h;
            rvDefs::CSR_MHPMEVENT29H: readData = mhpmevent29h;
            rvDefs::CSR_MHPMEVENT30H: readData = mhpmevent30h;
            rvDefs::CSR_MHPMEVENT31H: readData = mhpmevent31h;
            default: readData = rvDefs::word_t'(0);
        endcase
    end

endmodule
