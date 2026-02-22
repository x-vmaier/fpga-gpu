`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module upscaler2x (
    input  logic clk,
    input  logic rst_n,
    output logic x
);
    // Input Pixel Stream -> Line Buffer -> Address Calculator -> Pixel Selector -> Output Pixel Stream

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0;
        end
    end
endmodule
