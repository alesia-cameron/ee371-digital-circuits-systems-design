/*
EE371 - Autumn 2025

Description: Top levellogic module connected directly to DE1_SOC hardwareinputs, 
integrates the car detection FSM, counter, and display modules 
to track parking lot occupancy, drives LEDs to show sensor states, 
and outputs the current car count to seven-segment display.
*/

module parkingLotOccupancy_TopLevel (
    input  logic clk,          // clock signal
    input  logic reset,        // reset system
    input  logic OuterSensor,  // switch aka outer sensor
    input  logic InnerSensor,  // switch aka inner sensor
    output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, // seven-segment display
    output logic ledOne,       // LED shows outer switch state
    output logic ledTwo        // LED shows inner switch state
);

    // internal signals
    logic incr, decr;
    logic [4:0] count;

    // FSM or detection logic to decide incr/decr
	 // Instantiate CarDetection FSM
	 
    CarDetection carDetect_inst (
        .clk(clk),
        .reset(reset),
        .OuterSensor(OuterSensor),
        .InnerSensor(InnerSensor),
        .incr(incr),
        .decr(decr)
    );
	 

    // Counter module
    Counter counter_inst (
        .clk(clk),
        .reset(reset),
        .incr(incr),
        .decr(decr),
        .count(count)
    );

    // Display module
    Display display_inst (
        .count(count),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    // LEDs light up to show sensor activated
    assign ledOne = OuterSensor;  // ON if outer switch = 1
    assign ledTwo = InnerSensor;  // ON if inner switch = 1
	 
endmodule // parkingLotOccupancy_TopLevel


//=====================Test Bench=======================
module parkingLotOccupancy_TopLevel_tb();
	 // Signals
    logic clk, reset;
    logic OuterSensor, InnerSensor;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic ledOne, ledTwo;
    //logic incr, decr;
    //logic [4:0] count;

    // Instantiate top-level module
     parkingLotOccupancy_TopLevel dut (
        .clk(clk),
        .reset(reset),
        .OuterSensor(OuterSensor),
        .InnerSensor(InnerSensor),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0),
        .ledOne(ledOne),
        .ledTwo(ledTwo)
    );

    // Clock generation
   parameter CLOCK_PERIOD = 10;	//Clock generation 	
	
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    // Test sequence
    initial begin
    // Initialize signals
        reset = 0;
        OuterSensor = 0;
        InnerSensor = 0;
        @(posedge clk);
		  reset = 1;
        @(posedge clk); 
        reset = 0;

        // --- Car entering sequence ---
        repeat (2) begin
		  @(posedge clk); OuterSensor = 1; InnerSensor = 0; // Outer triggered
		  @(posedge clk); OuterSensor = 1; InnerSensor = 1; // Both triggered
		  @(posedge clk); OuterSensor = 0; InnerSensor = 1; // Outer off
		  @(posedge clk); OuterSensor = 0; InnerSensor = 0; // Both off (incr pulse)
		  end
        // --- Car exiting sequence ---
		  repeat (3) begin
        @(posedge clk); OuterSensor = 0; InnerSensor = 1; // Inner triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 1; // Both triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 0; // Inner off
        @(posedge clk); OuterSensor = 0; InnerSensor = 0; // Both off (decr pulse)
		  end
		  
        // --- Car entering then reversing ---
        @(posedge clk); OuterSensor = 1; InnerSensor = 0;
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;
        @(posedge clk); OuterSensor = 1; InnerSensor = 0;
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;

        // --- Car exiting then reversing ---
        @(posedge clk); OuterSensor = 0; InnerSensor = 1;
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;
        @(posedge clk); OuterSensor = 0; InnerSensor = 1;
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;

        // --- Glitch inputs ---
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;

        $stop;
    end
endmodule
