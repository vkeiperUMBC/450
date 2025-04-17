`timescale 1ns / 1ps
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
    logic [7:0] test_pattern_val = 8'b01000101;
    
    // Storage for combined output sequence
    logic [15:0] output_sequence;  // Will store pairs of outputs
    
    // Instantiate the encoder
    encoder dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .in_enable(in_enable),
        .out_enable(out_enable),
        .constraint_sel(constraint_sel),
        .encoded_out0(encoded_out0),
        .encoded_out1(encoded_out1)
    );
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Task to run a test sequence
    task test_pattern(input [7:0] pattern, input [1:0] k_sel);
        // Declare local variables at beginning of task
        int wait_count;
        
        output_sequence = '0;
        
        $display("\n=== Testing K=%0d Encoder ===", k_sel == 2'b00 ? 3 : k_sel == 2'b01 ? 4 : k_sel == 2'b10 ? 5 : 7);
        $display("Input sequence: %b", pattern);
        $display("Time\tInput\tin_en\tout_en\tRegister\tOutput Pair");
        $display("----------------------------------------------------");
        
        for(int i = 7; i >= 0; i--) begin
            // Set up input for this bit
            @(posedge clk);
            data_in = pattern[i];
            in_enable = 1'b1;  // Enable input for this bit
            $display("%0t\t%b\t%b\t%b\t%s\t%b %b", $time, data_in, in_enable, out_enable, 
                   "Input", encoded_out0, encoded_out1);
            
            // Disable input and wait for out_enable
            @(posedge clk);
            in_enable = 1'b0;  // Disable input
            
            // Wait for out_enable to go high or a timeout
            wait_count = 0;  // Reset counter each iteration
            while (!out_enable && wait_count < 5) begin
                @(posedge clk);
                wait_count++;
            end
            
            // If we timed out waiting for out_enable
            if (!out_enable) begin
                $display("WARNING: out_enable did not go high after %0d cycles at time %0t", wait_count, $time);
                // Continue anyway
            end
            
            // Display and capture output regardless of out_enable state
            // Store this bit's encoded output pair
            output_sequence[i*2 +: 2] = {encoded_out0, encoded_out1};
            
            // Display current state with proper shift register display
            case (k_sel)
                2'b00: $display("%0t\t%b\t%b\t%b\t%b\t%b %b", $time, pattern[i], in_enable, out_enable, 
                               dut.shift_reg3bit, encoded_out0, encoded_out1);
                2'b01: $display("%0t\t%b\t%b\t%b\t%b\t%b %b", $time, pattern[i], in_enable, out_enable, 
                               dut.shift_reg4bit, encoded_out0, encoded_out1);
                2'b10: $display("%0t\t%b\t%b\t%b\t%b\t%b %b", $time, pattern[i], in_enable, out_enable, 
                               dut.shift_reg5bit, encoded_out0, encoded_out1);
                2'b11: $display("%0t\t%b\t%b\t%b\t%b\t%b %b", $time, pattern[i], in_enable, out_enable, 
                               dut.shift_reg7bit, encoded_out0, encoded_out1);
            endcase
            
            // Wait at least one cycle between bits
            @(posedge clk);
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
        constraint_sel = 2'b00;
        
        // Reset sequence
        #20 rst = 0;
        #10;  // Wait a bit after reset
        
        $display("\n=== Convolutional Encoder Test ===");
        
        // Test each constraint length
        for(int k = 0; k < 4; k++) begin
            constraint_sel = k[1:0];
            #10;  // Wait between constraint changes
            test_pattern(test_pattern_val, k[1:0]);
        end
        
        $display("\n=== Test Complete ===\n");
        $finish;
    end
endmodule