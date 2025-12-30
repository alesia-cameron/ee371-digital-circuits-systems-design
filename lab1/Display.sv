/*
EE371 - Autumn 2025

Description: Module takes a 5-bit car count input and outputs 
corresponding patterns to six seven-segment displays. It shows “CLEAR 0” when empty, “FULL” when the count reaches 16, and the numeric value (1–15) otherwise.
*/

module Display (
    input  logic [4:0] count,
    output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);
    always_comb begin
        // Default blank
        HEX5 = 7'b1111111;
        HEX4 = 7'b1111111;
        HEX3 = 7'b1111111;
        HEX2 = 7'b1111111;
        HEX1 = 7'b1111111;
        HEX0 = 7'b1111111;

        if (count <= 0) begin
            // "CLEAR 0"
            HEX5 = 7'b1000110;  // C
            HEX4 = 7'b1000111;  // L
            HEX3 = 7'b0000110;  // E
            HEX2 = 7'b0001000;  // A
            HEX1 = 7'b1001110;  // R 
            HEX0 = 7'b1000000;  // 0
        end
        else if (count >= 16) begin
            // "FULL"
            HEX5 = 7'b0001110;  // F
            HEX4 = 7'b1000001;  // U
            HEX3 = 7'b1000111;  // L
            HEX2 = 7'b1000111;  // L
        end
        else begin
            // 1–15
            // Tens digit
            if (count >= 10)
                HEX1 = 7'b1111001; // '1'
            // Ones digit
            case (count % 10) //modulous operator to get one's digit
                0: HEX0 = 7'b1000000;
                1: HEX0 = 7'b1111001;
                2: HEX0 = 7'b0100100;
                3: HEX0 = 7'b0110000;
                4: HEX0 = 7'b0011001;
                5: HEX0 = 7'b0010010;
                6: HEX0 = 7'b0000010;
                7: HEX0 = 7'b1111000;
                8: HEX0 = 7'b0000000;
                9: HEX0 = 7'b0010000;
            endcase
        end //else
    end //always
endmodule



//=====================Test Bench=======================
module Display_tb();

   // Declare signals
   logic [4:0] count;
   logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

   // Instantiate the Device Under Test (DUT)
   Display dut (
      .count(count),
      .HEX5(HEX5),
      .HEX4(HEX4),
      .HEX3(HEX3),
      .HEX2(HEX2),
      .HEX1(HEX1),
      .HEX0(HEX0)
   );

	
   // Test sequence
   initial begin
      // Count up from 0 to 16
      for (int i = 0; i <= 16; i++) begin
         count = i;
         #10;  // Wait 10 time units
      end

      // Count down from 16 to 0
      for (int i = 16; i >= 0; i--) begin
         count = i;
         #10;  // Wait 10 time units
      end

      $stop;  // End simulation
   end

endmodule // Display_tb

