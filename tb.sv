`timescale 1ns / 1ps
module tb ();
 logic [13:0] rstring;//the input string
 logic clk = 1;//the clock
 logic rst;//the reset
 logic enable; //enable
 logic [2:0] size; //the size of the input string
 logic [6:0] dstring;//the output string
 logic done; //signal saying it is done decoding
decoder decoder(
    .rstring(rstring),
    .clk(clk),
    .rst(rst),
    .size(size),
    .enable(enable),
    .dstring(dstring),
    
    .done(done)
    );
initial begin
        forever #5ns clk = !clk;
    end

initial begin
enable = 1'b1;
size = 2'b10;
rstring = 10'b1101101010;

@(posedge clk);
@(posedge clk);
@(posedge clk);

enable = 1'b1;
size = 2'b01;
rstring = 8'b11010110;

end
endmodule
