`timescale 1ns / 1ps

interface vga_io (
    input logic clk,
    input logic rst_n
);
    logic Hsync;
    logic Vsync;
    logic [3:0] vgaRed;
    logic [3:0] vgaGreen;
    logic [3:0] vgaBlue;

endinterface
