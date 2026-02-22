`timescale 1ns / 1ps

`include "TB_task_collection.vh"
`include "TB_macro_collection.vh"

program tb_uart ();
    parameter realtime BAUD_PERIOD = 1_000_000_000.0 / 921_600.0;

    byte test_byte;

    `TB_TEST_START("UART Test", 1)

    `TB_TEST_PART("Random receive test")
        `reset_uart
        #(BAUD_PERIOD);
        for (int i = 0; i < 100; i++) begin
            test_byte = $urandom_range(0, 8'hFF);
            fork
                uart_send_byte(test_byte, BAUD_PERIOD, TB.RsRx);
                `wait_for_posedge(TB.dut0.uart_if.rx_valid, 100us)
            join
            `Check(TB.dut0.uart_if.rx_data == test_byte, ("Byte %0d: expected 0x%02X got 0x%02X", i, test_byte, TB.dut0.uart_if.rx_data))
        end

    `TB_TEST_END(15ms)

endprogram
