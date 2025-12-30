/*
EE371 - Autumn 2025

Description: this module is a finite state machine that monitors the outer and inner sensors to generate single-cycle incr or decr pulses when a car enters or exits the parking lot.

*/

module CarDetection (
   input  logic clk, reset,
   input  logic OuterSensor, InnerSensor,
   output logic incr, decr
);
	
	//state declaration
   enum logic [2:0] {
      Idle,
      OuterOn,
      OuterOnInnerOn,
      OuterOffInnerOn,
      InnerOn,
      InnerOnOuterOn,
      InnerOffOuterOn
   } ps, ns;

	
	//flip flop handling next and present state
   always_ff @(posedge clk)
      if (reset) ps <= Idle;
      else       ps <= ns;
		
	//combinational state logic
   always_comb
      case (ps)
         Idle: begin
				 if (InnerSensor == 0 && OuterSensor == 1) ns = OuterOn; 
             else if (InnerSensor == 1 && OuterSensor == 0) ns = InnerOn;
				 else 		ns = Idle;
			end
        
		  OuterOn: begin
				 if (InnerSensor == 1 && OuterSensor == 1) ns = OuterOnInnerOn;
				 else if (InnerSensor == 0 && OuterSensor == 0) ns = Idle;
				 else 		ns = OuterOn;
			end
        
		  OuterOnInnerOn: begin
				 if (InnerSensor == 1 && OuterSensor == 0) ns = OuterOffInnerOn;
             else if (InnerSensor == 0 && OuterSensor == 1) ns = OuterOn;
				 else if (InnerSensor == 0 && OuterSensor == 0) ns = Idle; //cant both be switched at once 
				 else       ns = OuterOnInnerOn; 
			end
        
		  OuterOffInnerOn: begin
				 if (InnerSensor == 0 && OuterSensor == 0) ns = Idle;
				 else if (InnerSensor == 1 && OuterSensor == 1) ns = OuterOnInnerOn;
				 else 		ns =  OuterOffInnerOn;
			end
        
		  InnerOn: begin
				 if (InnerSensor == 1 && OuterSensor == 1) ns = InnerOnOuterOn; 
             else if (InnerSensor == 0 && OuterSensor == 0) ns = Idle;
				 else 		ns = InnerOn;
			end
			
			InnerOnOuterOn: begin
				 if (InnerSensor == 0 && OuterSensor == 1) ns = InnerOffOuterOn;
				 else if (InnerSensor == 1 && OuterSensor == 0) ns =  InnerOn;
				 else if (InnerSensor == 0 && OuterSensor == 0) ns = Idle; //cant both be switched at once 
				 else       ns = InnerOnOuterOn;
			end
			
			InnerOffOuterOn: begin
				 if (InnerSensor == 0 && OuterSensor == 0) ns = Idle;
				 else if (InnerSensor == 1 && OuterSensor == 1) ns = InnerOnOuterOn;
				 else 		ns =  InnerOffOuterOn;
			end
			
      endcase

   always_comb begin
      // Car entering sequence completed
		 incr = 0;
		 decr = 0;
			 
      if (ps == OuterOffInnerOn && ns == Idle)
         incr = 1;

      // Car exiting sequence completed
      else if (ps == InnerOffOuterOn && ns == Idle)
         decr = 1;
			
		else begin
			 incr = 0;
			 decr = 0;
		end
    end
	 
endmodule //CarDetection 



//=====================Test Bench=======================
module CarDetection_tb();
    logic clk, reset;
    logic OuterSensor, InnerSensor;
    logic incr, decr;

    // Instantiate the FSM
    CarDetection dut (
        .clk(clk),
        .reset(reset),
        .OuterSensor(OuterSensor),
        .InnerSensor(InnerSensor),
        .incr(incr),
        .decr(decr)
    );

    // Clock generation
   parameter CLOCK_PERIOD = 10;	//Clock generation 	
	
	initial begin
		clk <= 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

    // Test sequence
    initial begin
        // Initialize
        reset = 0;
        OuterSensor = 0;
        InnerSensor = 0;
		  
		  @(posedge clk);
        @(posedge clk) reset = 1;
		  @(posedge clk);
		  @(posedge clk) reset = 0;


        //$display("Time\tOuterSensor\tInnerSensor\tincr\tdecr");

        // --- Car Entering Sequence ---
        @(posedge clk); OuterSensor = 1; InnerSensor = 0;  // Outer triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;  // Both triggered
        @(posedge clk); OuterSensor = 0; InnerSensor = 1;  // Outer off
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;  // Both off - incr 

        // --- Car Exiting Sequence ---
        @(posedge clk); OuterSensor = 0; InnerSensor = 1;  // Inner triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;  // Both triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 0;  // Inner off
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;  // Both off - decr 
		  
			// --- Car Entering Then Reversing ---
        @(posedge clk); OuterSensor = 1; InnerSensor = 0;  // Outer triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;  // Both triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 0;  // Outer triggered
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;  // Both off 

        // --- Car Exiting Then Reversing ---
        @(posedge clk); OuterSensor = 0; InnerSensor = 1;  // Inner triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;  // Both triggered
        @(posedge clk); OuterSensor = 0; InnerSensor = 1;  // Inner On
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;  // Both off  
		  
			// --- Glitches ---
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;  // Both Off 
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;  // Both triggered
        @(posedge clk); OuterSensor = 1; InnerSensor = 1;  // Inner On
        @(posedge clk); OuterSensor = 0; InnerSensor = 0;  // Both off 

        $stop;
    end
endmodule
