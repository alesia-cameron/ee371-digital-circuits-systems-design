//EE 371 Lab4
//Nov 1, 2025

/*
Testbench for lab_top. KEY0 to resets the system, both tasks tested one after the other
first, it selects Task 1 the bit counte) by setting SW[9] to 0, 
sets the switches to 10101100 (which contains 4 ones), 
pulses KEY3 to start counting. The bit counter display 4 on HEX0

After letting it run for a short time it switches to Task 2 the binary search 
by setting SW[9] to 1, sets the search value to 10, and pulses KEY3 to trigger 
search. Simulation continues for enough clock cycles to observe outputs on 
HEX display and LEDR */

`timescale 1ns/1ps
module lab_top_tb;

    logic CLOCK_50;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;

    lab_top dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .HEX0(HEX0),
       // .HEX1(HEX1),
       // .HEX2(HEX2),
       // .HEX3(HEX3),
       // .HEX4(HEX4),
       // .HEX5(HEX5),
        .LEDR(LEDR)
    );

   initial begin
		 CLOCK_50 = 0;
		 forever #10 CLOCK_50 = ~CLOCK_50; 
	end

    initial begin
        KEY = 4'b1111;
        SW = 10'b0;
        repeat (5) @(posedge CLOCK_50);

        KEY[0] = 0;
        @(posedge CLOCK_50);
        KEY[0] = 1;
        @(posedge CLOCK_50);

        SW[9] = 0;
        SW[7:0] = 8'b10101100;
        KEY[3] = 0;
        @(posedge CLOCK_50);
        KEY[3] = 1;
        repeat (50) @(posedge CLOCK_50);

        SW[9] = 1;
        SW[7:0] = 8'd10;
        KEY[3] = 0;
        @(posedge CLOCK_50);
        KEY[3] = 1;
        repeat (200) @(posedge CLOCK_50);

        $stop;
    end
	
endmodule
