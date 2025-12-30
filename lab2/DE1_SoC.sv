//EE 371 Lab2
//Oct 10, 2025

/* Top-level module for LandsLand hardware connections */

module DE1_SoC (CLOCK_50, SW, KEY, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	input  logic CLOCK_50;	// 50MHz clock
	input  logic [9:0] SW;          
    input  logic [3:0] KEY; 
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// active low

    //internal clock signal
    logic clk;
    assign clk = CLOCK_50;

    //========= INSTANTIATE TOP MODULE =========
	 lab2toplevel_Part3 top_inst (
          .SW(SW),                     
          .KEY(KEY),   
		  .CLOCK_50(CLOCK_50),        
		  .HEX5(HEX5),
		  .HEX4(HEX4),
		  .HEX3(HEX3),
		  .HEX2(HEX2),
		  .HEX1(HEX1),
		  .HEX0(HEX0)
    ); 
endmodule  // DE1_SoC

