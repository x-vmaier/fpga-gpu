`timescale 1ns / 1ps

`include "TB_task_collection.vh"
`include "TB_macro_collection.vh"

program tb_uart ();
    parameter time BAUD_PERIOD = 1_000_000_000 / 921_600; // ns

    `TB_TEST_START("UART Test", 1)

    `TB_TEST_PART("Receive test")
        `reset_uart
        uart_send_byte(8'h55, BAUD_PERIOD, TB.RsRx);
        `wait_for_posedge(TB.dut0.uart_if.rx_ready, 100us)
        `Check(TB.dut0.uart_if.rx_data == 8'h55, ("Failed to receive correct UART byte"))
        
        uart_send_byte(8'hA3, BAUD_PERIOD, TB.RsRx);
        `wait_for_posedge(TB.dut0.uart_if.rx_ready, 100us)
        `Check(TB.dut0.uart_if.rx_data == 8'hA3, ("Failed to receive correct UART byte"))

    `TB_TEST_END(500us)

endprogram
