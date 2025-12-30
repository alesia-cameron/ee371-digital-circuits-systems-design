//EE 371 LAB 3 
//AU 25

/*
CLOCK_50 sequential logic updates on its rising edge
write_ready signal triggers module to move to next sample in the ROM
reset resets internal ROM address back to zero

Outputs:
writedata_left 24bit data output for the left audio channel
writedata_right 24bit data output for the right audio channel
 
Description:
Play a tone from memory MIF file

Task2_part2 reads audio tone data stored in ROM initialized from MIF file 
and continuously outputs it to both left and right audio channels.
It cycles through 48,000 audio samples in ROM, 
sends each sample to writedata_left and writedata_right. 

ROM address is stored internally in 16-bit register, 
which increments when write_ready high. When address reaches the last sample,
it wraps back to zero for looping. 

Reset input resets address to the start 
*/
module Task2_part2 (CLOCK_50, write_ready, reset, writedata_left, writedata_right);
	input CLOCK_50;
	input write_ready; 
   input reset;             
   output [23:0] writedata_left;  
   output [23:0] writedata_right;  
	
///////////Local logic list ///////////////////////////////////
	reg [15:0] ROM_address; 
	wire [23:0] Tone_data;
	assign writedata_left = Tone_data; //pass from ROM
	assign writedata_right = Tone_data;
	
	
////////Instantiation///////////////////////////////////////
	Task2_ROM1Port Rom_Instantiation (
		.address(ROM_address),
		.clock(CLOCK_50),
		.q(Tone_data)
	);
	
	
////////sequential logic for reading MIF file, incrementing the ROM////////
	always @(posedge CLOCK_50) //not always_ff bc .v not .sv
	begin
		 if (reset) 
		 begin
			  ROM_address <= 0;
		 end
		 else if (write_ready) begin
			  if (ROM_address == 16'd47999) begin //48000 words in MIF file
					ROM_address <= 0; //loop back to zero
			  end
			  else begin
					ROM_address <= ROM_address + 1;
			  end
		 end
	end

endmodule


