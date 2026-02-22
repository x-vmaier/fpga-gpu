`timescale 1ns / 1ps

`include "TB_task_collection.vh"
`include "TB_macro_collection.vh"

program tb_uart();
    parameter int BAUD_PERIOD = 1085ns; // 921_600 baud

    `TB_TEST_START("UART Test", 1)

    `TB_TEST_PART("Receive test")
        TB.RsRx = 1; // Idle

        #50us;
        uart_send_byte(8'h55, BAUD_PERIOD);
        #50us;
        uart_send_byte(8'hA3, BAUD_PERIOD);

    `TB_TEST_END(500us)
endprogram
