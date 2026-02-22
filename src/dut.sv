`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module dut (
    input logic CLK100MHZ,
    input logic RsRx,
    output logic RsTx,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync
);
    // Clocks & resets
    logic rst_n;
    logic locked;  // MMCM lock indicator
    logic clk_vga;

    // Interfaces
    uart_io uart_if (
        .clk(CLK100MHZ),
        .*
    );

    vga_io vga_if (
        .clk(clk_vga),
        .*
    );

    // Wire physical pins
    assign uart_if.rx = RsRx;
    assign RsTx = uart_if.tx;

    // Clock wizard (MMCM)
    clk_wiz_0 cw0 (
        .clk_in1 (CLK100MHz),
        .resetn  (rst_n),
        .clk_out1(clk_vga),
        .locked(locked)
    );

    uart u_uart0 (.*);

    vga_controller vga0 (
        .clk(CLK100MHZ),
        .*
    );
endmodule
