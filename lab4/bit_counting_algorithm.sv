//EE 371 Lab4
//Nov 1, 2025

/*
Input:
CLOCK_50 50 MHz clock signal
SW [7:0] 8bit switch input representing the number to count
KEY [3:0] 4bit key input where KEY[0] is reset and KEY[3] is start

Output:
HEX0 [6:0] 7-segment display showing # of 1s in SW
HEX1 [6:0] unused 7-segment display
HEX2 [6:0] unused 7-segment display
HEX3 [6:0] unused 7-segment display
HEX4 [6:0] unused 7-segment display
HEX5 [6:0] unused 7-segment display
LEDR [9:0] LED output LEDR[9] lights up when counting complete

Module implements 8 bit bit counter that counts the number
of 1s in a switch input and displays the result on a 7-segment display.
Uses a finite state machine with three states: S1 loads the switch 
value into a register, S2 shifts the register right while incrementing 
a result counter for each 1 encountered in the least significant bit, 
& S3 signals that counting is done. The module includes input 
synchronization for the switches and keys to prevent metastability. 
Instantiates a separate shift module and a 7-segment display module for
output.

*/
module bit_counting_algorithm (
	 input  logic CLOCK_50,
    input  logic [7:0]  SW,        
    input  logic [3:0]  KEY, // KEY[0] is reset, KEY[3] start
    output logic [6:0]  HEX0,
    output logic [9:0]  LEDR //light up LEDR9 as done signal 
);

	 //internal signals
	 logic Reset, s; //s is start signal

	 //synchronized signals for metastability
    logic [7:0] SW_Sync, SW_Stable;
    logic [3:0] KEY_Sync, KEY_Stable;

	 assign Reset = ~KEY_Stable[0];
	 assign s = ~KEY_Stable[3];
	 
	 //2-stage input synchronization -- Metastability
    //could make this into its own module later
    always_ff @(posedge CLOCK_50) begin
        //Initial synchronization
        SW_Sync <= SW;
        KEY_Sync <= KEY;
        //Stable outputs
        SW_Stable <= SW_Sync;
        KEY_Stable <= KEY_Sync;
    end

////////////datapath///////////////////////
    logic [7:0] A; //A is 8 bit num that comes from user flipping switches 0-7 on board
    logic [3:0] result;// number of 1's counted
    logic LoadA, done; //signal that we're finished counting lights up LEDR9
	 logic [7:0] A_Next;   //current version of A
    logic [7:0] A_Shifted;  //next shifted version

///////state declaration
   enum logic [2:0] {
      S1,
      S2,
      S3
   } ps, ns;

////////////////////FSM Logic//////////////////////////
//flip flop handling next and present state
   always_ff @(posedge CLOCK_50)
      if (Reset) 
		ps <= S1;
      else 
		ps <= ns;
		
  //load a is listening constantly then stop at start = 1 needs to be registered use a ff to store a
  //need to remember what a is once s = 1 aka start = 1
  //reg a if s1 rega to load a
  //then reg a = rega then you shift
  
    //result register needs to remember across states
    always_ff @(posedge CLOCK_50) begin
        if (Reset)
            result <= 0;
        else if (ps == S1)
            result <= 0; //reset result when loading
        else if (ps == S2 && A[0] == 1)
            result <= result + 1; //otherwise
    end
	 
	 //A register holds either new switch value or old A
	always_ff @(posedge CLOCK_50) begin
		 if (Reset)
			  A <= 0;
		 else if (LoadA)
			  A <= SW_Stable; //load switches
		 else if (ps == S2)
			  A <= {1'b0, A[7:1]}; //shift right manually here
    end


	//datapath
	 always_comb begin
	     LoadA = 0;
        done = 0;
        ns = ps;
			case (ps)
				S1: 
				begin
					LoadA = 1; //enable to load
					done = 0;
					if (s == 0 ) 
						begin
						ns = S1;
						end
					else 
					 ns = S2;
				end //end S1	    
				 
			S2: 
			begin
				if (A == 0) ns = S3;
				else if (A[0] == 1) //A0 is the LSB of A leftmost bit
					begin
					ns = S2;
					end
				else 
					ns = S2;
			end //end S2
			
			S3: 
			begin
				done = 1; 
				if (s == 1) ns = S3;
				else ns = S1;
			end //end S3
		
		endcase 
    end
		
		//instantiate shift module
		right_shift_A shifting (
        .InputToLoad(A),
        .LoadNewVal(LoadA),
        .CLOCK_50(CLOCK_50),
        .Result(A_Shifted)
      );
	
	 //light up LEDR9 when done
    assign LEDR[9] = done;
	
//////////////////Seg7 Inst///////////////////////////
	//seg 7 code from lab 2
	seg7 seg7HEX0 (.data(result), .segments(HEX0));

endmodule //end bit_counting_algorithm
