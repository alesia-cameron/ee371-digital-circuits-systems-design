//EE 371 LAB 3 
//AU 25

/*
Inputs:
CLOCK_50 system clock
CLOCK2_50 secondary clock used for generating audio master clock
KEY reset control active low
AUD_DACLRCK DAC left right clock input from codec
AUD_ADCLRCK ADC left right clock input from codec
AUD_BCLK bit clock input from codec
AUD_ADCDAT ADC serial audio input from codec

Outputs:
FPGA_I2C_SCLK I2C clock for audio video configuration
AUD_XCK master clock output to audio codec
writedata_left 24 bit audio output for left channel passed directly from input
writedata_right 24 bit audio output for right channel passed directly from input
AUD_DACDAT DAC serial audio output to codec

Bidirectional:
FPGA_I2C_SDAT I2C data line for configuration

Description: Module acts as synchronized audio pass-through for Task 3
Doesn’t modify the audio but ensures that data is transferred when the
audio codec is ready. Instantiated by Task2_Top
*/

module Task3_TopLevel (CLOCK_50, CLOCK2_50, KEY, SW, FPGA_I2C_SCLK, 
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
	
///////////logic to choose between outputs of task 1 & task 2 & filtered vs not
	reg [23:0] master_output_right; //output from DFF selecting, reg means they're regiters
	reg [23:0] master_output_left;  //output from DFF selecting 
	
	wire [23:0] filtered_left;
	wire [23:0] filtered_right;
	
	reg [23:0] data_to_filter_left;
	reg [23:0] data_to_filter_right;
	
	always @(posedge CLOCK_50) 
	begin
        if (reset) begin
            master_output_left  <= 0;
            master_output_right <= 0;
				read <= 0;
				write <= 0;
        end 
		 
		 else begin
            if (SW[9] == 1) begin //Task 2
					data_to_filter_left<= writedata_left_part2;
					data_to_filter_right <= writedata_right_part2;
					if (SW[8] == 1) begin //filtered
						 master_output_left  <= filtered_left;
						 master_output_right <= filtered_right;
						 read <= 0; //Task 2 has no readying
						 write <= write_ready; 
					end 
					else begin //non filtered
						 master_output_left  <= writedata_left_part2;
						 master_output_right <= writedata_right_part2;
						 read <= 0; //Task 2 has no readying
						 write <= write_ready; 
					 end
            end //Task 2
			
		 else begin //Task 1
					data_to_filter_left<= writedata_left_part1;
					data_to_filter_right <= writedata_right_part1;
					if (SW[8] == 1) begin //filtered
						 master_output_left  <= filtered_left;
						 master_output_right <= filtered_right;
						 read  <= read_part1;   
					    write <= write_part1;  
					end 
					else begin //not filtered
					 master_output_left  <= writedata_left_part1;
                master_output_right <= writedata_right_part1;
					 read  <= read_part1;   
					 write <= write_part1;  
					 end
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

//////// Instantiate filters for Right and Left samples
//need to instantiatte two for left and right values for each audio channel in top module
//module fifo #(parameter DATA_WIDTH=8, ADDR_WIDTH=4)
FIR_Filter #(256, 24) left_filter (
    .clk(CLOCK_50),
    .reset(reset),
    .isValid(write_ready),
    .dataIn(data_to_filter_left),
    .dataOut(filtered_left)
);

FIR_Filter #(256, 24) right_filter (
    .clk(CLOCK_50),
    .reset(reset),
    .isValid(write_ready),
    .dataIn(data_to_filter_right),
    .dataOut(filtered_right)
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
