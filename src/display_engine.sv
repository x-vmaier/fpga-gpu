`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module display_engine #(
    parameter int H_ACTIVE = 640,
    parameter int V_ACTIVE = 480
) (
    input logic clk,
    input logic rst_n,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic Hsync,
    output logic Vsync
);
    logic [11:0] pixel_data;
    logic [$clog2((H_ACTIVE/2)*(V_ACTIVE/2))-1:0] addr;
    logic [$clog2(H_ACTIVE)-1:0] x_dest;
    logic [$clog2(V_ACTIVE)-1:0] y_dest;

    blk_mem_gen_0 framebuffer_rom_0 (
        .clka (clk),
        .addra(addr),
        .douta(pixel_data)
    );

    nearest_upscaler_2x #(
        .H_OUT(H_ACTIVE),
        .V_OUT(V_ACTIVE)
    ) u_nearest_2x (
        .clk   (clk),
        .rst_n (rst_n),
        .x_dest(x_dest),
        .y_dest(y_dest),
        .addr  (addr)
    );

    vga_controller #(
        .H_ACTIVE(H_ACTIVE),
        .V_ACTIVE(V_ACTIVE)
    ) u_vga_controller (
        .clk       (clk),
        .rst_n     (rst_n),
        .pixel_data(pixel_data),
        .x_dest    (x_dest),
        .y_dest    (y_dest),
        .vgaRed    (vgaRed),
        .vgaGreen  (vgaGreen),
        .vgaBlue   (vgaBlue),
        .Hsync     (Hsync),
        .Vsync     (Vsync)
    );
endmodule
