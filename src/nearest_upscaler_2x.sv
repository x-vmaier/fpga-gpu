`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module nearest_upscaler_2x #(
    parameter int H_OUT = 640,
    parameter int V_OUT = 480
) (
    input logic clk,
    input logic rst_n,
    input logic [$clog2(H_OUT)-1:0] x_dest,
    input logic [$clog2(V_OUT)-1:0] y_dest,
    output logic [$clog2((H_OUT/2)*(V_OUT/2))-1:0] addr
);
    localparam int H_SRC = H_OUT / 2;
    localparam int V_SRC = V_OUT / 2;

    logic [$clog2(H_SRC)-1:0] h_src;
    logic [$clog2(V_SRC)-1:0] v_src;

    // Same source pixel for adjacent pixels
    assign h_src = x_dest >> 1;
    assign v_src = y_dest >> 1;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            addr <= '0;
        end else begin
            addr <= v_src * H_SRC + h_src;
        end
    end
endmodule
