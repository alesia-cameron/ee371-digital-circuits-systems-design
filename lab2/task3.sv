//EE 371 Lab2
//Oct 10, 2025

/*
Input:
Address [4:0] 2 5-bit address line connected to task1 module  
clk 1-bit clock signal 
DataIn [2:0] 3-bit data input 
Write  1-bit control signal (1 = write, 0 = read)  

Output:
DataOut [2:0] 3-bit data output 
*/ 

`timescale 1 ps / 1 ps
module task3(
    input logic [9:0] SW,        
    input [3:0] KEY, //active low
	 output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
	 input  CLOCK_50
);
    //internal signals
    logic [4:0] WriteAddress, ReadAddress; //bits A4 A3 A2 A1 A0 values 0-31
    logic [2:0] DataIn,DataOut;
    logic Write, Reset;
	 
    //switch and key inputs - use stable synchronized signals 
    assign WriteAddress = SW[8:4];     
    assign DataIn = SW[3:1];    
    assign Write = SW[0] & ~KEY[0];  //Write when key is pressed (active low)
	 assign Reset = ~KEY[3];
    assign ReadAddress = SW[8:4]; 

	 //instantiation task3 
    ram32x3port2 task3_solotest (
        .clock(CLOCK_50),
        .wren(Write),
        .data(DataIn),
        .wraddress(WriteAddress),
        .rdaddress(ReadAddress),
        .q(DataOut)
    ); 

	seg7 seg7HEX5 (.hex({3'b000, WriteAddress[4]}), .leds(HEX5)); // high digit 0 or 1 and pads w zero's bc address is not [7:0]
	seg7 seg7HEX4 (.hex(WriteAddress[3:0]), .leds(HEX4));
	seg7 seg7HEX1 (.hex(DataIn), .leds(HEX1));
	seg7 seg7HEX0 (.hex({1'b0, DataOut}), .leds(HEX0));
	seg7 seg7HEX3 (.hex({3'b000, ReadAddress[4]}), .leds(HEX3));
   seg7 seg7HEX2 (.hex(ReadAddress[3:0]), .leds(HEX2)); 
	
endmodule //task3



//=====================Test Bench=======================
module task3_readtest_tb;
    logic CLOCK_50;
    logic [2:0] data;
    logic [4:0] rdaddress;
    logic [4:0] wraddress;
    logic wren;
    logic [2:0] DataOut;

    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    //instantiation of RAM
    ram32x3port2 dut (
        .clock(CLOCK_50),
        .data(data),
        .rdaddress(rdaddress),
        .wraddress(wraddress),
        .wren(wren),
        .q(DataOut)
    );

    initial begin
        data = 3'b0;
        rdaddress = 5'b0;
        wraddress = 5'b0;
        wren = 1'b0;  // No writing
        
        $display("reading MIF");
        
        //reading addresses 1 through 10
        for (int i = 1; i <= 10; i++) begin
            rdaddress = i;
            #100;
            $display("Addr %2d: DataOut = %b (%0d)", i, DataOut, DataOut);
        end
        
        $display("test complete");
        $stop;
    end
endmodule

