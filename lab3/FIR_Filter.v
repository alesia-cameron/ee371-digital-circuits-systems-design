//EE 371 LAB 3 
//AU 25

/*
Inputs:
clk 
reset resets accumulator, FIFO, count, output to zero
isValid enable when dataIn contains new valid sample 
dataIn 24bit input data for smoothing

Outputs:
dataOut 24bit filtered output, moving average of recent input samples

FIR_Filter module is adigital filter that smooths noisy input signal 
by averaging sliding window of recent samples. Takes an 24 bits data 
on dataIn when isValid signal is high, then scales it down by factor of 2^n 
using arithmetic right shift, then pushes it into a FIFO buffer 
that stores the most recent samples. 
The oldest sample is subtracted from the sum stored in accumulator, 
which keeps a continuous sum of the last 256 samples if n=8. 
This implements moving average filter and smoothes fluctuations in input 
while preserving the general trend ofsignal. 
Module pre-fills accumulator and FIFO until enough samples collected, 
then continuously updates dataOut with averaged val 
Reset can accumulator, FIFO, and output to restart. larger n means more smoothing num samples and sample width 
*/

module FIR_Filter (
    input clk, //cant use logic bc .v not .sv 
    input reset,
    input isValid, //enable for 
    input signed [23:0] dataIn, //raw data input - noisy
    output reg signed [23:0] dataOut //averaged data out - smooth
);
	
///////////Constants declared/////////////////////////////////
    parameter n = 4;  //divide by 2^n and we want 8
    parameter w = 24; //data width
	 
///////////Local logic list ///////////////////////////////////
	 wire signed [23:0] divided; //cant use logic bc v not sv
	 assign divided = dataIn >>> n;//first divide each noisy input sample by n	 //assign divided = {{n{dataIn[w-1]}}, dataIn[w-1:n]};
	 
///////////Fifo signals/////////////////////////////////////////
    wire signed [23:0] out;
    wire empty, full;
    
    //fifo write when valid, read after prefill
    wire fifo_write, fifo_read;
    assign fifo_write = isValid;
    assign fifo_read = isValid & prefill;
	 
////////FIFO Instantiation///////////////////////////////////////
		//#(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
		//push divided into FIFO, pop out oldest value from fifo into out
		//do buffer length of 256, sample is 24 bits long
		fifo #(.DATA_WIDTH(24), .ADDR_WIDTH(8)) fifo_inst( //not 2^8, 256
				  .clk(clk),
				  .reset(reset),
				  .rd(fifo_read),
				  .wr(fifo_write),
				  .empty(empty),
				  .full(full),
				  .w_data(divided),
				  .r_data(out) //oldest sample to subract when new sample comes in
			 );
	
///////////Accumulator//////////////////////////////////////////////
    reg signed [23+n:0] accumulator; //running sum should be bigger than 24 bits, creates registers
    reg [4:0] count;//# of samples, < n
    wire prefill;
    assign prefill = (count == (2**n));

////////////FSM Logic////////////////////////////////////////////////
    always @(posedge clk) 
	 begin
        if (reset) 
		  begin
            accumulator <= 0;			
				count <= 0;
				dataOut <= 0;
        end 
		  
		  else if (isValid) 
		  begin //if new data ready to go
            // Increment counter during prefill
            if (!prefill)
                count <= count + 1;
            
            //accumulator
            if (prefill)				
				//add divided sample add old sample multiplied by -1 instead of subtracting
                accumulator <= accumulator + divided + (-out);  ////add new sample and sub oldes sample
            else
                accumulator <= accumulator + divided;              
            
            //averaged result
            dataOut <= accumulator[23+n:n];
        end
    end
endmodule
