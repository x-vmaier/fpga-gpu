`timescale 1ns / 1ps

`include "TB_task_collection.vh"
`include "TB_macro_collection.vh"

program tb_uart ();
    parameter realtime BAUD_PERIOD  = 1_000_000_000.0 / 921_600.0;
    parameter int      DATA_BITS    = 8;
    parameter int      START_BITS   = 1;
    parameter int      STOP_BITS    = 1;
    parameter int      TEST_MARGIN  = 1;
    parameter realtime FRAME_PERIOD = (START_BITS + DATA_BITS + STOP_BITS + TEST_MARGIN) * BAUD_PERIOD;

    logic [7:0] test_byte;
    logic [7:0] received_byte;
    logic framing_error;

    `TB_TEST_START("UART Test", 1)

    `TB_TEST_PART("Random receive test")
        `reset_uart
        #(BAUD_PERIOD);
        for (int i = 0; i < 100; i++) begin
            test_byte = $urandom_range(0, 8'hFF);
            fork
                uart_send_byte(test_byte, BAUD_PERIOD, TB.RsRx);
                `wait_for_posedge(TB.u_dut.uart_if.rx_valid, FRAME_PERIOD)
            join
            `Check(TB.u_dut.uart_if.rx_data == test_byte,
                ("Byte %0d: expected 0x%02X got 0x%02X", i, test_byte, TB.u_dut.uart_if.rx_data))
        end

    `TB_TEST_PART("Random transmit test")
        for (int i = 0; i < 100; i++) begin
            test_byte = $urandom_range(0, 8'hFF);

            // Wait for transmitter to be ready before sending
            fork
                wait(TB.u_dut.uart_if.tx_ready == 1'b1);
                begin
                    #(FRAME_PERIOD);
                    $error("Timeout waiting for transmitter to be ready, byte %0d", i);
                end
            join_any
            disable fork;

            // Load data and assert valid for one cycle to trigger transmission
            force TB.u_dut.uart_if.tx_data = test_byte;
            force TB.u_dut.uart_if.tx_valid = 1'b1;
            fork
                wait(TB.u_dut.uart_if.tx_ready == 1'b0);
                begin
                    #(FRAME_PERIOD);
                    $error("Timeout waiting for transmitter to start sending, byte %0d", i);
                end
            join_any
            disable fork;
            force TB.u_dut.uart_if.tx_valid = 1'b0;

            // Receive and verify
            fork
                uart_receive_byte(received_byte, framing_error, BAUD_PERIOD, TB.RsTx);
                begin
                    #(FRAME_PERIOD);
                    $error("Timeout waiting for transmission of byte %0d", i);
                end
            join_any
            disable fork;

            `Check(!framing_error, ("Byte %0d: framing error on received byte", i))
            `Check(received_byte == test_byte, ("Byte %0d: expected 0x%02X got 0x%02X", i, test_byte, received_byte))
        end
        release TB.u_dut.uart_if.tx_data;
        release TB.u_dut.uart_if.tx_valid;

    `TB_TEST_END(15ms)
endprogram
