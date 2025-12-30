//EE 371 Lab2
//Oct 10, 2025

/*
Implements a 32x3-bit memory using a multidimensional array.
The design mimics the behavior of Task 1’s RAM module (ram32x3) but
uses native SystemVerilog constructs instead of IP Catalog memory.

Input:
Address [4:0] 5-bit address input
CLK Clock input
DataIn [2:0] 3-bit input data to write into memory
Write Control signal 1 = write 0 = read

Output:
DataOut [2:0]3-bit data output coming from memory
*/


`timescale 1 ps / 1 ps
module task2 (
    input logic [4:0] Address,
    input logic CLK,
    input logic [2:0] DataIn,
    input logic Write,
    output logic [2:0] DataOut
);
    //memory array
    logic [2:0] memory_array [31:0];
	 
	 //use flipflop
    always_ff @(posedge CLK) begin
		 if (Write) begin
			  memory_array[Address] <= DataIn;  
		 end
	end
	
	always_comb begin
		DataOut <= memory_array[Address];
	end
endmodule
