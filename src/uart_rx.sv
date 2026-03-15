`timescale 1ns / 1ps

(* keep_hierarchy = "yes" *) module uart_rx #(
    parameter int DATA_BITS = 8,
    parameter int STOP_BITS = 1,
    parameter int BAUD_OSR  = 8
) (
    input logic clk,
    input logic rst_n,
    input logic baud_osr_tick,
    input logic rx,
    output logic valid,
    output logic frame_error,
    output logic [DATA_BITS-1:0] data_out
);
    // Sample at the center of each bit period
    localparam SAMPLE_POINT = BAUD_OSR / 2;

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state;
    logic [$clog2(BAUD_OSR+1)-1:0] tick_cnt;
    logic [$clog2(DATA_BITS):0] bit_cnt;
    logic [DATA_BITS-1:0] shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            tick_cnt    <= '0;
            bit_cnt     <= '0;
            shift_reg   <= '0;
            data_out    <= '0;
            valid       <= 1'b0;
            frame_error <= 1'b0;
        end else begin
            // Deassert each cycle
            valid <= 1'b0;

            // Oversampled Rx state machine
            if (baud_osr_tick) begin
                case (state)
                    IDLE: begin
                        tick_cnt <= '0;
                        bit_cnt  <= '0;

                        // Falling edge translates to start bit
                        if (!rx) begin
                            state <= START;
                            frame_error <= 1'b0;  // Remain assertion valid until next start bit
                        end
                    end

                    START: begin
                        if (tick_cnt == SAMPLE_POINT) begin
                            // Verify start bit is still low at bit center
                            if (!rx) begin
                                // Confirmed start bit
                                tick_cnt <= '0;  // Current position is at the bit center
                                state    <= DATA;
                            end else begin
                                // Glitch happened if line went back high
                                state <= IDLE;  // Return to IDLE
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end

                    DATA: begin
                        // To get from the center of a bit period to
                        // the next, proceed one full bit period.
                        if (tick_cnt == BAUD_OSR - 1) begin
                            tick_cnt  <= '0;

                            // Shift in LSB-first
                            shift_reg <= {rx, shift_reg[DATA_BITS-1:1]};
                            if (bit_cnt == DATA_BITS - 1) begin
                                // All data bits are read
                                bit_cnt <= '0;
                                state   <= STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 1'b1;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end

                    STOP: begin
                        if (tick_cnt == BAUD_OSR - 1) begin
                            // Data only valid if stop bit is high
                            if (rx) begin
                                data_out <= shift_reg;
                                valid <= 1'b1;
                            end else begin
                                frame_error <= 1'b1;
                            end
                            tick_cnt <= '0;
                            state    <= IDLE;
                        end else begin
                            tick_cnt <= tick_cnt + 1'b1;
                        end
                    end

                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
