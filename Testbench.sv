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

//please run the sim for 2200 ns;

initial begin
enable = 1'b1;
size = 2'b00;

rstring = 6'b110110;
while(done != 1'b1) begin
@(posedge clk);
end
@(posedge clk);
size = 2'b11;
rstring = 14'b11111001101011;
while(done != 1'b1) begin
@(posedge clk);
end
@(posedge clk);
size = 2'b00;

rstring = 6'b001110;
while(done != 1'b1) begin
@(posedge clk);
end
@(posedge clk);
size = 2'b01;

rstring = 8'b11011001;
while(done != 1'b1) begin
@(posedge clk);
end
@(posedge clk);
size = 2'b10;

rstring = 10'b0000110110;
while(done != 1'b1) begin
@(posedge clk);
end
@(posedge clk);
end
endmodule
