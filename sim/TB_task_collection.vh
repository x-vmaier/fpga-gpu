task automatic uart_send_byte(input [7:0] data, input realtime baud_period, ref logic rx);
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

task automatic uart_receive_byte(output [7:0] data, output logic framing_error,
                                 input realtime baud_period, ref logic tx);
    framing_error = 1'b0;
    // Wait for start bit
    @(negedge tx);
    // Sample at bit center
    #(baud_period / 2);
    if (tx !== 1'b0) begin
        // Abort on glitch
        framing_error = 1'b1;
        return;
    end
    // Read bits at bit center
    for (int i = 0; i < 8; i++) begin
        #(baud_period);
        data[i] = tx;
    end
    #(baud_period);
    // Verify stop bit
    if (tx !== 1'b1) begin
        framing_error = 1'b1;
    end
endtask : uart_receive_byte
