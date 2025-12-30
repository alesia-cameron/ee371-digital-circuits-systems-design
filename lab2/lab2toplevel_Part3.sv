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

Description: Task 3 incorporates an IP catalog designed M10K 32x3 dual 
port RAM with separate addresses for reading and writing alongside the 
single-port RAM from Task 2. A Memory Initialization File, ram32x3.mif, 
is created and initialized with integer values. A new top level module, 
task3_toplevel includes Task 2 single port logic alongside the logic for 
the dual port RAM. A new switch, SW9, selects between the two memory 
modules for operation and chooses one. When SW9 = 0, the design utilizes
task 2 memory, writing and reading data from the single-port RAM. 
When SW9= 1, it utilizes Task 3 memory where the dual-port RAM 
(ram32x3port2) allows simultaneous read and write using separate address ports. 
The output data between the two modules (DataTask2Out or DataTask3Out) 
is selected using a MUX and displayed on a seven segment display. 
*/

`timescale 1 ps / 1 ps
module lab2toplevel_Part3(
    input logic [9:0] SW,        
    input [3:0] KEY, //active low
	 output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
	 input  CLOCK_50
);
    // Internal signals
    logic [4:0] WriteAddress, ReadAddress; //bits A4 A3 A2 A1 A0 values 0-31
    logic [2:0] DataIn, DataTask2Out,DataTask3Out, DataSelected;
    logic Write, Reset, Task3True;
    logic [4:0] Counter; //counter for address cycling thru addresses
    
    //Synchronized signals for metastability
    logic [9:0] SW_Sync, SW_Stable;
    logic [3:0] KEY_Sync, KEY_Stable;
	 
	//2-stage input synchronization
   //Metastability
    always_ff @(posedge CLOCK_50) begin
        //Initial synchronization
        SW_Sync <= SW;
        KEY_Sync <= KEY;
        
        //Stable outputs
        SW_Stable <= SW_Sync;
        KEY_Stable <= KEY_Sync;
    end
	 
    //switch and key inputs - use stable synchronized signals 
    assign WriteAddress = SW_Stable[8:4];     
    assign DataIn = SW_Stable[3:1];    
    assign Write = SW_Stable[0];  // Write when key is pressed (active low)
    assign Task3True = SW_Stable[9];
    assign ReadAddress = Counter;
	assign Reset = ~KEY_Stable[3];
	 
	 //clock divider that creates 1-sec pulse from 50 MHz clock
    logic [25:0] secondCount; //counter counts from 0 to 50M
    parameter ONE_SECOND = 26'd50000000; // is 50MHz using our clock
    
    always_ff @(posedge CLOCK_50) begin
        if (Reset) begin
            Counter <= 5'b0; //=0
            secondCount <= 26'b0; //=0
        end else begin
            if (secondCount == ONE_SECOND) begin //50M cycles = 1 sec thus weve reached 1 sec
                secondCount <= 0; //reset back to 0
                Counter <= Counter + 1; //incrementing address
            end else begin
                secondCount <= secondCount + 1; //do the counting
            end
        end
    end
	 
	 //Select Data for output between Task 2 & Task 3 
    assign DataSelected = (Task3True) ? DataTask3Out : DataTask2Out; //If DataSelected is true
	 
	 //Instantiation task2 multi-dim array
    task2 task2_instantiation (
        .Address(WriteAddress),
        .CLK(CLOCK_50), 
        .DataIn(DataIn),
        .Write(SW_Stable[0] & ~Task3True), 
        .DataOut(DataTask2Out)
    );
    
	 //Instantiation task3 
    ram32x3port2 task3_instantiation (
        .clock(CLOCK_50),
        .wren(Write & Task3True),
        .data(DataIn),
        .wraddress(WriteAddress),
        .rdaddress(ReadAddress),
        .q(DataTask3Out)
    ); 
	 
	seg7 seg7HEX5 (.hex({3'b000, WriteAddress[4]}), .leds(HEX5)); // high digit 0 or 1 and pads w zero's bc address is not [7:0]
	seg7 seg7HEX4 (.hex(WriteAddress[3:0]), .leds(HEX4));
	seg7 seg7HEX1 (.hex(DataIn), .leds(HEX1));
	seg7 seg7HEX0 (.hex({1'b0, DataSelected}), .leds(HEX0));
	
	/* Use a counter to cycle through read addresses
	Display (in hex) the read address on HEX3–HEX2 and the 3-bit word content on HEX0 */
	seg7 seg7HEX3 (.hex({3'b000, ReadAddress[4]}), .leds(HEX3)); //correct
    seg7 seg7HEX2 (.hex(ReadAddress[3:0]), .leds(HEX2)); //correct
endmodule 
