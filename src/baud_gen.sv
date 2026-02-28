`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module baud_gen #(
    parameter int CLK_FREQ  = 100_000_000,
    parameter int BAUD_RATE = 921_600,
    parameter int BAUD_OSR  = 8,
    parameter int FRAC_BITS = 16
) (
    input  logic clk,
    input  logic rst_n,
    output logic baud_tick,
    output logic baud_osr_tick
);
    // Step for oversampled baud generation
    // round( BAUD_RATE * BAUD_OSR * 2^FRAC_BITS / CLK_FREQ )
    localparam longint STEP = (longint'(BAUD_RATE) * BAUD_OSR * (longint'(1) << FRAC_BITS) + CLK_FREQ / 2) / CLK_FREQ;

    logic [FRAC_BITS-1:0] acc;
    logic [  FRAC_BITS:0] acc_next;  // One extra bit for carry

    assign acc_next = {1'b0, acc} + FRAC_BITS'(STEP[FRAC_BITS-1:0]);
    assign baud_osr_tick = acc_next[FRAC_BITS];  // Carry bit

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= '0;
        end else begin
            acc <= acc_next[FRAC_BITS-1:0];
        end
    end

    // Baud tick
    logic [$clog2(BAUD_OSR)-1:0] baud_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt  <= '0;
            baud_tick <= '0;
        end else begin
            baud_tick <= '0;  // Default low
            if (baud_osr_tick) begin
                // Divide baud_osr by oversampling ratio to produce baud_tick
                baud_cnt  <= baud_cnt + 1'b1;
                baud_tick <= (baud_cnt == BAUD_OSR - 1);
            end
        end
    end
endmodule
