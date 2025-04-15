module encoder_k3 (
    input  logic        clk,
    input  logic        rst,
    input  logic        data_in,
    input  logic        in_enable,
    input  logic        out_enable,
    input  logic [1:0]  constraint_sel,
    output logic        encoded_out0,
    output logic        encoded_out1
);
    // K=3 shift register (2 previous bits + current input)
    logic [2:0] shift_reg3bit;
    logic [3:0] shift_reg4bit;
    logic [4:0] shift_reg5bit;
    logic [6:0] shift_reg7bit;
    
    // Generator polynomials for K=3
    localparam [2:0] G0_3bit = 3'b111;  // First polynomial
    localparam [2:0] G1_3bit = 3'b101;  // Second polynomial
    
    localparam [3:0] G0_4bit = 4'b1101;
    localparam [3:0] G1_4bit = 4'b1111;
    
    localparam [4:0] G0_5bit = 5'b11011;
    localparam [4:0] G1_5bit = 5'b11111;
    
    localparam [6:0] G0_7bit = 7'b1111001;
    localparam [6:0] G1_7bit = 7'b1010111;    
    
    // Shift register logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg3bit <= 3'b0;
            shift_reg4bit <= 4'b0;
            shift_reg5bit <= 5'b0;
            shift_reg7bit <= 7'b0;
        end else if (in_enable) begin
            // Shift in new data to leftmost position
            case (constraint_sel)
                2'b00: begin
                    shift_reg3bit <= {data_in, shift_reg3bit[2:1]};
                end
                2'b01: begin
                    shift_reg4bit <= {data_in, shift_reg4bit[3:1]};
                end
                2'b10: begin
                    shift_reg5bit <= {data_in, shift_reg5bit[4:1]};
                end
                2'b11: begin
                    shift_reg7bit <= {data_in, shift_reg7bit[6:1]};
                end
            endcase
        end
    end
    
    // Output logic using XOR operations
    always_comb begin
        if (out_enable) begin
            // XOR bits where polynomial has 1's
            case (constraint_sel)
                2'b00: begin
                    encoded_out0 = ^(shift_reg3bit & G0_3bit);
                    encoded_out1 = ^(shift_reg3bit & G1_3bit);
                end
                2'b01: begin
                    encoded_out0 = ^(shift_reg4bit & G0_4bit);
                    encoded_out1 = ^(shift_reg4bit & G1_4bit);
                end
                2'b10: begin
                    encoded_out0 = ^(shift_reg5bit & G0_5bit);
                    encoded_out1 = ^(shift_reg5bit & G1_5bit);
                end
                2'b11: begin
                    encoded_out0 = ^(shift_reg7bit & G0_7bit);
                    encoded_out1 = ^(shift_reg7bit & G1_7bit);
                end
            endcase
            
        end else begin
            encoded_out0 = 1'b0;
            encoded_out1 = 1'b0;
        end
    end
endmodule
