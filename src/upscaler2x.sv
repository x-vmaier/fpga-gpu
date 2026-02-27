`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module upscaler2x #(
    parameter int H_OUT = 640,
    parameter int V_OUT = 480
) (
    input logic clk,
    input logic rst_n,
    input logic [$clog2(H_OUT)-1:0] x_dest,
    input logic [$clog2(V_OUT)-1:0] y_dest,
    input logic [11:0] frame_mem[0:(H_OUT/2)*(V_OUT/2)-1],
    output logic [11:0] pixel_data
);
    localparam int H_SRC = H_OUT / 2;
    localparam int V_SRC = V_OUT / 2;

    logic [$clog2(H_SRC)-1:0] h_src;
    logic [$clog2(V_SRC)-1:0] v_src;

    // Assign the same source pixel for 2x2 dest pixels
    assign h_src = x_dest >> 1;
    assign v_src = y_dest >> 1;

    // Pipeline BRAM read
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) pixel_data <= '0;
        else pixel_data <= frame_mem[v_src*H_SRC+h_src];
    end
endmodule
