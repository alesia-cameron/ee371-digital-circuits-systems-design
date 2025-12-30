//EE 371 Lab4
//Nov 1, 2025

/*
Testbench module simulates bit_counting_algorithm by providing clock, 
switches, key inputs while monitoring the outputs. 
Generates 50 MHz clock, applies initial vals to switches and keys, 
triggers reset and start sequence, then repeatedly displays
internal register A, counted result, the done signal on LEDR[9] 
at each clock edge. Allows observation of right-shifting behavior in simulation

Input:
CLOCK_50 1-bit clock signal used to drive the DUT
SW [7:0] 8-bit switch input to simulate user input
KEY [3:0] 4-bit control keys, KEY[0] is reset, KEY[3] is start

Output:
HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 [6:0] Seven-segment display outputs 
LEDR [9:0] 10 LED outputs from DUT, LEDR[9] indicates done signal
*/

///////////////////Test Bench////////////////////////////////
module bit_counting_tb;

  //inputs
  logic CLOCK_50;
  logic [7:0] SW;
  logic [3:0] KEY;
  //outputs
  logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
  logic [9:0] LEDR;

  //instantiate dut
  bit_counting_algorithm dut (
    .CLOCK_50(CLOCK_50),
    .SW(SW),
    .KEY(KEY),
    .HEX5(HEX5),
    .HEX4(HEX4),
    .HEX3(HEX3),
    .HEX2(HEX2),
    .HEX1(HEX1),
    .HEX0(HEX0),
    .LEDR(LEDR)
  );

  //clock generation
  initial begin
    CLOCK_50 = 0;
    forever #10 CLOCK_50 = ~CLOCK_50; // 50 MHz clock → 20ns period
  end

  initial begin
    SW = 8'b10101100;
    KEY = 4'b1111; //all keys released active-low
	 
	 //$display("Time\tSW\tKEY\tA\tResult\tLEDR[9]");
    //$monitor("%0t\t%b\t%b\t%b\t%0d\t%b", $time, SW, KEY, dut.A, dut.result, LEDR[9]);

    @(posedge CLOCK_50);
    KEY[0] = 0; //reset
    @(posedge CLOCK_50);
    KEY[0] = 1; //release reset

    @(posedge CLOCK_50);
    KEY[3] = 0; // press start active-low
    @(posedge CLOCK_50);
    KEY[3] = 1; //release start

    // Wait to observe operation
    repeat(50) @(posedge CLOCK_50);
	 
	 //second test value
    SW = 8'b11010010; //new val
    @(posedge CLOCK_50);
    KEY[0] = 0; // reset
    @(posedge CLOCK_50);
    KEY[0] = 1; // release reset

    @(posedge CLOCK_50);
    KEY[3] = 0; // press start
    @(posedge CLOCK_50);
    KEY[3] = 1; // release start

    // Wait to observe operation
    repeat(50) @(posedge CLOCK_50);
	 
    $stop;
  end

endmodule
