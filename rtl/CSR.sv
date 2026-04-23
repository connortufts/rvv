module CSR (
    input  logic              clk,
    input  logic              rstn,
    input  logic              writeEnable,
    input  rvDefs::mem_addr_t addr,
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
    rvDefs::doubleword_t mstatusf;
    rvDefs::word_t mstatus;
    assign mstatus = mstatusf[31 : 0];
    //0x301
    rvDefs::word_t misa;
    assign misa = 32'b01000000001000000000000100000000;
    //0x302
    rvDefs::doubleword_t medelegf;
    assign medelegf = 64'd0;
    rvDefs::word_t medeleg;
    assign medeleg = medelegf[31 : 0];
    //0x303
    rvDefs::word_t mideleg;
    assign mideleg = 32'd0;
    //0x304
    rvDefs::word_t mie;
    //0x305
    rvDefs::word_t mtvec;
    //0x310
    rvDefs::word_t mstatush;
    assign mstatush = mstatusf[63 : 32];
    //0x312
    rvDefs::word_t medelegh;
    assign medelegh = medelegf[63 : 32];

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

ecall generates env call from m mode exception

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
            mcounteren <= rvDefs::word_t'(0);
            mstatush <= rvDefs::word_t'(0);
            medelegh <= rvDefs::word_t'(0);
            mscratch <= rvDefs::word_t'(0);
            mepc <= rvDefs::word_t'(0);
            mcause <= rvDefs::word_t'(0);
            mtval <= rvDefs::word_t'(0);
            mip <= rvDefs::word_t'(0);
            mcycle <= rvDefs::word_t'(0);
            minstret <= rvDefs::word_t'(0);
            mhpmcounter3 <= rvDefs::word_t'(0);
            mhpmcounter4 <= rvDefs::word_t'(0);
            mhpmcounter5 <= rvDefs::word_t'(0);
            mhpmcounter6 <= rvDefs::word_t'(0);
            mhpmcounter7 <= rvDefs::word_t'(0);
            mhpmcounter8 <= rvDefs::word_t'(0);
            mhpmcounter9 <= rvDefs::word_t'(0);
            mhpmcounter10 <= rvDefs::word_t'(0);
            mhpmcounter11 <= rvDefs::word_t'(0);
            mhpmcounter12 <= rvDefs::word_t'(0);
            mhpmcounter13 <= rvDefs::word_t'(0);
            mhpmcounter14 <= rvDefs::word_t'(0);
            mhpmcounter15 <= rvDefs::word_t'(0);
            mhpmcounter16 <= rvDefs::word_t'(0);
            mhpmcounter17 <= rvDefs::word_t'(0);
            mhpmcounter18 <= rvDefs::word_t'(0);
            mhpmcounter19 <= rvDefs::word_t'(0);
            mhpmcounter20 <= rvDefs::word_t'(0);
            mhpmcounter21 <= rvDefs::word_t'(0);
            mhpmcounter22 <= rvDefs::word_t'(0);
            mhpmcounter23 <= rvDefs::word_t'(0);
            mhpmcounter24 <= rvDefs::word_t'(0);
            mhpmcounter25 <= rvDefs::word_t'(0);
            mhpmcounter26 <= rvDefs::word_t'(0);
            mhpmcounter27 <= rvDefs::word_t'(0);
            mhpmcounter28 <= rvDefs::word_t'(0);
            mhpmcounter29 <= rvDefs::word_t'(0);
            mhpmcounter30 <= rvDefs::word_t'(0);
            mhpmcounter31 <= rvDefs::word_t'(0);
            mcycleh <= rvDefs::word_t'(0);
            minstreth <= rvDefs::word_t'(0);
            mhpmcounter3h <= rvDefs::word_t'(0);
            mhpmcounter4h <= rvDefs::word_t'(0);
            mhpmcounter5h <= rvDefs::word_t'(0);
            mhpmcounter6h <= rvDefs::word_t'(0);
            mhpmcounter7h <= rvDefs::word_t'(0);
            mhpmcounter8h <= rvDefs::word_t'(0);
            mhpmcounter9h <= rvDefs::word_t'(0);
            mhpmcounter10h <= rvDefs::word_t'(0);
            mhpmcounter11h <= rvDefs::word_t'(0);
            mhpmcounter12h <= rvDefs::word_t'(0);
            mhpmcounter13h <= rvDefs::word_t'(0);
            mhpmcounter14h <= rvDefs::word_t'(0);
            mhpmcounter15h <= rvDefs::word_t'(0);
            mhpmcounter16h <= rvDefs::word_t'(0);
            mhpmcounter17h <= rvDefs::word_t'(0);
            mhpmcounter18h <= rvDefs::word_t'(0);
            mhpmcounter19h <= rvDefs::word_t'(0);
            mhpmcounter20h <= rvDefs::word_t'(0);
            mhpmcounter21h <= rvDefs::word_t'(0);
            mhpmcounter22h <= rvDefs::word_t'(0);
            mhpmcounter23h <= rvDefs::word_t'(0);
            mhpmcounter24h <= rvDefs::word_t'(0);
            mhpmcounter25h <= rvDefs::word_t'(0);
            mhpmcounter26h <= rvDefs::word_t'(0);
            mhpmcounter27h <= rvDefs::word_t'(0);
            mhpmcounter28h <= rvDefs::word_t'(0);
            mhpmcounter29h <= rvDefs::word_t'(0);
            mhpmcounter30h <= rvDefs::word_t'(0);
            mhpmcounter31h <= rvDefs::word_t'(0);
            mcountinhibit <= rvDefs::word_t'(0);
            mhpmevent3 <= rvDefs::word_t'(0);
            mhpmevent4 <= rvDefs::word_t'(0);
            mhpmevent5 <= rvDefs::word_t'(0);
            mhpmevent6 <= rvDefs::word_t'(0);
            mhpmevent7 <= rvDefs::word_t'(0);
            mhpmevent8 <= rvDefs::word_t'(0);
            mhpmevent9 <= rvDefs::word_t'(0);
            mhpmevent10 <= rvDefs::word_t'(0);
            mhpmevent11 <= rvDefs::word_t'(0);
            mhpmevent12 <= rvDefs::word_t'(0);
            mhpmevent13 <= rvDefs::word_t'(0);
            mhpmevent14 <= rvDefs::word_t'(0);
            mhpmevent15 <= rvDefs::word_t'(0);
            mhpmevent16 <= rvDefs::word_t'(0);
            mhpmevent17 <= rvDefs::word_t'(0);
            mhpmevent18 <= rvDefs::word_t'(0);
            mhpmevent19 <= rvDefs::word_t'(0);
            mhpmevent20 <= rvDefs::word_t'(0);
            mhpmevent21 <= rvDefs::word_t'(0);
            mhpmevent22 <= rvDefs::word_t'(0);
            mhpmevent23 <= rvDefs::word_t'(0);
            mhpmevent24 <= rvDefs::word_t'(0);
            mhpmevent25 <= rvDefs::word_t'(0);
            mhpmevent26 <= rvDefs::word_t'(0);
            mhpmevent27 <= rvDefs::word_t'(0);
            mhpmevent28 <= rvDefs::word_t'(0);
            mhpmevent29 <= rvDefs::word_t'(0);
            mhpmevent30 <= rvDefs::word_t'(0);
            mhpmevent31 <= rvDefs::word_t'(0);
            mhpmevent3h <= rvDefs::word_t'(0);
            mhpmevent4h <= rvDefs::word_t'(0);
            mhpmevent5h <= rvDefs::word_t'(0);
            mhpmevent6h <= rvDefs::word_t'(0);
            mhpmevent7h <= rvDefs::word_t'(0);
            mhpmevent8h <= rvDefs::word_t'(0);
            mhpmevent9h <= rvDefs::word_t'(0);
            mhpmevent10h <= rvDefs::word_t'(0);
            mhpmevent11h <= rvDefs::word_t'(0);
            mhpmevent12h <= rvDefs::word_t'(0);
            mhpmevent13h <= rvDefs::word_t'(0);
            mhpmevent14h <= rvDefs::word_t'(0);
            mhpmevent15h <= rvDefs::word_t'(0);
            mhpmevent16h <= rvDefs::word_t'(0);
            mhpmevent17h <= rvDefs::word_t'(0);
            mhpmevent18h <= rvDefs::word_t'(0);
            mhpmevent19h <= rvDefs::word_t'(0);
            mhpmevent20h <= rvDefs::word_t'(0);
            mhpmevent21h <= rvDefs::word_t'(0);
            mhpmevent22h <= rvDefs::word_t'(0);
            mhpmevent23h <= rvDefs::word_t'(0);
            mhpmevent24h <= rvDefs::word_t'(0);
            mhpmevent25h <= rvDefs::word_t'(0);
            mhpmevent26h <= rvDefs::word_t'(0);
            mhpmevent27h <= rvDefs::word_t'(0);
            mhpmevent28h <= rvDefs::word_t'(0);
            mhpmevent29h <= rvDefs::word_t'(0);
            mhpmevent30h <= rvDefs::word_t'(0);
            mhpmevent31h <= rvDefs::word_t'(0);
        end
        else begin

            // Software CSR writes (from SYSTEM instruction path)
            if (writeEnable) begin
                case (addr)
                    mvendorid <= writeData;
                    marchid <= writeData;
                    mimpid <= writeData;
                    mhartid <= writeData;
                    mconfigptr <= writeData;
                    mstatus <= writeData;
                    misa <= writeData;
                    medeleg <= writeData;
                    mideleg <= writeData;
                    mie <= writeData;
                    mtvec <= writeData;
                    mcounteren <= writeData;
                    mstatush <= writeData;
                    medelegh <= writeData;
                    mscratch <= writeData;
                    mepc <= writeData;
                    mcause <= writeData;
                    mtval <= writeData;
                    mip <= writeData;
                    mcycle <= writeData;
                    minstret <= writeData;
                    mhpmcounter3 <= writeData;
                    mhpmcounter4 <= writeData;
                    mhpmcounter5 <= writeData;
                    mhpmcounter6 <= writeData;
                    mhpmcounter7 <= writeData;
                    mhpmcounter8 <= writeData;
                    mhpmcounter9 <= writeData;
                    mhpmcounter10 <= writeData;
                    mhpmcounter11 <= writeData;
                    mhpmcounter12 <= writeData;
                    mhpmcounter13 <= writeData;
                    mhpmcounter14 <= writeData;
                    mhpmcounter15 <= writeData;
                    mhpmcounter16 <= writeData;
                    mhpmcounter17 <= writeData;
                    mhpmcounter18 <= writeData;
                    mhpmcounter19 <= writeData;
                    mhpmcounter20 <= writeData;
                    mhpmcounter21 <= writeData;
                    mhpmcounter22 <= writeData;
                    mhpmcounter23 <= writeData;
                    mhpmcounter24 <= writeData;
                    mhpmcounter25 <= writeData;
                    mhpmcounter26 <= writeData;
                    mhpmcounter27 <= writeData;
                    mhpmcounter28 <= writeData;
                    mhpmcounter29 <= writeData;
                    mhpmcounter30 <= writeData;
                    mhpmcounter31 <= writeData;
                    mcycleh <= writeData;
                    minstreth <= writeData;
                    mhpmcounter3h <= writeData;
                    mhpmcounter4h <= writeData;
                    mhpmcounter5h <= writeData;
                    mhpmcounter6h <= writeData;
                    mhpmcounter7h <= writeData;
                    mhpmcounter8h <= writeData;
                    mhpmcounter9h <= writeData;
                    mhpmcounter10h <= writeData;
                    mhpmcounter11h <= writeData;
                    mhpmcounter12h <= writeData;
                    mhpmcounter13h <= writeData;
                    mhpmcounter14h <= writeData;
                    mhpmcounter15h <= writeData;
                    mhpmcounter16h <= writeData;
                    mhpmcounter17h <= writeData;
                    mhpmcounter18h <= writeData;
                    mhpmcounter19h <= writeData;
                    mhpmcounter20h <= writeData;
                    mhpmcounter21h <= writeData;
                    mhpmcounter22h <= writeData;
                    mhpmcounter23h <= writeData;
                    mhpmcounter24h <= writeData;
                    mhpmcounter25h <= writeData;
                    mhpmcounter26h <= writeData;
                    mhpmcounter27h <= writeData;
                    mhpmcounter28h <= writeData;
                    mhpmcounter29h <= writeData;
                    mhpmcounter30h <= writeData;
                    mhpmcounter31h <= writeData;
                    mcountinhibit <= writeData;
                    mhpmevent3 <= writeData;
                    mhpmevent4 <= writeData;
                    mhpmevent5 <= writeData;
                    mhpmevent6 <= writeData;
                    mhpmevent7 <= writeData;
                    mhpmevent8 <= writeData;
                    mhpmevent9 <= writeData;
                    mhpmevent10 <= writeData;
                    mhpmevent11 <= writeData;
                    mhpmevent12 <= writeData;
                    mhpmevent13 <= writeData;
                    mhpmevent14 <= writeData;
                    mhpmevent15 <= writeData;
                    mhpmevent16 <= writeData;
                    mhpmevent17 <= writeData;
                    mhpmevent18 <= writeData;
                    mhpmevent19 <= writeData;
                    mhpmevent20 <= writeData;
                    mhpmevent21 <= writeData;
                    mhpmevent22 <= writeData;
                    mhpmevent23 <= writeData;
                    mhpmevent24 <= writeData;
                    mhpmevent25 <= writeData;
                    mhpmevent26 <= writeData;
                    mhpmevent27 <= writeData;
                    mhpmevent28 <= writeData;
                    mhpmevent29 <= writeData;
                    mhpmevent30 <= writeData;
                    mhpmevent31 <= writeData;
                    mhpmevent3h <= writeData;
                    mhpmevent4h <= writeData;
                    mhpmevent5h <= writeData;
                    mhpmevent6h <= writeData;
                    mhpmevent7h <= writeData;
                    mhpmevent8h <= writeData;
                    mhpmevent9h <= writeData;
                    mhpmevent10h <= writeData;
                    mhpmevent11h <= writeData;
                    mhpmevent12h <= writeData;
                    mhpmevent13h <= writeData;
                    mhpmevent14h <= writeData;
                    mhpmevent15h <= writeData;
                    mhpmevent16h <= writeData;
                    mhpmevent17h <= writeData;
                    mhpmevent18h <= writeData;
                    mhpmevent19h <= writeData;
                    mhpmevent20h <= writeData;
                    mhpmevent21h <= writeData;
                    mhpmevent22h <= writeData;
                    mhpmevent23h <= writeData;
                    mhpmevent24h <= writeData;
                    mhpmevent25h <= writeData;
                    mhpmevent26h <= writeData;
                    mhpmevent27h <= writeData;
                    mhpmevent28h <= writeData;
                    mhpmevent29h <= writeData;
                    mhpmevent30h <= writeData;
                    mhpmevent31h <= writeData;
                endcase
            end
        end
    end

    // CSR read logic
    always_comb begin
        case (addr)
            CSR_MVENDORID: readData = mvendorid;
            CSR_MARCHID: readData = marchid;
            CSR_MIMPID: readData = mimpid;
            CSR_MHARTID: readData = mhartid;
            CSR_MCONFIGPTR: readData = mconfigptr;
            CSR_MSTATUS: readData = mstatus;
            CSR_MISA: readData = misa;
            CSR_MEDELEG: readData = medeleg;
            CSR_MIDELEG: readData = mideleg;
            CSR_MIE: readData = mie;
            CSR_MTVEC: readData = mtvec;
            CSR_MCOUNTEREN: readData = mcounteren;
            CSR_MSTATUSH: readData = mstatush;
            CSR_MEDELEGH: readData = medelegh;
            CSR_MSCRATCH: readData = mscratch;
            CSR_MEPC: readData = mepc;
            CSR_MCAUSE: readData = mcause;
            CSR_MTVAL: readData = mtval;
            CSR_MIP: readData = mip;
            CSR_MCYCLE: readData = mcycle;
            CSR_MINSTRET: readData = minstret;
            CSR_MHPMCOUNTER3: readData = mhpmcounter3;
            CSR_MHPMCOUNTER4: readData = mhpmcounter4;
            CSR_MHPMCOUNTER5: readData = mhpmcounter5;
            CSR_MHPMCOUNTER6: readData = mhpmcounter6;
            CSR_MHPMCOUNTER7: readData = mhpmcounter7;
            CSR_MHPMCOUNTER8: readData = mhpmcounter8;
            CSR_MHPMCOUNTER9: readData = mhpmcounter9;
            CSR_MHPMCOUNTER10: readData = mhpmcounter10;
            CSR_MHPMCOUNTER11: readData = mhpmcounter11;
            CSR_MHPMCOUNTER12: readData = mhpmcounter12;
            CSR_MHPMCOUNTER13: readData = mhpmcounter13;
            CSR_MHPMCOUNTER14: readData = mhpmcounter14;
            CSR_MHPMCOUNTER15: readData = mhpmcounter15;
            CSR_MHPMCOUNTER16: readData = mhpmcounter16;
            CSR_MHPMCOUNTER17: readData = mhpmcounter17;
            CSR_MHPMCOUNTER18: readData = mhpmcounter18;
            CSR_MHPMCOUNTER19: readData = mhpmcounter19;
            CSR_MHPMCOUNTER20: readData = mhpmcounter20;
            CSR_MHPMCOUNTER21: readData = mhpmcounter21;
            CSR_MHPMCOUNTER22: readData = mhpmcounter22;
            CSR_MHPMCOUNTER23: readData = mhpmcounter23;
            CSR_MHPMCOUNTER24: readData = mhpmcounter24;
            CSR_MHPMCOUNTER25: readData = mhpmcounter25;
            CSR_MHPMCOUNTER26: readData = mhpmcounter26;
            CSR_MHPMCOUNTER27: readData = mhpmcounter27;
            CSR_MHPMCOUNTER28: readData = mhpmcounter28;
            CSR_MHPMCOUNTER29: readData = mhpmcounter29;
            CSR_MHPMCOUNTER30: readData = mhpmcounter30;
            CSR_MHPMCOUNTER31: readData = mhpmcounter31;
            CSR_MCYCLEH: readData = mcycleh;
            CSR_MINSTRETH: readData = minstreth;
            CSR_MHPMCOUNTER3H: readData = mhpmcounter3h;
            CSR_MHPMCOUNTER4H: readData = mhpmcounter4h;
            CSR_MHPMCOUNTER5H: readData = mhpmcounter5h;
            CSR_MHPMCOUNTER6H: readData = mhpmcounter6h;
            CSR_MHPMCOUNTER7H: readData = mhpmcounter7h;
            CSR_MHPMCOUNTER8H: readData = mhpmcounter8h;
            CSR_MHPMCOUNTER9H: readData = mhpmcounter9h;
            CSR_MHPMCOUNTER10H: readData = mhpmcounter10h;
            CSR_MHPMCOUNTER11H: readData = mhpmcounter11h;
            CSR_MHPMCOUNTER12H: readData = mhpmcounter12h;
            CSR_MHPMCOUNTER13H: readData = mhpmcounter13h;
            CSR_MHPMCOUNTER14H: readData = mhpmcounter14h;
            CSR_MHPMCOUNTER15H: readData = mhpmcounter15h;
            CSR_MHPMCOUNTER16H: readData = mhpmcounter16h;
            CSR_MHPMCOUNTER17H: readData = mhpmcounter17h;
            CSR_MHPMCOUNTER18H: readData = mhpmcounter18h;
            CSR_MHPMCOUNTER19H: readData = mhpmcounter19h;
            CSR_MHPMCOUNTER20H: readData = mhpmcounter20h;
            CSR_MHPMCOUNTER21H: readData = mhpmcounter21h;
            CSR_MHPMCOUNTER22H: readData = mhpmcounter22h;
            CSR_MHPMCOUNTER23H: readData = mhpmcounter23h;
            CSR_MHPMCOUNTER24H: readData = mhpmcounter24h;
            CSR_MHPMCOUNTER25H: readData = mhpmcounter25h;
            CSR_MHPMCOUNTER26H: readData = mhpmcounter26h;
            CSR_MHPMCOUNTER27H: readData = mhpmcounter27h;
            CSR_MHPMCOUNTER28H: readData = mhpmcounter28h;
            CSR_MHPMCOUNTER29H: readData = mhpmcounter29h;
            CSR_MHPMCOUNTER30H: readData = mhpmcounter30h;
            CSR_MHPMCOUNTER31H: readData = mhpmcounter31h;
            CSR_MCOUNTINHIBIT: readData = mcountinhibit;
            CSR_MHPMEVENT3: readData = mhpmevent3;
            CSR_MHPMEVENT4: readData = mhpmevent4;
            CSR_MHPMEVENT5: readData = mhpmevent5;
            CSR_MHPMEVENT6: readData = mhpmevent6;
            CSR_MHPMEVENT7: readData = mhpmevent7;
            CSR_MHPMEVENT8: readData = mhpmevent8;
            CSR_MHPMEVENT9: readData = mhpmevent9;
            CSR_MHPMEVENT10: readData = mhpmevent10;
            CSR_MHPMEVENT11: readData = mhpmevent11;
            CSR_MHPMEVENT12: readData = mhpmevent12;
            CSR_MHPMEVENT13: readData = mhpmevent13;
            CSR_MHPMEVENT14: readData = mhpmevent14;
            CSR_MHPMEVENT15: readData = mhpmevent15;
            CSR_MHPMEVENT16: readData = mhpmevent16;
            CSR_MHPMEVENT17: readData = mhpmevent17;
            CSR_MHPMEVENT18: readData = mhpmevent18;
            CSR_MHPMEVENT19: readData = mhpmevent19;
            CSR_MHPMEVENT20: readData = mhpmevent20;
            CSR_MHPMEVENT21: readData = mhpmevent21;
            CSR_MHPMEVENT22: readData = mhpmevent22;
            CSR_MHPMEVENT23: readData = mhpmevent23;
            CSR_MHPMEVENT24: readData = mhpmevent24;
            CSR_MHPMEVENT25: readData = mhpmevent25;
            CSR_MHPMEVENT26: readData = mhpmevent26;
            CSR_MHPMEVENT27: readData = mhpmevent27;
            CSR_MHPMEVENT28: readData = mhpmevent28;
            CSR_MHPMEVENT29: readData = mhpmevent29;
            CSR_MHPMEVENT30: readData = mhpmevent30;
            CSR_MHPMEVENT31: readData = mhpmevent31;
            CSR_MHPMEVENT3H: readData = mhpmevent3h;
            CSR_MHPMEVENT4H: readData = mhpmevent4h;
            CSR_MHPMEVENT5H: readData = mhpmevent5h;
            CSR_MHPMEVENT6H: readData = mhpmevent6h;
            CSR_MHPMEVENT7H: readData = mhpmevent7h;
            CSR_MHPMEVENT8H: readData = mhpmevent8h;
            CSR_MHPMEVENT9H: readData = mhpmevent9h;
            CSR_MHPMEVENT10H: readData = mhpmevent10h;
            CSR_MHPMEVENT11H: readData = mhpmevent11h;
            CSR_MHPMEVENT12H: readData = mhpmevent12h;
            CSR_MHPMEVENT13H: readData = mhpmevent13h;
            CSR_MHPMEVENT14H: readData = mhpmevent14h;
            CSR_MHPMEVENT15H: readData = mhpmevent15h;
            CSR_MHPMEVENT16H: readData = mhpmevent16h;
            CSR_MHPMEVENT17H: readData = mhpmevent17h;
            CSR_MHPMEVENT18H: readData = mhpmevent18h;
            CSR_MHPMEVENT19H: readData = mhpmevent19h;
            CSR_MHPMEVENT20H: readData = mhpmevent20h;
            CSR_MHPMEVENT21H: readData = mhpmevent21h;
            CSR_MHPMEVENT22H: readData = mhpmevent22h;
            CSR_MHPMEVENT23H: readData = mhpmevent23h;
            CSR_MHPMEVENT24H: readData = mhpmevent24h;
            CSR_MHPMEVENT25H: readData = mhpmevent25h;
            CSR_MHPMEVENT26H: readData = mhpmevent26h;
            CSR_MHPMEVENT27H: readData = mhpmevent27h;
            CSR_MHPMEVENT28H: readData = mhpmevent28h;
            CSR_MHPMEVENT29H: readData = mhpmevent29h;
            CSR_MHPMEVENT30H: readData = mhpmevent30h;
            CSR_MHPMEVENT31H: readData = mhpmevent31h;
            default: readData = rvDefs::word_t'(0);
        endcase
    end

endmodule
