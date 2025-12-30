/*
EE371 - Autumn 2025

Description: this module tracks number of cars in the parking lot by incrementing 
or decrementing the count based on the incr and decr control signals, 
count stays within valid range of 0 to 16.
*/

module Counter(
    input  logic clk,        // clock signal
    input  logic reset,      // reset to 0
    input  logic incr,       // increment 
    input  logic decr,       // decrement 
    output logic [4:0] count // current car count (0–16)
);

    always_ff @(posedge clk) begin
        if (reset)
            count <= 0;
        else begin
            if (incr && count < 16)
                count <= count + 1;
            else if (decr && count > 0)
                count <= count - 1;
        end
    end
endmodule // Counter

//=====================Test Bench=======================
module Counter_tb();
    logic clk, reset;
    logic incr, decr;
    logic [4:0] count;

    // Instantiate the Counter DUT
    Counter dut (
        .clk(clk),
        .reset(reset),
        .incr(incr),
        .decr(decr),
        .count(count)
    );

    // Clock generation
   parameter CLOCK_PERIOD = 10;	//Clock generation 	
	
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    // Test sequence
    initial begin
        reset = 1; incr = 0; decr = 0;
		  @(posedge clk)
        @(posedge clk) reset = 0;
		  
        // --- Count Up Loop (0 to 17) ---
        $display("Counting Up:");
        repeat (18) begin
            incr = 1; decr = 0;
            @(posedge clk);
				@(posedge clk);
            $display("count = %0d", count);
        end
			  
        // --- Count Down Loop (16 to -1) ---
        $display("\nCounting Down:");
        repeat (18) begin
            incr = 0; decr = 1;
            @(posedge clk);
				@(posedge clk);
            $display("count = %0d", count);
        end

        $stop;
    end
endmodule
