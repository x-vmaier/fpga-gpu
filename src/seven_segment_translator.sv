`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module seven_segment_translator #(
    parameter integer REFRESH_BITS = 17
) (
    input logic clk,
    input logic rst_n,
    input logic [15:0] segment_data_in,
    input logic [3:0] segment_point_in,
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic dp
);
    // Refresh counter
    logic [REFRESH_BITS-1:0] refresh_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            refresh_cnt <= '0;
        end else begin
            refresh_cnt <= refresh_cnt + 1'b1;
        end
    end

    // Top two bits select the active digit
    logic [1:0] digit_index;
    assign digit_index = refresh_cnt[REFRESH_BITS-1-:2];

    // Digit and decimal-point selection
    logic [3:0] current_digit;
    logic current_dp;

    assign current_digit = segment_data_in[digit_index*4+:4];
    assign current_dp = segment_point_in[digit_index];

    // Active-low anode and decimal-point outputs
    assign an = ~(4'b0001 << digit_index);
    assign dp = ~current_dp;

    // 7-Segment decoder
    logic [6:0] seg_active_high;

    always_comb begin
        unique case (current_digit)
            4'h0: seg_active_high = 7'b0111111;
            4'h1: seg_active_high = 7'b0000110;
            4'h2: seg_active_high = 7'b1011011;
            4'h3: seg_active_high = 7'b1001111;
            4'h4: seg_active_high = 7'b1100110;
            4'h5: seg_active_high = 7'b1101101;
            4'h6: seg_active_high = 7'b1111101;
            4'h7: seg_active_high = 7'b0000111;
            4'h8: seg_active_high = 7'b1111111;
            4'h9: seg_active_high = 7'b1101111;
            4'hA: seg_active_high = 7'b1110111;
            4'hB: seg_active_high = 7'b1111100;
            4'hC: seg_active_high = 7'b0111001;
            4'hD: seg_active_high = 7'b1011110;
            4'hE: seg_active_high = 7'b1111001;
            4'hF: seg_active_high = 7'b1110001;
            default: seg_active_high = 7'b0000000;
        endcase
    end

    assign seg = ~seg_active_high;  // Active-low for Basys3
endmodule
