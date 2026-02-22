// UART send task
task automatic uart_send_byte(input [7:0] data, input time baud_period, ref logic rx);
    // Start bit
    rx = 1'b0;
    #(baud_period);
    // Data bits (LSB first)
    for (int i = 0; i < 8; i++) begin
        rx = data[i];
        #(baud_period);
    end
    // Stop bit
    rx = 1'b1;
    #(baud_period);
endtask : uart_send_byte
