//EE 371 Lab2
//Oct 10, 2025

/*
Input:
Address [4:0] 5-bit address line connected to task1 module  
clk 1-bit clock signal 
DataIn [2:0] 3-bit data input 
Write  1-bit control signal (1 = write, 0 = read)  

Output:
DataOut [2:0] 3-bit data output 
*/

`timescale 1 ps / 1 ps

module lab2toplevel_Part2(
    input logic [8:0] SW,        
    input [3:0] KEY, 
	 output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
 
);

	 //internal signals
    logic [4:0] Address; //bits A4 A3 A2 A1 A0 values 0-31
    logic [2:0] DataIn;
    logic Write;
    logic [2:0] DataOut;
	 
	 assign HEX2 = 7'b1111111; // off
    assign HEX3 = 7'b1111111; // off

    //Switch and key inputs
    assign Address = SW[8:4];   
    assign DataIn = SW[3:1];    
    assign Write = SW[0];    
	 
	 //Instantiation task2 multi-dim array
    task2 task2_instantiation (
        .Address(Address),
        .CLK(KEY[0]),
        .DataIn(DataIn),
        .Write(Write),
        .DataOut(DataOut)
    );
    
	//Address is 5 bits but the hex displays take 4 bits each so we separate
	/*seg7 takes a 4bit input logic [3:0] hex and shows 0–F in hex (doesnt show the #s, 15 = 0F not 15)
	each HEX shows value 0 to 15 -- the HEX cant show vals 16 to 31
	5bit number can be displayed as two hex digits, high digit upper bit
	Address vals 0 to 31 only MSB contributes to the first hex digit
	so upper 1 or 2 bits goes to HEX5
	the low digit will be the lower 4 bits so address[3:0] goes to HEX4
	*/
	seg7 seg7HEX5 (.hex({3'b000, Address[4]}), .leds(HEX5)); // high digit 0 or 1 and pads w zero's bc address is not [7:0]
	seg7 seg7HEX4 (.hex(Address[3:0]), .leds(HEX4));
	seg7 seg7HEX1 (.hex(DataIn), .leds(HEX1));
	seg7 seg7HEX0 (.hex(DataOut), .leds(HEX0));
endmodule //lab2toplevel
	 
/* Display
HEX5 HEX4 Address 
HEX1 DataIn
HEX0 DataOut
*/ 
