`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module uart_tx #(
    parameter int DATA_BITS = 8,
    parameter int STOP_BITS = 1
) (
    input logic clk,
    input logic rst_n,
    input logic baud_tick,
    input logic [DATA_BITS-1:0] data_in,
    input logic valid,
    output logic ready,
    output logic tx
);
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state;
    logic [$clog2(DATA_BITS):0] bit_cnt;
    logic [DATA_BITS-1:0] shift_reg;

    assign ready = (state == IDLE);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx        <= 1'b1;
            state     <= IDLE;
            bit_cnt   <= '0;
            shift_reg <= '0;
        end else if (baud_tick) begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (valid) begin
                        shift_reg <= data_in;
                        state     <= START;
                    end
                end

                START: begin
                    // Drive Tx line low for one baud tick
                    tx      <= 1'b0;
                    bit_cnt <= DATA_BITS - 1;
                    state   <= DATA;
                end

                DATA: begin
                    // Shift out one bit per baud tick
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    if (bit_cnt == '0) begin
                        bit_cnt <= STOP_BITS - 1;
                        state   <= STOP;
                    end else begin
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                STOP: begin
                    // Drive Tx line high for each stop bit
                    tx <= 1'b1;
                    if (bit_cnt == '0) begin
                        state <= IDLE;
                    end else begin
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
