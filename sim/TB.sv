`timescale 1ns / 1ps

`include "TB_macro_collection.vh"

module TB;
    logic clk;
    logic [15:0] sw;
    logic RsRx;
    logic RsTx;
    logic Hsync;
    logic Vsync;
    logic [3:0] vgaRed;
    logic [3:0] vgaGreen;
    logic [3:0] vgaBlue;
    logic [15:0] LED;
    logic [6:0] seg;
    logic [3:0] an;
    logic dp;

    // DUT Instance
    dut dut0 (
        .clk_osc(clk),
        .*
    );

    // Instantiate tests
    tb_vga_controller inst_tb_vga_controller ();
    tb_uart inst_tb_uart ();

    // Start tests
    `start_clock

endmodule
