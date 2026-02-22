`timescale 1ns / 1ps

`include "TB_macro_collection.vh"

module TB;
    logic clk;
    logic RsRx;
    logic RsTx;
    logic Hsync;
    logic Vsync;
    logic [3:0] vgaRed;
    logic [3:0] vgaGreen;
    logic [3:0] vgaBlue;

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
