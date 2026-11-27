
`timescale 1ns/1ps

module tb_riscv_core;

    reg clk;
    reg rst_n;

    wire [31:0] instr_addr;
    reg  [31:0] instr_rdata;

    wire [31:0] data_addr;
    wire [31:0] data_wdata;
    wire data_we;
    wire data_re;
    reg  [31:0] data_rdata;

    // Instruction memory
    always @(*) begin

        case (instr_addr)

            32'h00: instr_rdata = 32'h00500093;
            32'h04: instr_rdata = 32'h00700113;
            32'h08: instr_rdata = 32'h002081B3;
            32'h0C: instr_rdata = 32'h00302023;
            32'h10: instr_rdata = 32'h00002203;
            32'h14: instr_rdata = 32'h00418463;
            32'h18: instr_rdata = 32'h00100293;
            32'h1C: instr_rdata = 32'h00900293;
            32'h20: instr_rdata = 32'h0080036F;
            32'h24: instr_rdata = 32'h06300393;
            32'h28: instr_rdata = 32'h00300393;
            32'h2C: instr_rdata = 32'h0000006F;

            default: instr_rdata = 32'h00000013;

        endcase

    end

    // Data memory
    reg [31:0] dmem [0:15];

    always @(*) begin

        if (data_re)
            data_rdata = dmem[data_addr[5:2]];
        else
            data_rdata = 32'b0;

    end

    always @(posedge clk) begin

        if (data_we)
            dmem[data_addr[5:2]] <= data_wdata;

    end

    // DUT
    riscv_core dut (
        .clk(clk),
        .rst_n(rst_n),

        .instr_addr(instr_addr),
        .instr_rdata(instr_rdata),

        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_we(data_we),
        .data_re(data_re),
        .data_rdata(data_rdata)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    integer i;

    initial begin

        $dumpfile("waveform/riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);

        rst_n = 0;

        for (i = 0; i < 16; i = i + 1)
            dmem[i] = 0;

        repeat (2) @(posedge clk);

        #1 rst_n = 1;

        repeat (15) @(posedge clk);

        #1;

        $display("--------------------------------");
        $display(" RISC-V PROCESSOR TEST RESULTS");
        $display("--------------------------------");

        $display("x1 = %0d", dut.regs[1]);
        $display("x2 = %0d", dut.regs[2]);
        $display("x3 = %0d", dut.regs[3]);
        $display("x4 = %0d", dut.regs[4]);
        $display("x5 = %0d", dut.regs[5]);
        $display("x6 = %0d", dut.regs[6]);
        $display("x7 = %0d", dut.regs[7]);

        $display("Memory[0] = %0d", dmem[0]);

        if (
            dut.regs[1] == 5 &&
            dut.regs[2] == 7 &&
            dut.regs[3] == 12 &&
            dut.regs[4] == 12 &&
            dmem[0] == 12 &&
            dut.regs[5] == 9 &&
            dut.regs[6] == 36 &&
            dut.regs[7] == 3
        ) begin

            $display("PASS: ALL TESTS SUCCESSFUL");

        end
        else begin

            $display("FAIL: CHECK RTL DESIGN");

        end

        $display("--------------------------------");

        $finish;

    end

endmodule

