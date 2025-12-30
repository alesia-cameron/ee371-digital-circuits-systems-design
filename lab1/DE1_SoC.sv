/* Top-level module for LandsLand hardware connections to implement the parking lot system.*/

module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, V_GPIO);
	inout  logic [35:0] V_GPIO;	// expansion header 0 (LabsLand board)
	input  logic  CLOCK_50;	// 50MHz clock
	assign clk = CLOCK_50;
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// active low
	
   // ========= SENSOR INPUTS =========
   // Use GPIO pins for sensors (switches, photo sensors, etc.)
   logic OuterSensor, InnerSensor, reset;
	
	// Assign switches to GPIO pins -- For LabsLand DE1, you can map these to specific GPIOs.
   assign OuterSensor = V_GPIO[28]; //sensor switch 
   assign InnerSensor = V_GPIO[30]; //sensor switch  
   assign reset       = V_GPIO[29];  //reset switch 

   // ========= LED OUTPUTS =========
   logic ledOne, ledTwo;

   // LEDs driven by FSM outputs
   assign V_GPIO[33] = ledOne; // external LED 1
   assign V_GPIO[35] = ledTwo; // external LED 2
	
	
	// ========= INSTANTIATE PARKING LOT TOP MODULE =========
   parkingLotOccupancy_TopLevel parkingLot_inst (
        .clk         (CLOCK_50),
        .reset       (reset),
        .OuterSensor (OuterSensor),
        .InnerSensor (InnerSensor),
        .HEX5        (HEX5),
        .HEX4        (HEX4),
        .HEX3        (HEX3),
        .HEX2        (HEX2),
        .HEX1        (HEX1),
        .HEX0        (HEX0),
        .ledOne      (ledOne),  // internal logic → GPIO[2]
        .ledTwo      (ledTwo)   // internal logic → GPIO[3]
   );

endmodule  // DE1_SoC