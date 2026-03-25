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

    // GPU Instance
    gpu u_gpu (
        .clk_osc (clk),
        .sw      (sw),
        .RsRx    (RsRx),
        .RsTx    (RsTx),
        .Hsync   (Hsync),
        .Vsync   (Vsync),
        .vgaRed  (vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue (vgaBlue),
        .LED     (LED),
        .seg     (seg),
        .an      (an),
        .dp      (dp)
    );

    // Instantiate tests
    tb_vga_controller u_tb_vga_controller ();
    tb_uart u_tb_uart ();

    // Start tests
    `start_clock

endmodule
