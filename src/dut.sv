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

    logic rst_n;
    logic locked;  // MMCM
    logic clk_vga;
    logic [3:0] cg_clk;

    // Interfaces
    uart_io uart_if (
        .clk(CLK100MHZ),
        .*
    );
    vga_io vga_if (
        .clk(clk_vga),
        .*
    );

    assign uart_if.rx = RsRx;
    assign RsTx = uart_if.tx;

    // Modules
    clk_wiz_0 cw0 (
        .resetn(rst_n),
        .*
    );
    uart u_uart0 (.*);

    clockgate cg0 (
        .clk(clk_vga),
        .*
    );
    vga_controller vga0 (
        .clk(CLK100MHZ),
        .*
    );

endmodule
