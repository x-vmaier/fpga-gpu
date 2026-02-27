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
    logic [$clog2(H_ACTIVE)-1:0] x_dest;
    logic [$clog2(V_ACTIVE)-1:0] y_dest;
    logic [11:0] frame_mem[0:320*240-1];

    initial $readmemh("image.hex", frame_mem);

    upscaler2x #(
        .H_OUT(H_ACTIVE),
        .V_OUT(V_ACTIVE)
    ) up2x0 (
        .frame_mem(frame_mem),
        .*
    );

    vga_controller #(
        .H_ACTIVE(H_ACTIVE),
        .V_ACTIVE(V_ACTIVE)
    ) vga0 (
        .*
    );
endmodule
