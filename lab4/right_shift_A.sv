//EE 371 Lab4
//Nov 1, 2025

/*
Module implements an 8-bit right shift register that can either 
load a new value or shift its current value right by one bit each 
clock cycle. When the load signal is high, the input value is loaded 
into the register. Otherwise, the register shifts its contents right, 
inserting a 0 into the most significant bit.

Input:
InputToLoad [7:0] 8-bit data input to be loaded into the register
LoadNewVal 1-bit control signal that triggers loading when high
CLOCK_50 1-bit 50 MHz clock signal
Output:
Result [7:0] 8-bit output representing either the loaded value or the right-shifted value

Testbench loads two 8bit values into shift register
then lets circuit shift them right over 
several clock cycles to verify correct operation. 
Uses50 MHz clock and toggles load signal to test loading and shift behavior

*/
 
/////////////////Right Shift A Module///////////////////////////
module right_shift_A (
    input  logic [7:0] InputToLoad, // data to load
    input  logic LoadNewVal, // load trigger
    input  logic CLOCK_50, // clock input
    output logic [7:0] Result // shifted result
);
    always_ff @(posedge CLOCK_50) begin
        if (LoadNewVal)
            Result <= InputToLoad; //load value
        else
            Result <= {1'b0, Result[7:1]}; //shift right, insert 0 MSB
    end
endmodule



///////////////////////////////////////////////////////
module right_shift_A_tb;

  logic CLOCK_50;
  logic [7:0] InputToLoad;
  logic LoadNewVal;
  logic [7:0] Result;

  right_shift_A dut (
    .CLOCK_50(CLOCK_50),
    .InputToLoad(InputToLoad),
    .LoadNewVal(LoadNewVal),
    .Result(Result)
  );

  //clock
  initial begin
    CLOCK_50 = 0;
    forever #10 CLOCK_50 = ~CLOCK_50; 
  end

  initial begin
    InputToLoad = 8'b00000000;
    LoadNewVal = 0;

    @(posedge CLOCK_50);

    //first value
    InputToLoad = 8'b10101010;
    LoadNewVal = 1;
    @(posedge CLOCK_50);
    LoadNewVal = 0; //release 

    //wait and observe shifts
    repeat(8) @(posedge CLOCK_50);

    //second test value
    InputToLoad = 8'b11001100;
    LoadNewVal = 1;
    @(posedge CLOCK_50);
    LoadNewVal = 0;

    repeat(8) @(posedge CLOCK_50);
	 
    $stop;
  end

endmodule




