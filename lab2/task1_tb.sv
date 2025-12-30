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
module task1_tb();
    logic [4:0] Address;
    logic clk;
    logic [2:0] DataIn;
    logic Write;
    logic [2:0] DataOut;
	 logic [2:0] DataOut2; //to differentiate multidimen array

	 task1 dut1 (
        .Address(Address),
        .CLK(clk),
        .DataIn(DataIn),
        .Write(Write),
        .DataOut(DataOut)
    );
	 
	 task2 dut2 (
        .Address(Address),
        .CLK(clk),
        .DataIn(DataIn),
        .Write(Write),
        .DataOut(DataOut2)
    );

   //Clock generation
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

      //Write data 4 to address 1
      @(posedge clk)
	  Address = 1;
      DataIn = 4;
      Write = 1;
	  @(posedge clk)
      Write = 0;

      //Wait then read 
      @(posedge clk)
	   Address = 1;
		
	  //try to rewrite with write being 0, new data 8 address still 1
	  @(posedge clk)
	  Address = 1;
      DataIn = 8;	

      //write val to different address
	  @(posedge clk)
      Address = 2;
      DataIn =5;
      Write = 1;
	  @(posedge clk)
	  Write = 0;

       //read
	   @(posedge clk)
	   Address = 2;
		
	   @(posedge clk)
	   @(posedge clk)
		
      $stop;
    end

endmodule

