`timescale 1ns / 1ps

/*
This is the decoder for the CCED, it should work with different
constraint lengths to decode 

*/



module decoder(
input logic [13:0] rstring,//the input string
input logic clk,//the clock
input logic rst,//the reset
input logic [2:0] size, //the size of the input string
output logic [6:0] dstring,//the output string
output logic done //signal saying it is done decoding
);


//trackers signifies if the decoding is done
logic doneq = 0;
assign done = doneq;

//7 tracker (11)
logic [6:0] lowest7 = 7'b1111111; //the lowest number of differences
logic [6:0] lowestString7 = 7'b0;//the string with the lowest number of differences
logic [6:0] numDifs7 = 7'b0;//number of differences per round
logic [6:0] guess7 = 7'b0000000; //the guess counts up, the bits help determine a path
logic [6:0] mstring7 =7'b0;//string that is temporary
int i7 = 7;//counts down to 0 then restarts and finds another string
int j7 = 126;//counts down to zero and starts a new string to decode all together
//5 tracker (10)
logic [4:0] lowest5 = 5'b11111; //the lowest number of differences
logic [4:0] lowestString5 = 5'b0;//the string with the lowest number of differences
logic [4:0] numDifs5 = 5'b0;//number of differences per round
logic [4:0] guess5 = 5'b00000; //the guess counts up, the bits help determine a path
logic [4:0] mstring5 =5'b0;//string that is temporary
int i5 = 5;//counts down to 0 then restarts and finds another string
int j5 = 32;//counts down to zero and starts a new string to decode all together
//4 tracker (01)
logic [3:0] lowest4 = 4'b1111; //the lowest number of differences
logic [3:0] lowestString4 = 4'b0;//the string with the lowest number of differences
logic [3:0] numDifs4 = 4'b0;//number of differences per round
logic [3:0] guess4 = 4'b0000; //the guess counts up, the bits help determine a path
logic [3:0] mstring4 =4'b0;//string that is temporary
int i4 = 4;//counts down to 0 then restarts and finds another string
int j4 = 16;//counts down to zero and starts a new string to decode all together
//3 tracker (00)
logic [2:0] lowest3 = 3'b111; //the lowest number of differences
logic [2:0] lowestString3 = 3'b0;//the string with the lowest number of differences
logic [2:0] numDifs3 = 3'b0;//number of differences per round
logic [2:0] guess3 = 3'b000; //the guess counts up, the bits help determine a path
logic [2:0] mstring3 =3'b0;//string that is temporary
int i3 = 3;//counts down to 0 then restarts and finds another string
int j3 = 8;//counts down to zero and starts a new string to decode all together
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//7 tracker Q(11)
logic [4:0] numDifs7Q = 7'b0;//number of differences per round
logic [6:0] mstring7Q =7'b0;//string that is temporary
//5 tracker Q(10)
logic [4:0] numDifs5Q = 5'b0;//number of differences per round
logic [4:0] mstring5Q =5'b0;//string that is temporary

//4 tracker Q(01)
logic [3:0] numDifs4Q = 4'b0;//number of differences per round
logic [3:0] mstring4Q =4'b0;//string that is temporary

//3 tracker Q(00)
logic [2:0] numDifs3Q = 3'b0;//number of differences per round
logic [2:0] mstring3Q =3'b0;//string that is temporary




int option1;//option to go down path 1
int option2;//option to go down path 2
logic other = 0; //when there are two options the other variable determined by guess will choose a path

int k;//used in the for loops
int m = 0;
int mQ = 0;// used in getting the bit in guess
logic [1:0] NS;// the next state

//state machine
localparam [1:0] S0 = 2'b00, S1 = 2'b10, S2 = 2'b01, S3 = 2'b11;
logic two [1:0];// used in getting two bits from rstring
logic [1:0] CS = S0;//current state

//FlipFlop
always_ff @ (posedge clk or posedge rst) begin
//checks to detect certain bit string, will be removed from final product
if(size == 2'b00)begin
if (rst) begin
CS <= S0;
i3 <= 6;
j3 <= 7;
doneq <= 0;
guess3 <= 3'b000;
dstring <= 3'bx;
end else begin
if(i3 > 1) begin //counts down i to zero, saves variables as to not reset them
CS <= NS;
i3 <= i3 -1;
dstring <= 3'bx;
doneq <= 0;
j3 <= j3 - 1;
lowest3 <= lowest3;
lowestString3 <= lowestString3;
mstring3 <= mstring3Q;
end else if(j3 == 0) begin//if j equals zero it means it's waiting for a new string to be an input
CS <= S0;
i3 <= 6;
j3 <= 6;
doneq <= 1;
m <= mQ;
guess3 <= 3'b000;
dstring <= lowestString3;
end else begin //this is when i = 0, where a new guess string is formed
CS <= S0;
i3 <= 6;
j3 <= j3 - 1;
guess3 <= guess3 + 1;

doneq <= 0;


if(lowest3 > numDifs3Q) begin// checks to see if the next string can be saved if the numDifs is lower than the previous saved #
lowest3 <= numDifs3Q;

lowestString3 <= mstring3Q;
end
end
end



end else if (size == 2'b01)begin
if (rst) begin
CS <= S0;
i4 <= 7;
j4 <= 127;
doneq <= 0;
guess4 <= 4'b0000;
dstring <= 4'bx;
end else begin
if(i4 > 1) begin //counts down i to zero, saves variables as to not reset them
CS <= NS;
i4 <= i4 -1;
dstring <= 4'bx;
doneq <= 0;
j4 <= j4 - 1;
lowest4 <= lowest4;
lowestString4 <= lowestString4;
mstring4 <= mstring4Q;
end else if(j4 == 0) begin//if j equals zero it means it's waiting for a new string to be an input
CS <= S0;
i4 <= 3;
j4 <= 15;
doneq <= 1;
m<=0;
guess4 <= 4'b0000;
dstring <= lowestString4;
end else begin //this is when i = 0, where a new guess string is formed
CS <= S0;
i4 <= 3;
j4 <= j4 - 1;
guess4 <= guess4 + 1;
numDifs4 <= 4'b0;

if(lowest4 > numDifs4Q) begin// checks to see if the next string can be saved if the numDifs is lower than the previous saved #
lowest4 <= numDifs4Q;

lowestString4 <= mstring4Q;
end
end
end


end else if (size == 2'b10)begin
if (rst) begin
CS <= S0;
i5 <= 5;
j5 <= 31;
doneq <= 0;
guess5 <= 5'b00000;
dstring <= 5'bx;
end else begin
if(i5 > 1) begin //counts down i to zero, saves variables as to not reset them
CS <= NS;
i5 <= i5 -1;
dstring <= 5'bx;
doneq <= 0;
j5 <= j5 - 1;
lowest5 <= lowest5;
lowestString5 <= lowestString5;
mstring5 <= mstring5Q;
end else if(j5 == 0) begin//if j equals zero it means it's waiting for a new string to be an input
CS <= S0;
i5 <= 4;
j5 <= 30;
doneq <= 1;
m<=0;
guess5 <= 5'b000000;
dstring <= lowestString5;
end else begin //this is when i = 0, where a new guess string is formed
CS <= S0;
i5 <= 4;
j5 <= j5 - 1;
guess5 <= guess5 + 1;
numDifs5 <= 5'b0;

if(lowest5 > numDifs5Q) begin// checks to see if the next string can be saved if the numDifs is lower than the previous saved #
lowest5 <= numDifs5Q;

lowestString5 <= mstring5Q;
end
end
end


end else if (size == 2'b11)begin
if (rst) begin
CS <= S0;
i7 <= 7;
j7 <= 127;
doneq <= 0;
guess7 <= 7'b0000000;
dstring <= 7'bx;
end else begin
if(i7 > 1) begin //counts down i to zero, saves variables as to not reset them
CS <= NS;
i7 <= i7 -1;
j7 <= j7 - 1;
dstring <= 7'bx;
doneq <= 0;

lowest7 <= lowest7;
lowestString7 <= lowestString7;
mstring7 <= mstring7Q;
end else if(j7 == 0) begin//if j equals zero it means it's waiting for a new string to be an input
CS <= S0;
i7 <= 6;
j7 <= 126;
doneq <= 1;
m<=0;
guess7 <= 7'b0000000;
dstring <= lowestString7;
end else begin //this is when i = 0, where a new guess string is formed
CS <= S0;
i7 <= 6;
j7 <= j7 - 1;
guess7 <= guess7 + 1;
numDifs7 <= 7'b0;

if(lowest7 > numDifs7Q) begin// checks to see if the next string can be saved if the numDifs is lower than the previous saved #
lowest7 <= numDifs7Q;

lowestString7 <= mstring7Q;
end
end
end

end else begin

end

end

//Changes and determines next state
always_comb begin 


if(size == 2'b00)begin

numDifs3Q = 3'b0;
numDifs4Q = 4'b0;
numDifs5Q = 5'b0;
numDifs7Q = 7'b0;
mstring3Q = 3'b0;
mstring4Q = 4'b0;
mstring5Q = 5'b0;
mstring7Q = 7'b0;

mQ = 1'b0;

option1 = 0;
option2 = 0;
two = {rstring[(i3*2)+1], rstring[(i3*2)]};
case (CS)
    S0 : begin //the first state

//finds the hamming distance between two different 2 bit strings
    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
        
    //finds the lowest number of difference between the two options
    if(option1 < option2) begin
    NS = S1;
    mstring3Q[i3] = 1;
    numDifs3Q = numDifs3Q + option1;
    end else if(option2 < option1) begin
    NS = S0;
    mstring3Q[i3] = 0;
    numDifs3Q = numDifs3Q + option2;
    end else begin
 
 //if there are ties, go to guess to determine path
    numDifs3Q = numDifs3Q + option1;
    other = guess3[mQ];
    mQ = mQ + 1;
        if(other == 0) begin
        NS = S1;
        mstring3Q[i3] = 1;
        end else begin
        NS = S0;
        mstring3Q[i3] = 0;
     end
    end
    end
    
    //these same notations apply to all the other states
    S1: begin //the second state

        for(k = 1; k >= 0; k = k - 1) begin
            option1 += two[k] ^ S2[k];
            end
        for(k = 1; k >= 0; k = k - 1) begin
            option2 += two[k] ^ S1[k];
            end
        if(option1 < option2) begin
        NS = S3;
        mstring3Q[i3] = 1;
        numDifs3Q = numDifs3Q + option1;
        end else if(option2 < option1) begin
        NS = S2;
        mstring3Q[i3] = 0;
        numDifs3Q = numDifs3Q + option2;
        end else begin
        numDifs3Q = numDifs3Q + option1;
        other = guess3[mQ];
        mQ = mQ + 1;
            if(other == 1) begin
            NS = S3;
            mstring3Q[i3] = 1;
            end else begin
            NS = S2;
            mstring3Q[i3] = 0;
         end
        end
           
        end
    S2: begin //the third state

    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
    if(option1 < option2) begin
        NS = S0;
        mstring3Q[i3] = 0;
        numDifs3Q = numDifs3Q + option1;
            end else if(option2 < option1) begin
            NS = S1;
            mstring3Q[i3] = 1;
            numDifs3Q = numDifs3Q + option2;
            end else begin
            other = guess3[mQ];
            mQ = mQ + 1;
            numDifs3Q = numDifs3Q + option1;
                if(other == 1) begin
                NS = S0;
                mstring3Q[i3] = 0;
                end else begin
                NS = S1;
                mstring3Q[i3] = 1;
             end
            end
               end
    S3: begin //the fourth state

for(k = 1; k >= 0; k = k - 1) begin
                option1 += two[k] ^ S1[k];
                end
            for(k = 1; k >= 0; k = k - 1) begin
                option2 += two[k] ^ S2[k];
                end
            if(option1 < option2) begin
            NS = S3;
            mstring3Q[i3] = 1;
            numDifs3Q = numDifs3Q + option1;
            end else if(option2 < option1) begin
            NS = S2;
            mstring3Q[i3] = 0;
            numDifs3Q = numDifs3Q + option2;
            end else begin
            numDifs3Q = numDifs3Q + option1;
            other = guess3[mQ];
            mQ = mQ + 1;
                if(other == 1) begin
                NS = S3;
                mstring3Q[i3] = 1;
                end else begin
                NS = S2;
                mstring3Q[i3] = 0;
             end
            end
               end
     default: begin //default

     end 
endcase
end

else if(size == 2'b01) begin
option1 = 0;
option2 = 0;
two = {rstring[(i4*2)+1], rstring[(i4*2)]};

case (CS)
    S0 : begin //the first state

//finds the hamming distance between two different 2 bit strings
    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
        
    //finds the lowest number of difference between the two options
    if(option1 < option2) begin
    NS = S1;
    mstring4Q[i4] = 1;
    numDifs4Q = numDifs4Q + option1;
    end else if(option2 < option1) begin
    NS = S0;
    mstring4Q[i4] = 0;
    numDifs4Q = numDifs4Q + option2;
    end else begin
 
 //if there are ties, go to guess to determine path
    numDifs4Q = numDifs4Q + option1;
    other = guess4[mQ];
    mQ = mQ + 1;
        if(other == 0) begin
        NS = S1;
        mstring4Q[i4] = 1;
        end else begin
        NS = S0;
        mstring4Q[i4] = 0;
     end
    end
    end
    
    //these same notations apply to all the other states
    S1: begin //the second state

        for(k = 1; k >= 0; k = k - 1) begin
            option1 += two[k] ^ S2[k];
            end
        for(k = 1; k >= 0; k = k - 1) begin
            option2 += two[k] ^ S1[k];
            end
        if(option1 < option2) begin
        NS = S3;
        mstring4Q[i4] = 1;
        numDifs4Q = numDifs4Q + option1;
        end else if(option2 < option1) begin
        NS = S2;
        mstring4Q[i4] = 0;
        numDifs4Q = numDifs4Q + option2;
        end else begin
        numDifs4Q = numDifs4Q + option1;
        other = guess4[mQ];
        mQ = mQ + 1;
            if(other == 1) begin
            NS = S3;
            mstring4Q[i4] = 1;
            end else begin
            NS = S2;
            mstring4Q[i4] = 0;
         end
        end
           
        end
    S2: begin //the third state

    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
    if(option1 < option2) begin
        NS = S0;
        mstring4Q[i4] = 0;
        numDifs4Q = numDifs4Q + option1;
            end else if(option2 < option1) begin
            NS = S1;
            mstring4Q[i4] = 1;
            numDifs4Q = numDifs4Q + option2;
            end else begin
            other = guess4[mQ];
            mQ = mQ + 1;
            numDifs4Q = numDifs4Q + option1;
                if(other == 1) begin
                NS = S0;
                mstring4Q[i4] = 0;
                end else begin
                NS = S1;
                mstring4Q[i4] = 1;
             end
            end
               end
    S3: begin //the fourth state

for(k = 1; k >= 0; k = k - 1) begin
                option1 += two[k] ^ S1[k];
                end
            for(k = 1; k >= 0; k = k - 1) begin
                option2 += two[k] ^ S2[k];
                end
            if(option1 < option2) begin
            NS = S3;
            mstring4Q[i4] = 1;
            numDifs4Q = numDifs4Q + option1;
            end else if(option2 < option1) begin
            NS = S2;
            mstring4Q[i4] = 0;
            numDifs4Q = numDifs4Q + option2;
            end else begin
            numDifs4Q = numDifs4Q + option1;
            other = guess4[mQ];
            mQ = mQ + 1;
                if(other == 1) begin
                NS = S3;
                mstring4Q[i4] = 1;
                end else begin
                NS = S2;
                mstring4Q[i4] = 0;
             end
            end
               end
     default: begin //default

     end 
endcase
end

else if (size == 2'b10) begin
option1 = 0;
option2 = 0;
two = {rstring[(i5*2)+1], rstring[(i5*2)]};
case (CS)
    S0 : begin //the first state

//finds the hamming distance between two different 2 bit strings
    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
        
    //finds the lowest number of difference between the two options
    if(option1 < option2) begin
    NS = S1;
    mstring5Q[i5] = 1;
    numDifs5Q = numDifs5Q + option1;
    end else if(option2 < option1) begin
    NS = S0;
    mstring5Q[i5] = 0;
    numDifs5Q = numDifs5Q + option2;
    end else begin
 
 //if there are ties, go to guess to determine path
    numDifs5Q = numDifs5Q + option1;
    other = guess5[mQ];
    mQ = mQ + 1;
        if(other == 0) begin
        NS = S1;
        mstring5Q[i5] = 1;
        end else begin
        NS = S0;
        mstring5Q[i5] = 0;
     end
    end
    end
    
    //these same notations apply to all the other states
    S1: begin //the second state

        for(k = 1; k >= 0; k = k - 1) begin
            option1 += two[k] ^ S2[k];
            end
        for(k = 1; k >= 0; k = k - 1) begin
            option2 += two[k] ^ S1[k];
            end
        if(option1 < option2) begin
        NS = S3;
        mstring5Q[i5] = 1;
        numDifs5Q = numDifs5Q + option1;
        end else if(option2 < option1) begin
        NS = S2;
        mstring5Q[i5] = 0;
        numDifs5Q = numDifs5Q + option2;
        end else begin
        numDifs5Q = numDifs5Q + option1;
        other = guess5[mQ];
        mQ = mQ + 1;
            if(other == 1) begin
            NS = S3;
            mstring5Q[i5] = 1;
            end else begin
            NS = S2;
            mstring5Q[i5] = 0;
         end
        end
           
        end
    S2: begin //the third state

    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
    if(option1 < option2) begin
        NS = S0;
        mstring5Q[i5] = 0;
        numDifs5Q = numDifs5Q + option1;
            end else if(option2 < option1) begin
            NS = S1;
            mstring5Q[i5] = 1;
            numDifs5Q = numDifs5Q + option2;
            end else begin
            other = guess5[mQ];
            mQ = mQ + 1;
            numDifs5Q = numDifs5Q + option1;
                if(other == 1) begin
                NS = S0;
                mstring5Q[i5] = 0;
                end else begin
                NS = S1;
                mstring5Q[i5] = 1;
             end
            end
               end
    S3: begin //the fourth state

for(k = 1; k >= 0; k = k - 1) begin
                option1 += two[k] ^ S1[k];
                end
            for(k = 1; k >= 0; k = k - 1) begin
                option2 += two[k] ^ S2[k];
                end
            if(option1 < option2) begin
            NS = S3;
            mstring5Q[i5] = 1;
            numDifs5Q = numDifs5Q + option1;
            end else if(option2 < option1) begin
            NS = S2;
            mstring5Q[i5] = 0;
            numDifs5Q = numDifs5Q + option2;
            end else begin
            numDifs5Q = numDifs5Q + option1;
            other = guess5[mQ];
            mQ = mQ + 1;
                if(other == 1) begin
                NS = S3;
                mstring5Q[i5] = 1;
                end else begin
                NS = S2;
                mstring5Q[i5] = 0;
             end
            end
               end
     default: begin //default

     end 
endcase

end else if (size == 2'b11) begin
option1 = 0;
option2 = 0;
two = {rstring[(i7*2)+1], rstring[(i7*2)]};
case (CS)
    S0 : begin //the first state

//finds the hamming distance between two different 2 bit strings
    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
        
    //finds the lowest number of difference between the two options
    if(option1 < option2) begin
    NS = S1;
    mstring7Q[i7] = 1;
    numDifs7Q = numDifs7Q + option1;
    end else if(option2 < option1) begin
    NS = S0;
    mstring7Q[i7] = 0;
    numDifs7Q = numDifs7Q + option2;
    end else begin
 
 //if there are ties, go to guess to determine path
    numDifs7Q = numDifs7Q + option1;
    other = guess7[mQ];
    mQ = mQ + 1;
        if(other == 0) begin
        NS = S1;
        mstring7Q[i7] = 1;
        end else begin
        NS = S0;
        mstring7Q[i7] = 0;
     end
    end
    end
    
    //these same notations apply to all the other states
    S1: begin //the second state

        for(k = 1; k >= 0; k = k - 1) begin
            option1 += two[k] ^ S2[k];
            end
        for(k = 1; k >= 0; k = k - 1) begin
            option2 += two[k] ^ S1[k];
            end
        if(option1 < option2) begin
        NS = S3;
        mstring7Q[i7] = 1;
        numDifs7Q = numDifs7Q + option1;
        end else if(option2 < option1) begin
        NS = S2;
        mstring7Q[i7] = 0;
        numDifs7Q = numDifs7Q + option2;
        end else begin
        numDifs7Q = numDifs7Q + option1;
        other = guess7[mQ];
        mQ = mQ + 1;
            if(other == 1) begin
            NS = S3;
            mstring7Q[i7] = 1;
            end else begin
            NS = S2;
            mstring7Q[i7] = 0;
         end
        end
           
        end
    S2: begin //the third state

    for(k = 1; k >= 0; k = k - 1) begin
        option1 += two[k] ^ S3[k];
        end
    for(k = 1; k >= 0; k = k - 1) begin
        option2 += two[k] ^ S0[k];
        end
    if(option1 < option2) begin
        NS = S0;
        mstring7Q[i7] = 0;
        numDifs7Q = numDifs7Q + option1;
            end else if(option2 < option1) begin
            NS = S1;
            mstring7Q[i7] = 1;
            numDifs7Q = numDifs7Q + option2;
            end else begin
            other = guess7[mQ];
            mQ = mQ + 1;
            numDifs7Q = numDifs7Q + option1;
                if(other == 1) begin
                NS = S0;
                mstring7Q[i7] = 0;
                end else begin
                NS = S1;
                mstring7Q[i7] = 1;
             end
            end
               end
    S3: begin //the fourth state

for(k = 1; k >= 0; k = k - 1) begin
                option1 += two[k] ^ S1[k];
                end
            for(k = 1; k >= 0; k = k - 1) begin
                option2 += two[k] ^ S2[k];
                end
            if(option1 < option2) begin
            NS = S3;
            mstring7Q[i7] = 1;
            numDifs7Q = numDifs7Q + option1;
            end else if(option2 < option1) begin
            NS = S2;
            mstring7Q[i7] = 0;
            numDifs7Q = numDifs7Q + option2;
            end else begin
            numDifs7Q = numDifs7Q + option1;
            other = guess7[mQ];
            mQ = mQ + 1;
                if(other == 1) begin
                NS = S3;
                mstring7Q[i7] = 1;
                end else begin
                NS = S2;
                mstring7Q[i7] = 0;
             end
            end
               end
     default: begin //default

     end 
endcase
end
end


endmodule
