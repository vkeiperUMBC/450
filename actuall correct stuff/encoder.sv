module encoder (
    input  logic        clk,
    input  logic        rst,
    input  logic        data_in,
    input  logic        in_enable,
    output logic        out_enable,
    input  logic [1:0]  constraint_sel,
    output logic        encoded_out0,
    output logic        encoded_out1
);
    // K=3 shift register (2 previous bits + current input)
    logic [2:0] shift_reg3bit;
    logic [3:0] shift_reg4bit;
    logic [4:0] shift_reg5bit;
    logic [6:0] shift_reg7bit;
    logic out_d, encoded_out0_comb, encoded_out1_comb;
    
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
            out_enable <= 1'b0;
            encoded_out0 <= 1'b0;
            encoded_out1 <= 1'b0;
        end else begin
            if (in_enable) begin
                out_enable <= 1'b0;
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
            end else begin
                out_enable <= out_d;
            end
            
            encoded_out0 <= encoded_out0_comb;
            encoded_out1 <= encoded_out1_comb;
        end
    end
    
    // Output logic using XOR operations
    always_comb begin
        // XOR bits where polynomial has 1's
        
        encoded_out0_comb = 1'b0;
        encoded_out1_comb = 1'b0;
        out_d = 1'b0;
        
        case (constraint_sel)
            2'b00: begin
                encoded_out0_comb = ^(shift_reg3bit & G0_3bit);
                encoded_out1_comb = ^(shift_reg3bit & G1_3bit);
                out_d = 1'b1;
            end
            2'b01: begin
                encoded_out0_comb = ^(shift_reg4bit & G0_4bit);
                encoded_out1_comb = ^(shift_reg4bit & G1_4bit);
                out_d = 1'b1;
            end
            2'b10: begin
                encoded_out0_comb = ^(shift_reg5bit & G0_5bit);
                encoded_out1_comb = ^(shift_reg5bit & G1_5bit);
                out_d = 1'b1;
            end
            2'b11: begin
                encoded_out0_comb = ^(shift_reg7bit & G0_7bit);
                encoded_out1_comb = ^(shift_reg7bit & G1_7bit);
                out_d = 1'b1;
            end
        endcase
    end
endmodule