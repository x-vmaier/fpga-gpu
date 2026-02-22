// Clocking
`define start_clock \
    initial begin \
        clk = 0; \
        forever #5ns clk = ~clk; \
    end \

// Error variable declarations
`define define_errorvariables \
    integer TB_error_count; \
    integer TB_assert_count; \
    integer TB_sim_mode; \
    time    TB_time_start; \
    event   TB_error_event;

// Error variable initialization
`define init_errorvariables \
    TB_error_count = 0; \
    TB_assert_count = 0; \
    TB_sim_mode = 1; \
    TB_time_start = $time;

/*
 * TB_TEST_START
 * Opens the initial block, resets DUT for 10ns if sim_mode=1.
 *
 * Params:
 *     title:    Name of the test
 *     sim_mode: 1 = reset DUT, 0 = skip reset
 *
 * Note: Must be closed with TB_TEST_END
 */
`define TB_TEST_START(title, sim_mode) \
    `define_errorvariables \
    initial begin \
        fork \
            begin \
                `init_errorvariables \
                TB_sim_mode = sim_mode; \
                $display("\n========================================== %s ==========================================", title); \
                $display("Info:  Time: %t ns \tTB_TEST_START \tSim-Mode: %s", $time, TB_sim_mode ? "true" : "false"); \
                if (TB_sim_mode) begin \
                    $display("Info:  Time: %t ns \tReset device", $time); \
                    force TB.dut0.rst_n = 0; \
                    #10ns; \
                    force TB.dut0.rst_n = 1; \
                end

/*
 * TB_TEST_PART
 * Prints part header.
 *
 * Params:
 *     message: Description of the test part
 */
`define TB_TEST_PART(message) \
    $display("Info:  Time: %t ns \tTB_TEST_PART: \t%s", $time, message); \

/*
 * TB_TEST_END
 * Closes the initial block opened by TB_TEST_START.
 * Runs a parallel timeout thread.
 *
 * Params:
 *     sim_timeout: Max simulation time (e.g. 18ms). Use 0 to disable.
 *
 * Note: Must follow TB_TEST_START
 */
`define TB_TEST_END(sim_timeout) \
                if (TB_sim_mode) begin \
                    release TB.dut0.rst_n; \
                end \
                $display("Info:  Time: %t ns \tTest completed with %0d errors and %0d assertions", $time, TB_error_count, TB_assert_count); \
                $display("=============================================================================================="); \
                if (TB_error_count > 0) begin \
                    $display("TEST FAILED with %0d errors!\n", TB_error_count); \
                end else begin \
                    $display("TEST PASSED - All %0d assertions successful!\n", TB_assert_count); \
                end \
            end \
            begin \
                #sim_timeout; \
                $display("Warning: Simulation timeout reached at %t ns", $time); \
                $finish; \
            end \
        join_any \
        disable fork; \
        #1ns; \
    end

/*
 * wait_for_posedge
 * Waits for posedge of signal. Stops simulation on timeout.
 *
 * Params:
 *     clk:     Signal to wait on
 *     timeout: Max wait time (e.g. 10us)
 */
`define wait_for_posedge(clk, timeout) \
    fork begin \
        fork \
            begin \
                @(posedge clk); \
            end \
            begin \
                #timeout; \
                $display("Error: Timeout waiting for posedge. Line %0d", `__LINE__); \
                $stop; \
            end \
        join_any \
        disable fork; \
    end join

/*
 * wait_for_negedge
 * Waits for negedge of signal. Stops simulation on timeout.
 *
 * Params:
 *     clk:     Signal to wait on
 *     timeout: Max wait time (e.g. 10us)
 */
`define wait_for_negedge(clk, timeout) \
    fork begin \
        fork \
            begin \
                @(negedge clk); \
            end \
            begin \
                #timeout; \
                $display("Error: Timeout waiting for negedge. Line %0d", `__LINE__); \
                $stop; \
            end \
        join_any \
        disable fork; \
    end join

/*
 * Check
 * Immediate assertion with error counting and event trigger.
 *
 * Params:
 *     compare: Expression to assert
 *     message: Format string in double parens, e.g. ("val=%0d", x)
 */
`define Check(compare, message) \
    begin \
        TB_assert_count++; \
        if (!(compare)) begin \
            TB_error_count++; \
            $display("Error: Time: %t ns \t[Line %0d] %s", $time, `__LINE__, $sformatf message); \
            ->TB_error_event; \
        end \
    end

/*
 * Check_blur
 * Checks if |param1 - param2| <= blur.
 *
 * Params:
 *     param1:  Measured value
 *     param2:  Expected value
 *     blur:    Tolerance
 *     message: Format string in double parens, e.g. ("got=%0t", x)
 */
`define Check_blur(param1, param2, blur, message) \
    begin \
        TB_assert_count++; \
        if (!((param1 <= param2 + blur) && (param1 >= param2 - blur))) begin \
            TB_error_count++; \
            $display("Error: Time: %t ns \t[Line %0d] %s", $time, `__LINE__, $sformatf message); \
            $display("Info:  Time: %t ns \t  measured = %0t, expected = %0t, blur = %0t", $time, param1, param2, blur); \
            ->TB_error_event; \
        end \
    end
