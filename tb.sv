`timescale 1ns / 1ps
module tb ();
 logic [13:0] rstring;//the input string
 logic clk = 1;//the clock
 logic rst;//the reset
 logic [2:0] size; //the size of the input string
 logic [6:0] dstring;//the output string
 logic done; //signal saying it is done decoding
decoder decoder(
    .rstring(rstring),
    .clk(clk),
    .rst(rst),
    .size(size),
    .dstring(dstring),
    
    .done(done)
    );
initial begin
        forever #5ns clk = !clk;
    end

initial begin
size = 2'b11;
rstring = 14'b11111001101011;
$monitor("dstring is %0b", dstring);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
size = 2'b00;
rstring = 6'b111111;
end
endmodule
