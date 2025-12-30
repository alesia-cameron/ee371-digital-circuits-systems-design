//EE 371 LAB 3 
//AU 25

/*
Module combines Task 1 Mic and Task 2 ROM by instantiating them in a single top-level module 
that plays input audio (Task 1) when SW9=0 and tone from memory (Task 2) when SW9=1.
*/

module Task2_TopLevel (CLOCK_50, CLOCK2_50, KEY, SW, FPGA_I2C_SCLK, 
FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, 
AUD_DACDAT);
	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [9:0] SW; //selects between task 1 & task 2
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
////////Local wires and initializations
	wire read_ready, write_ready;
	reg read, write; 
	wire read_part1, write_part1; 
	wire read_part2, write_part2; 

	wire [23:0] readdata_left_part1, readdata_right_part1; //reading vars for part 1
	wire [23:0] writedata_left_part1, writedata_right_part1;
	
	wire [23:0] readdata_left_part2, readdata_right_part2; //part 2 doesnt read
	wire [23:0] writedata_left_part2, writedata_right_part2;
	
	wire reset = ~KEY[0];//active low

///////////logic to choose between outputs of task 1 & task 2
	reg [23:0] master_output_right; //output from DFF selecting, reg means they're regiters
	reg [23:0] master_output_left;  //output from DFF selecting 
   
	always @(posedge CLOCK_50) 
	begin
        if (reset) begin
            master_output_left  <= 0;
            master_output_right <= 0;
				read <= 0;
				write <= 0;
        end else begin
            if (SW[9] == 1) begin //Task 2
                master_output_left  <= writedata_left_part2;
                master_output_right <= writedata_right_part2;
					 read <= 0; //Task 2 has no readying
					 write <= write_ready; //or should this be write_part2
            end 
				else begin //Task 1
					 master_output_left  <= writedata_left_part1;
                master_output_right <= writedata_right_part1;
					 read  <= read_part1;   
					 write <= write_part1;  
            end
        end
    end
       
///////////Instantiate both tasks//////////////////////
    Task2_part1 Task1_Instantiation (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .read_ready(read_ready),
        .write_ready(write_ready),
		  .read(read_part1), 
		  .write(write_part1), 
        .readdata_left(readdata_left_part1),
        .readdata_right(readdata_right_part1),
        .writedata_left(writedata_left_part1),
        .writedata_right(writedata_right_part1)
    );

    Task2_part2 Task2_Instantiation (
        .CLOCK_50(CLOCK_50),
        .reset(reset),
        .write_ready(write_ready),
		  //no read data
        .writedata_left(writedata_left_part2),
        .writedata_right(writedata_right_part2)
    );
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		.clk(CLOCK_50),
		.reset(reset),
		.read(read),	.write(write), //input
		.writedata_left(master_output_left), 
      .writedata_right(master_output_right),
		.AUD_ADCDAT(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK(AUD_BCLK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_DACLRCK(AUD_DACLRCK),

		// Outputs
		.read_ready(read_ready), .write_ready(write_ready),
		.readdata_left(readdata_left_part1), .readdata_right(readdata_right_part1),
		.AUD_DACDAT(AUD_DACDAT)
	);  
endmodule //Task2_TopLevel




////////////////////////Task 2 Test Bench/////////////////////////////////////
`timescale 1ns/1ps
module Task2_TopLevel_tb;

    //inputs
    reg CLOCK_50;
    reg CLOCK2_50;
    reg [0:0] KEY;
    reg [9:0] SW;

    //outputs
    wire FPGA_I2C_SCLK;
    wire AUD_XCK;
    wire AUD_DACDAT;

    //bidirectionals
    wire FPGA_I2C_SDAT;
    wire AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
    wire AUD_ADCDAT;

    Task2_TopLevel dut (
        .CLOCK_50(CLOCK_50),
        .CLOCK2_50(CLOCK2_50),
        .KEY(KEY),
        .SW(SW),
        .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
        .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
        .AUD_XCK(AUD_XCK),
        .AUD_DACLRCK(AUD_DACLRCK),
        .AUD_ADCLRCK(AUD_ADCLRCK),
        .AUD_BCLK(AUD_BCLK),
        .AUD_ADCDAT(AUD_ADCDAT),
        .AUD_DACDAT(AUD_DACDAT)
    );

    //clock generation
   initial CLOCK_50 = 0;
   always #10 CLOCK_50 = ~CLOCK_50;  

	initial CLOCK2_50 = 0;
	always #20 CLOCK2_50 = ~CLOCK2_50; //25MHz for codec XCK

    initial begin
        KEY = 1;  // reset inactive
        SW[9]  = 0; // start with task1

        @(posedge CLOCK_50); KEY = 0;             
        @(posedge CLOCK_50); KEY = 1;             

        //task1 for 10 clocks
        repeat (10) @(posedge CLOCK_50);

        //switch task2
        SW[9] = 1;

        //Run task2 for 10 clocks
        repeat (10) @(posedge CLOCK_50);
		 
		  SW[9] = 0; // back to task1
		  repeat (10) @(posedge CLOCK_50);

        SW[9] = 1; // task2 again
        repeat (10) @(posedge CLOCK_50);
        $stop;
    end
endmodule
