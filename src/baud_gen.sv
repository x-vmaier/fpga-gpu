`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module baud_gen #(
    parameter int CLK_FREQ  = 100_000_000,
    parameter int BAUD_RATE = 921_600,
    parameter int FRAC_BITS = 16
) (
    input  logic clk,
    input  logic rst_n,
    output logic baud_tick,
    output logic baud16_tick
);

    // Step = round( BAUD_RATE * 16 * 2^FRAC_BITS / CLK_FREQ )
    localparam longint STEP = (longint'(BAUD_RATE) * 16 * (longint'(1) << FRAC_BITS) + CLK_FREQ / 2) / CLK_FREQ;

    logic [FRAC_BITS-1:0] acc;
    logic [FRAC_BITS : 0] acc_next;  // one extra bit catches the carry

    assign acc_next    = {1'b0, acc} + FRAC_BITS'(STEP[FRAC_BITS-1:0]);
    assign baud16_tick = acc_next[FRAC_BITS];  // carry bit

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) acc <= '0;
        else acc <= acc_next[FRAC_BITS-1:0];
    end

    // 1x baud tick
    logic [3:0] baud_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt  <= '0;
            baud_tick <= '0;
        end else begin
            baud_tick <= baud16_tick && (baud_cnt == 4'd14);
            if (baud16_tick) baud_cnt <= baud_cnt + 1;
        end
    end
endmodule
