`timescale 1ns / 1ps

module display_engine (
    input logic clk,
    input logic rst_n,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync
);
    vga_controller vga0 (.*);
endmodule
