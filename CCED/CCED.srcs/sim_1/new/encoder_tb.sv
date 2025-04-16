module encoder_tb;
    logic        clk;
    logic        rst;
    logic        data_in;
    logic        in_enable;
    logic        out_enable;
    logic [1:0]  constraint_sel;
    logic        encoded_out0;
    logic        encoded_out1;
    
    // Test pattern
    logic [7:0] test_pattern_val = 8'b10101010;
    
    // Storage for combined output sequence
    logic [15:0] output_sequence;  // Will store pairs of outputs
    
    // Instantiate the encoder
    encoder_k3 dut (.*);
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to run a test sequence
    task test_pattern(input [7:0] pattern, input [1:0] k_sel);
        output_sequence = '0;
        
        $display("\n=== Testing K=%0d Encoder ===", k_sel == 2'b00 ? 3 : k_sel == 2'b01 ? 4 : k_sel == 2'b10 ? 5 : 7);
        $display("Input sequence: %b", pattern);
        $display("Time\tInput\tRegister\tOutput Pair");
        $display("-----------------------------------------");
        
        for(int i = 7; i >= 0; i--) begin
            @(posedge clk);
            data_in = pattern[i];
            #1; // Wait for outputs to settle
            
            // Store output pair
            output_sequence[i*2 +: 2] = {encoded_out0, encoded_out1};
            
            // Display current state
            $display("%0t\t%b\t%b\t%b %b", $time, data_in, k_sel == 2'b00 ? dut.shift_reg3bit : k_sel == 2'b01 ? dut.shift_reg4bit : k_sel == 2'b10 ? dut.shift_reg5bit : dut.shift_reg7bit, encoded_out0, encoded_out1);
        end
        
        // Display complete output sequence
        $display("\nFinal Output Sequence (16 bits):");
        $display("Output: %b", output_sequence);
        $display("Input to Output mapping:");
        for(int i = 7; i >= 0; i--) begin
            $display("  Input: %b -> Output: %b", 
                    pattern[i],
                    output_sequence[i*2 +: 2]);
        end
        $display("");
    endtask
    
    // Main test sequence
    initial begin
        // Initialize
        rst = 1;
        data_in = 0;
        in_enable = 0;
        out_enable = 0;
        constraint_sel = 2'b00;
        
        // Reset sequence
        #10 rst = 0;
        
        // Enable signals
        in_enable = 1;
        out_enable = 1;
        
        $display("\n=== Convolutional Encoder Test ===");
        
        // Test each constraint length
        for(int k = 0; k < 4; k++) begin
            constraint_sel = k[1:0];
            test_pattern(test_pattern_val, k[1:0]);
        end
        
        $display("\n=== Test Complete ===\n");
        $finish;
    end
endmodule
