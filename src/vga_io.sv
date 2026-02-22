`timescale 1ns / 1ps

interface vga_io #(
    parameter int R_BITS = 4,
    parameter int G_BITS = 4,
    parameter int B_BITS = 4
);
    logic Hsync;
    logic Vsync;
    logic [R_BITS-1:0] vgaRed;
    logic [G_BITS-1:0] vgaGreen;
    logic [B_BITS-1:0] vgaBlue;
endinterface
