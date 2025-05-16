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
    
    //input_bits
    logic [7:0] input_bits = 8'b10101010;
    
    //Store the output bits here
    logic [15:0] output_sequence;
    
    //Expected values based on the constraint length
    logic [15:0] expected_k3 = 16'b1101000100010001;
    logic [15:0] expected_k4 = 16'b1111010001000100;
    logic [15:0] expected_k5 = 16'b1111010010001000;
    logic [15:0] expected_k7 = 16'b1101000010100110;
    
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
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task test_constraint_length(input [1:0] k_sel);
        logic [15:0] expected_output;   //set depending on the constraint (kvalue)
        int k_value;
        output_sequence = 16'b0;
        
        //check which constraint is being tested
        if (k_sel == 2'b00) begin
            k_value = 3;
            expected_output = expected_k3;
        end
        else if (k_sel == 2'b01) begin
            k_value = 4;
            expected_output = expected_k4;
        end
        else if (k_sel == 2'b10) begin
            k_value = 5;
            expected_output = expected_k5;
        end
        else begin
            k_value = 7;
            expected_output = expected_k7;
        end
        
        $display("\n----Testing K=%0d Encoder----", k_value);
        $display("Input sequence: %b", input_bits);
        $display("Time | Input | Out_Enable | Output Pair");
        $display("---------------------------------------");
        
        rst = 1;
        in_enable = 0;
        data_in = 0;
        constraint_sel = k_sel;
        @(posedge clk);
        rst = 0;
        
        //Each input bit
        for(int i = 7; i >= 0; i--) begin
            @(posedge clk);
            in_enable = 1;
            data_in = input_bits[i];
            
            @(posedge clk);
            in_enable = 0;
            
            while (!out_enable) @(posedge clk);
            
            output_sequence[i*2] = encoded_out0;
            output_sequence[i*2+1] = encoded_out1;
            
            $display("%0t\t%b\t%b\t\t%b %b", $time, data_in, out_enable, encoded_out0, encoded_out1);
        end
        
        $display("\nResults for K=%0d:", k_value);
        $display("Got Output:%b", output_sequence);
        $display("Expected Output:%b", expected_output);
            
        $display("\nInput to Output:");
        for(int i = 7; i >= 0; i--) begin
            $display("Input: %b : Output: %b%b (Expected: %b%b)",input_bits[i], output_sequence[i*2+1], output_sequence[i*2], expected_output[i*2+1], expected_output[i*2]);
        end
        $display();    
        if (output_sequence == expected_output)
            $display("TEST PASSED: K=%0d", k_value);
        else
            $display("TEST FAILED: K=%0d", k_value);
    endtask
    
    //Main Testing Phase
    initial begin
        $display("\nConvolutional Encoder Test");
        
        test_constraint_length(2'b00);  // K=3
        test_constraint_length(2'b01);  // K=4
        test_constraint_length(2'b10);  // K=5
        test_constraint_length(2'b11);  // K=7
        
        $display("\n----Test Complete----\n");
        $finish;
    end
endmodule