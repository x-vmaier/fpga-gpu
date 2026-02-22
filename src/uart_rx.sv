`timescale 1ns / 1ps

module uart_rx #(
    parameter int DATA_BITS   = 8,
    parameter int STOP_BITS   = 1,
    parameter int PARITY_BITS = 0
) (
    input logic clk,
    input logic rst_n,
    input logic baud_tick,
    input logic rx,
    output logic valid,
    output logic ready,
    output logic [DATA_BITS-1:0] data_out
);
    // Sample at the center of each bit period
    localparam int HALF_BIT = 7;
    localparam int FULL_BIT = 15;

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state;
    logic [3:0] pulse_cnt;  // 0..15 within each bit window
    logic [$clog2(DATA_BITS):0] bit_cnt;  // how many data bits received
    logic [DATA_BITS-1:0] shift_reg;

    assign ready = 1'b1;
    assign data_out = shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            pulse_cnt <= '0;
            bit_cnt   <= '0;
            shift_reg <= '0;
            valid     <= 1'b0;
        end else begin
            valid <= 1'b0;  // default: deassert each cycle

            if (baud_tick) begin
                case (state)
                    IDLE: begin
                        pulse_cnt <= '0;
                        bit_cnt   <= '0;
                        if (!rx)  // falling edge -> start bit detected
                            state <= START;
                    end

                    // Verify start bit is still low at the centre (tick 7)
                    // If the line went high it was a glitch; return to IDLE
                    START: begin
                        if (pulse_cnt == HALF_BIT[3:0]) begin
                            if (!rx) begin
                                // Confirmed start bit; reset counter for data
                                pulse_cnt <= '0;
                                state     <= DATA;
                            end else begin
                                // Glitch – abort
                                pulse_cnt <= '0;
                                state     <= IDLE;
                            end
                        end else begin
                            pulse_cnt <= pulse_cnt + 1'b1;
                        end
                    end

                    // Sample each data bit at the centre of its 16-tick window
                    DATA: begin
                        if (pulse_cnt == FULL_BIT[3:0]) begin
                            pulse_cnt <= '0;
                            // Shift in LSB-first
                            shift_reg <= {rx, shift_reg[DATA_BITS-1:1]};
                            if (bit_cnt == DATA_BITS - 1) begin
                                bit_cnt <= '0;
                                state   <= STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end else begin
                            pulse_cnt <= pulse_cnt + 1'b1;
                        end
                    end

                    // Wait for stop bit(s); assert valid on the centre sample
                    STOP: begin
                        if (pulse_cnt == HALF_BIT[3:0]) begin
                            valid     <= 1'b1;  // data_out is stable here
                            pulse_cnt <= '0;
                            state     <= IDLE;
                        end else begin
                            pulse_cnt <= pulse_cnt + 1'b1;
                        end
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
