//EE 371 Lab2
//Oct 10, 2025

/*
Input:
Reset
clk 1-bit clock signal 
Description: A basic counter cycles through the various addresses 
of the separate modules, displayed on HEX 2 & 3, and displays the data 
tstored at those locations on HEX0. The counter uses a custom made clock
divider to slow down counting: a 26bit register (secondCount) increments
at every clock edge, and when it reaches the set value (ONE_SECOND = 100),
it resets to zero and increments the counter by one. 
This makes the counter increase much slower, 1HZ, than the actual 
clock and allows for address output to be displayed every second. 
When reset is high, both values go to zero. Write enable, address and
data input are controlled using the same switches as task 2, KEY 3 is
used as a reset. A synchronous 50 MHz clock was used for both memories 
and replaces KEY0 logic from Task2. 
*/

//vsim work.task1_tb -L altera_mf_ver -L lpm_ver -L work //to run on modlesim

`timescale 1ns/1ps
module counter_tb;

    logic CLOCK_50;
    logic Reset;
    logic [4:0] Counter;

    counterTest dut (
        .CLOCK_50(CLOCK_50),
        .Reset(Reset),
        .Counter(Counter)
    );

    initial CLOCK_50 = 0;
    always #10 CLOCK_50 = ~CLOCK_50;  


    initial begin
    Reset = 1;
    @(posedge CLOCK_50);
    
    //Release reset counter run
    Reset = 0;
    $display("Reset released at time %0t", $time);
    
    //Counter for 50 clock cycles
    repeat(50) @(posedge CLOCK_50);
    
    $display("Test complete - saw %0d clock cycles", 50);
    $stop;
end
endmodule



module counterTest(
    input logic CLOCK_50,
    input logic Reset,
    output logic [4:0] Counter
);
 
    logic [25:0] secondCount;
    parameter ONE_SECOND = 26'd100;  
    
    always_ff @(posedge CLOCK_50) begin
        if (Reset) begin
            Counter <= 5'b0;
            secondCount <= 26'b0;
        end else begin
            if (secondCount == ONE_SECOND) begin
                secondCount <= 0;
                Counter <= Counter + 1;
            end else begin
                secondCount <= secondCount + 1;
            end
        end
    end

endmodule
