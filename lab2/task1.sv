//Alesia Cameron 
//ID 2050790
//EE 371 Lab2
//Oct 10, 2025

/*
Module interfaces with 32x3bit RAM for read & write operations  
Connects signals to the internal RAM module

Ports: 
Input:
Address [4:0] – 5-bit address input specifying the memory  
CLK – Clock 
DataIn [2:0] 3-bit input data to be written to RAM  
Write Control signal when 1, data is written to RAM when 0, data is read from RAM  
Output:
DataOut [2:0] 3-bit output data read from RAM  

Connections:  
Connects to module ram32x3 (named ‘instantiation’), which implements the actual memory storage.  
*/

`timescale 1 ps / 1 ps

module task1 (
 	input	logic [4:0]  Address,
	input	logic CLK,
	input	logic [2:0]  DataIn,
	input	logic  Write,
	output logic [2:0]  DataOut
);

//instantiate memory

ram32x3 instantiation (
      .address(Address[4:0]),
		.clock(CLK),
		.data(DataIn[2:0]),
		.wren(Write),
		.q(DataOut[2:0])
    );
endmodule //task1




//=====================Test Bench=======================
/*
module task1_tb();
    logic [4:0] Address;
    logic CLK;
    logic [2:0] DataIn;
    logic Write;
    logic [2:0] DataOut;

	 task1 dut (
        .Address(Address),
        .CLK(clk),
        .DataIn(DataIn),
        .Write(Write),
        .DataOut(DataOut)
    );

     // Clock generation
   parameter CLOCK_PERIOD = 10;	//Clock generation 	
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	

   initial begin
	//Initialize vars
		Write = 0;
      Address = 0;
      DataIn = 0;
		  
		@(posedge clk)
		@(posedge clk)

      //Write data 3 to address 1
      @(posedge clk)
		Address = 1;
      DataIn = 4;
      Write = 1;
	   @(posedge clk)
      Write = 0;

      //Wait then read 
      @(posedge clk)
	   Address = 1;

      //write val to different address
		@(posedge clk)
      Address = 2;
      DataIn = 4;
      Write = 1;
		@(posedge clk)
		Write = 0;

      //read
		@(posedge clk)
		Address = 2;
		
      $stop;
    end

endmodule
*/