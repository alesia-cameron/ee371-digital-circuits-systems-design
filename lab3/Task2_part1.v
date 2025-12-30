//EE 371 LAB 3 
//AU 25

//updated for integration with Task 2

/*
Description: Task2_part2 reads audio tone data stored in ROM 
initialized from MIF file and continuously outputs both left and right 
audio channels. Cycles through 48,000 samples in ROM, sending each sample 
to writedata_left and writedata_right sequentially. 
ROM address stored internally in 16-bit register increments when write_ready 
goes high. When address reaches last sample, 
wraps back to zero.

Inputs:
CLOCK_50 system clock
write_ready high when ready to output next sample
reset active-high reset signal

Outputs:
writedata_left 24-bit audio output left channel
writedata_right 24-bit audio output right channel 
*/

//Top level for part 1 Task 2
module Task2_part1 (CLOCK_50, reset, read_ready, write_ready, writedata_left, 
writedata_right, readdata_left, readdata_right, read, write);

/////////////////Port list /////////////////////
	input CLOCK_50;
    input reset;
    input read_ready; //was local wire but now need for top module
    input write_ready; //was local wire but now need for top module
    input [23:0] readdata_left, readdata_right;
    output [23:0] writedata_left, writedata_right;
	output read, write;
	
	assign writedata_left = readdata_left; //pass from mic to speaker
	assign writedata_right = readdata_right;
	assign read = read_ready & write_ready;	//the data is only valid when the read_ready signal is asserted
	assign write = write_ready & read_ready; 
endmodule




