// UART send task
task uart_send_byte(
    input [7:0] data,
    input baud_period
);
    integer i;
    begin
        // Start bit
        TB.RsRx = 0;
        #(baud_period);

        // Data bits
        for (i = 0; i < 8; i = i + 1) begin
            TB.RsRx = data[i];
            #(baud_period);
        end

        // Stop bit
        TB.RsRx = 1;
        #(baud_period);
    end
endtask : uart_send_byte
