/* 
EE/CSE 371
Nov 16, 2025
Lab 5  */


/* Top level module of Task 3 
 *
 * Inputs:
 *   KEY - On board keys of FPGA
 *   SW 	- On board switches of FPGA
 *   CLOCK_50 - On board 50 MHz clock of FPGA
 *
 * Outputs:
 *   HEX - On board 7 segment displays of FPGA
 *   LEDR - On board LEDs of FPGA
 *   VGA_R - Red data of VGA connection
 *   VGA_G - Green data of VGA connection
 *   VGA_B - Blue data of VGA connection
 *   VGA_BLANK_N - Blanking interval of VGA connection
 *   VGA_CLK - VGA's clock signal
 *   VGA_HS - Horizontal Sync of VGA connection
 *   VGA_SYNC_N - Enable signal for the sync of VGA connection
 *   VGA_VS	- Vertical Sync of VGA connection
 
Description: 
This module is a VGA drawing system on the DE1 board. When the user presses KEY0, it launches a full-screen clear 
that wipes every pixel by sweeping through the entire 640×480 framebuffer by colum. 
After screen cleared system waits for KEY1 press which begins animating a dog drawing line by line. 
Each line’s start and end coordinates come from a lookup table. A Bresenham line_drawer module produces 
every pixel along the segment. A FSM steps through clearing, waiting, drawing, pausing for animation timing to be visible,
and done state. A mux decides whether framebuffer receives clear pixels or line drawing pixels. 
Once last line drawn, the image stays on screen as framebuffer holds all written values until reset is aserted and it 
clears.
*/


module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR[8:0] = SW[8:0];
	
	logic [10:0] x0, y0, x1, y1, x, y;
	logic color, reset;
	
////////////Framebuffer clear controls/////////////
	logic clear_active;  //high while clearing screen
	logic [9:0] clear_x; //clear pixel column 0-639
	logic [8:0] clear_y; //clear pixel row 0-479
	logic [10:0] framebuffer_x; //x coordinate sent
	logic [10:0] framebuffer_y; //y coordinate sent
	logic framebuffer_color; //pixel color
	
	
/////////////////Framebuffer//////////////////
	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(1'b0), 
		.x              (framebuffer_x),
		.y              (framebuffer_y),
		.pixel_color	(framebuffer_color), 
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));
		
////////////////Line Drawer Instantiation////////////	
	logic done;
	line_drawer lines (.clk(CLOCK_50), .reset(reset), .x0, .y0, .x1, .y1, .x, .y, .done);

	
/////////////////FSM Logic///////////////////////////////	
	
	//FSM States (clear screen, wait for start, draw lines, wait for animation purposes, done)
	enum {clear, wait_start, draw, wait_delay, finished} ps, ns;
	assign reset = (ps == draw);

//FSM logic 
/*
When the reset key is pressed, immediately enters the clear state, 
resets coordinates, color, line index, and delay counter, and activates
clear engine to start clearing the screen pixel by pixel. 

While in clear, if the clear is active, it increments clear_x and clear_y 
until entire screen is cleared, then moves to wait_start. 

In wait_start, the FSM waits for start key press to begin drawing, 
initializing first line’s coordinates, color, and resetting the line index

In the draw state, sets pixel color to active and waits for line drawer 
to signal done, moves to wait_delay. 

During wait_delay, counter runs to create visible pause between drawing lines
if more lines remain, FSM updates coordinates for next line and returns to draw
If all lines drawn, it enters finished and remains there, holding the final drawn image
*/	
	always_ff @(posedge CLOCK_50) 
	begin
		if (~KEY[0]) begin
			ps <= clear;
			x0 <= 11'd0;
			x1 <= 11'd0;
			y0 <= 11'd0;
			y1 <= 11'd480;
			color <= 1'b0;
			line_index <= 16'd0;
			delay_counter <= 26'd0;

			// start clear engine on user press
			clear_active <= 1'b1;
			clear_x <= 10'd0;
			clear_y <= 9'd0;
		end else 
		begin
			case (ps)
				
				clear: begin //clear state see description above
					color <= 1'b0;
					
					//clear engine drives framebuffer while clear_active true
					if (clear_active) begin
						if (clear_x < 10'd639) begin
							clear_x <= clear_x + 10'd1;
						end else begin
							clear_x <= 10'd0;
							if (clear_y < 9'd479) begin
								clear_y <= clear_y + 9'd1;
							end else begin
								//finished clearing screen
								clear_active <= 1'b0;
								ps <= wait_start;
							end
						end
					end else begin
						//fallback if clear_active somehow false in clear state
						if (x0 < 11'd640) begin
							if (done) begin
								x0 <= x0 + 11'd1;
								x1 <= x1 + 11'd1;
							end
						end else 
						begin
							ps <= wait_start;
						end
					end
				end
				
				wait_start: begin //wait state see description above
					if (~KEY[1]) begin
						ps <= draw;
						line_index <= 16'd0;
						x0 <= line_x0;
						y0 <= line_y0;
						x1 <= line_x1;
						y1 <= line_y1;
						color <= 1'b1;
					end
				end
				
				draw: begin //draw state see description above
					color <= 1'b1;
					
					if (done) begin
						ps <= wait_delay;
						delay_counter <= 26'd0;
					end
				end
				
				wait_delay: //delay state see description above
				begin
					delay_counter <= delay_counter + 26'd1;
					
					if (delay_counter >= delay_05s) begin
						if (line_index < NUM_LINES - 1) begin
							line_index <= line_index + 16'd1;
							x0 <= line_x0;
							y0 <= line_y0;
							x1 <= line_x1;
							y1 <= line_y1;
							ps <= draw;
						end else begin
							ps <= finished;
						end
					end
				end
				
				finished: begin //finished state see description above
					ps <= finished;
				end
				
			endcase
		end
	end


	//route proper coordinates and color into the framebuffer
	//clear engine takes priority while active
	always_comb begin
		if (clear_active) begin
			// sign/width extend to 11 bits for framebuffer interface
			framebuffer_x = {1'b0, clear_x};
			framebuffer_y = {2'b00, clear_y};
			framebuffer_color = 1'b0;
		end else begin
			framebuffer_x = x;
			framebuffer_y = y;
			framebuffer_color = color;
		end
	end


	//animation/drawing delay counter so we can see "the drawing"
	logic [25:0] delay_counter;
	parameter delay_1s = 26'd50_000_000; //1 sec
	parameter delay_05s = 26'd25_000_000; //0.5 sec
	parameter delay_02s = 26'd10_000_000; //0.2 sec
	
/////////////////Dog Drawing//////////////////
	parameter NUM_LINES = 100; //up to 100 lines to draw dog (we only use 60 at this point)
	logic [10:0] line_x0, line_y0, line_x1, line_y1;
	logic [15:0] line_index;
	
	always_comb //line coordinates based on curr index
	begin
		case (line_index)
         
           //body
	        16'd0:  begin line_x0 = 11'd200; line_y0 = 11'd450; line_x1 = 11'd230; line_y1 = 11'd370; end
	        16'd1:  begin line_x0 = 11'd330; line_y0 = 11'd370; line_x1 = 11'd350; line_y1 = 11'd450; end
 		     16'd2:  begin line_x0 = 11'd250; line_x1 = 11'd310; line_y0 = 11'd370; line_y1 = 11'd370; end
            
            //head
            16'd3:  begin line_x0 = 11'd310; line_x1 = 11'd350; line_y0 = 11'd370; line_y1 = 11'd320; end
            16'd4:  begin line_x0 = 11'd250; line_x1 = 11'd200; line_y0 = 11'd370; line_y1 = 11'd320; end
            16'd5:  begin line_x0 = 11'd350; line_x1 = 11'd370; line_y0 = 11'd320; line_y1 = 11'd240; end
            16'd6:  begin line_x0 = 11'd200; line_x1 = 11'd180; line_y0 = 11'd320; line_y1 = 11'd240; end
            16'd7:  begin line_x0 = 11'd370; line_x1 = 11'd365; line_y0 = 11'd240; line_y1 = 11'd150; end
            16'd8:  begin line_x0 = 11'd180; line_x1 = 11'd185; line_y0 = 11'd240; line_y1 = 11'd150; end
            
            //top of head
            16'd9:  begin line_x0 = 11'd185; line_x1 = 11'd210; line_y0 = 11'd150; line_y1 = 11'd130; end
            16'd10: begin line_x0 = 11'd210; line_x1 = 11'd275; line_y0 = 11'd130; line_y1 = 11'd120; end
            16'd11: begin line_x0 = 11'd275; line_x1 = 11'd340; line_y0 = 11'd120; line_y1 = 11'd130; end
            16'd12: begin line_x0 = 11'd340; line_x1 = 11'd365; line_y0 = 11'd130; line_y1 = 11'd150; end
           
            //nose
				16'd13: begin line_x0 = 11'd280; line_x1 = 11'd270; line_y0 = 11'd250; line_y1 = 11'd260; end 
				16'd14: begin line_x0 = 11'd270; line_x1 = 11'd265; line_y0 = 11'd260; line_y1 = 11'd275; end 
				16'd15: begin line_x0 = 11'd265; line_x1 = 11'd270; line_y0 = 11'd275; line_y1 = 11'd290; end 
				16'd16: begin line_x0 = 11'd270; line_x1 = 11'd280; line_y0 = 11'd290; line_y1 = 11'd300; end 
				16'd17: begin line_x0 = 11'd280; line_x1 = 11'd290; line_y0 = 11'd300; line_y1 = 11'd290; end 
				16'd18: begin line_x0 = 11'd290; line_x1 = 11'd295; line_y0 = 11'd290; line_y1 = 11'd275; end 
				16'd19: begin line_x0 = 11'd295; line_x1 = 11'd290; line_y0 = 11'd275; line_y1 = 11'd260; end
				16'd20: begin line_x0 = 11'd290; line_x1 = 11'd280; line_y0 = 11'd260; line_y1 = 11'd250; end
				
				//left eye
				16'd21: begin line_x0 = 11'd230; line_x1 = 11'd240; line_y0 = 11'd175; line_y1 = 11'd170; end
				16'd22: begin line_x0 = 11'd240; line_x1 = 11'd250; line_y0 = 11'd170; line_y1 = 11'd175; end
				16'd23: begin line_x0 = 11'd250; line_x1 = 11'd245; line_y0 = 11'd175; line_y1 = 11'd190; end
				16'd24: begin line_x0 = 11'd245; line_x1 = 11'd235; line_y0 = 11'd190; line_y1 = 11'd190; end
				16'd25: begin line_x0 = 11'd235; line_x1 = 11'd230; line_y0 = 11'd190; line_y1 = 11'd175; end
				  
				//right eye
				16'd26: begin line_x0 = 11'd290; line_x1 = 11'd300; line_y0 = 11'd175; line_y1 = 11'd170; end
				16'd27: begin line_x0 = 11'd300; line_x1 = 11'd310; line_y0 = 11'd170; line_y1 = 11'd175; end
				16'd28: begin line_x0 = 11'd310; line_x1 = 11'd305; line_y0 = 11'd175; line_y1 = 11'd190; end
				16'd29: begin line_x0 = 11'd305; line_x1 = 11'd295; line_y0 = 11'd190; line_y1 = 11'd190; end
				16'd30: begin line_x0 = 11'd295; line_x1 = 11'd290; line_y0 = 11'd190; line_y1 = 11'd175; end
			
				//left ear
				16'd31: begin line_x0 = 11'd185; line_x1 = 11'd140; line_y0 = 11'd150; line_y1 = 11'd180; end
				16'd32: begin line_x0 = 11'd140; line_x1 = 11'd110; line_y0 = 11'd180; line_y1 = 11'd230; end
				16'd33: begin line_x0 = 11'd110; line_x1 = 11'd100; line_y0 = 11'd230; line_y1 = 11'd290; end
				16'd34: begin line_x0 = 11'd100; line_x1 = 11'd110; line_y0 = 11'd290; line_y1 = 11'd340; end
				16'd35: begin line_x0 = 11'd110; line_x1 = 11'd135; line_y0 = 11'd340; line_y1 = 11'd365; end
				16'd36: begin line_x0 = 11'd135; line_x1 = 11'd165; line_y0 = 11'd365; line_y1 = 11'd350; end
				16'd37: begin line_x0 = 11'd165; line_x1 = 11'd175; line_y0 = 11'd350; line_y1 = 11'd300; end
				16'd38: begin line_x0 = 11'd175; line_x1 = 11'd180; line_y0 = 11'd300; line_y1 = 11'd240; end
				
				//right ear
				16'd39: begin line_x0 = 11'd365; line_x1 = 11'd410; line_y0 = 11'd150; line_y1 = 11'd180; end
				16'd40: begin line_x0 = 11'd410; line_x1 = 11'd440; line_y0 = 11'd180; line_y1 = 11'd230; end
				16'd41: begin line_x0 = 11'd440; line_x1 = 11'd450; line_y0 = 11'd230; line_y1 = 11'd290; end
				16'd42: begin line_x0 = 11'd450; line_x1 = 11'd440; line_y0 = 11'd290; line_y1 = 11'd340; end
				16'd43: begin line_x0 = 11'd440; line_x1 = 11'd415; line_y0 = 11'd340; line_y1 = 11'd365; end
				16'd44: begin line_x0 = 11'd415; line_x1 = 11'd385; line_y0 = 11'd365; line_y1 = 11'd350; end
				16'd45: begin line_x0 = 11'd385; line_x1 = 11'd375; line_y0 = 11'd350; line_y1 = 11'd300; end
				16'd46: begin line_x0 = 11'd375; line_x1 = 11'd370; line_y0 = 11'd300; line_y1 = 11'd240; end
		
				//collar 
				16'd47: begin line_x0 = 11'd230; line_x1 = 11'd250; line_y0 = 11'd375; line_y1 = 11'd380; end
				16'd48: begin line_x0 = 11'd250; line_x1 = 11'd275; line_y0 = 11'd380; line_y1 = 11'd382; end
				16'd49: begin line_x0 = 11'd275; line_x1 = 11'd300; line_y0 = 11'd382; line_y1 = 11'd380; end
				16'd50: begin line_x0 = 11'd300; line_x1 = 11'd335; line_y0 = 11'd380; line_y1 = 11'd375; end
				
				//collar tag 
				16'd55: begin line_x0 = 11'd270; line_x1 = 11'd280; line_y0 = 11'd382; line_y1 = 11'd382; end
				16'd56: begin line_x0 = 11'd280; line_x1 = 11'd280; line_y0 = 11'd382; line_y1 = 11'd392; end
				16'd57: begin line_x0 = 11'd280; line_x1 = 11'd270; line_y0 = 11'd392; line_y1 = 11'd392; end
				16'd58: begin line_x0 = 11'd270; line_x1 = 11'd270; line_y0 = 11'd392; line_y1 = 11'd382; end
				
				default: begin line_x0 = 11'd0; line_y0 = 11'd0; line_x1 = 11'd0; line_y1 = 11'd0; end
			endcase
		end
	
	assign LEDR[9] = done;

endmodule  // DE1_SoC


/*

below is version optimized for simulation with timing, 
not to use on actual FPGA

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR[8:0] = SW[8:0];
	
	logic [10:0] x0, y0, x1, y1, x, y;
	logic reset;
	
////////////Framebuffer clear controls/////////////
	logic clear_active;
	logic [9:0] clear_x;
	logic [8:0] clear_y;
	logic [10:0] framebuffer_x;
	logic [10:0] framebuffer_y;
	logic framebuffer_color;
	
	
/////////////////Framebuffer//////////////////
	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(1'b0), 
		.x              (framebuffer_x),
		.y              (framebuffer_y),
		.pixel_color	(framebuffer_color), 
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));
		
////////////////Line Drawer Instantiation////////////	
	logic done;
	line_drawer lines (.clk(CLOCK_50), .reset(reset), .x0, .y0, .x1, .y1, .x, .y, .done);

	
/////////////////FSM Logic///////////////////////////////	
	
	enum {clear, wait_start, draw, wait_delay, finished} ps, ns;
	assign reset = (ps == draw);

	logic [25:0] delay_counter;
	parameter delay_1s = 26'd50_000_000;
	parameter delay_05s = 26'd25_000_000;
	parameter delay_02s = 26'd10_000_000;
	
	parameter NUM_LINES = 100;
	logic [10:0] line_x0, line_y0, line_x1, line_y1;
	logic [15:0] line_index;

	always_ff @(posedge CLOCK_50) 
	begin
		if (~KEY[0]) begin
			ps <= clear;
			x0 <= 11'd0;
			x1 <= 11'd0;
			y0 <= 11'd0;
			y1 <= 11'd480;
			line_index <= 16'd0;
			delay_counter <= 26'd0;
			clear_active <= 1'b1;
			clear_x <= 10'd0;
			clear_y <= 9'd0;
		end else 
		begin
			case (ps)
				
				clear: begin
					if (clear_active) begin
						if (clear_x < 10'd639) begin
							clear_x <= clear_x + 10'd1;
						end else begin
							clear_x <= 10'd0;
							if (clear_y < 9'd479) begin
								clear_y <= clear_y + 9'd1;
							end else begin
								clear_active <= 1'b0;
								ps <= wait_start;
							end
						end
					end else begin
						if (x0 < 11'd640) begin
							if (done) begin
								x0 <= x0 + 11'd1;
								x1 <= x1 + 11'd1;
							end
						end else 
						begin
							ps <= wait_start;
						end
					end
				end
				
				wait_start: begin
					if (~KEY[1]) begin
						ps <= draw;
						line_index <= 16'd0;
						x0 <= line_x0;
						y0 <= line_y0;
						x1 <= line_x1;
						y1 <= line_y1;
					end
				end
				
				draw: begin
					if (done) begin
						ps <= wait_delay;
						delay_counter <= 26'd0;
					end
				end
				
				wait_delay: 
				begin
					delay_counter <= delay_counter + 26'd1;
					
					if (delay_counter >= delay_05s) begin
						if (line_index < NUM_LINES - 1) begin
							line_index <= line_index + 16'd1;
							x0 <= line_x0;
							y0 <= line_y0;
							x1 <= line_x1;
							y1 <= line_y1;
							ps <= draw;
						end else begin
							ps <= finished;
						end
					end
				end
				
				finished: begin
					ps <= finished;
				end
				
			endcase
		end
	end


	always_comb begin
		if (clear_active) begin
			framebuffer_x = {1'b0, clear_x};
			framebuffer_y = {2'b00, clear_y};
			framebuffer_color = 1'b0;
		end else begin
			framebuffer_x = x;
			framebuffer_y = y;
			framebuffer_color = 1'b1;
		end
	end

	
	always_comb
	begin
		case (line_index)
         
           //body
	        16'd0:  begin line_x0 = 11'd200; line_y0 = 11'd450; line_x1 = 11'd230; line_y1 = 11'd370; end
	        16'd1:  begin line_x0 = 11'd330; line_y0 = 11'd370; line_x1 = 11'd350; line_y1 = 11'd450; end
 		     16'd2:  begin line_x0 = 11'd250; line_x1 = 11'd310; line_y0 = 11'd370; line_y1 = 11'd370; end
            
            //head
            16'd3:  begin line_x0 = 11'd310; line_x1 = 11'd350; line_y0 = 11'd370; line_y1 = 11'd320; end
            16'd4:  begin line_x0 = 11'd250; line_x1 = 11'd200; line_y0 = 11'd370; line_y1 = 11'd320; end
            16'd5:  begin line_x0 = 11'd350; line_x1 = 11'd370; line_y0 = 11'd320; line_y1 = 11'd240; end
            16'd6:  begin line_x0 = 11'd200; line_x1 = 11'd180; line_y0 = 11'd320; line_y1 = 11'd240; end
            16'd7:  begin line_x0 = 11'd370; line_x1 = 11'd365; line_y0 = 11'd240; line_y1 = 11'd150; end
            16'd8:  begin line_x0 = 11'd180; line_x1 = 11'd185; line_y0 = 11'd240; line_y1 = 11'd150; end
            
            //top of head
            16'd9:  begin line_x0 = 11'd185; line_x1 = 11'd210; line_y0 = 11'd150; line_y1 = 11'd130; end
            16'd10: begin line_x0 = 11'd210; line_x1 = 11'd275; line_y0 = 11'd130; line_y1 = 11'd120; end
            16'd11: begin line_x0 = 11'd275; line_x1 = 11'd340; line_y0 = 11'd120; line_y1 = 11'd130; end
            16'd12: begin line_x0 = 11'd340; line_x1 = 11'd365; line_y0 = 11'd130; line_y1 = 11'd150; end
           
            //nose
				16'd13: begin line_x0 = 11'd280; line_x1 = 11'd270; line_y0 = 11'd250; line_y1 = 11'd260; end 
				16'd14: begin line_x0 = 11'd270; line_x1 = 11'd265; line_y0 = 11'd260; line_y1 = 11'd275; end 
				16'd15: begin line_x0 = 11'd265; line_x1 = 11'd270; line_y0 = 11'd275; line_y1 = 11'd290; end 
				16'd16: begin line_x0 = 11'd270; line_x1 = 11'd280; line_y0 = 11'd290; line_y1 = 11'd300; end 
				16'd17: begin line_x0 = 11'd280; line_x1 = 11'd290; line_y0 = 11'd300; line_y1 = 11'd290; end 
				16'd18: begin line_x0 = 11'd290; line_x1 = 11'd295; line_y0 = 11'd290; line_y1 = 11'd275; end 
				16'd19: begin line_x0 = 11'd295; line_x1 = 11'd290; line_y0 = 11'd275; line_y1 = 11'd260; end
				16'd20: begin line_x0 = 11'd290; line_x1 = 11'd280; line_y0 = 11'd260; line_y1 = 11'd250; end
				
				//left eye
				16'd21: begin line_x0 = 11'd230; line_x1 = 11'd240; line_y0 = 11'd175; line_y1 = 11'd170; end
				16'd22: begin line_x0 = 11'd240; line_x1 = 11'd250; line_y0 = 11'd170; line_y1 = 11'd175; end
				16'd23: begin line_x0 = 11'd250; line_x1 = 11'd245; line_y0 = 11'd175; line_y1 = 11'd190; end
				16'd24: begin line_x0 = 11'd245; line_x1 = 11'd235; line_y0 = 11'd190; line_y1 = 11'd190; end
				16'd25: begin line_x0 = 11'd235; line_x1 = 11'd230; line_y0 = 11'd190; line_y1 = 11'd175; end
				  
				//right eye
				16'd26: begin line_x0 = 11'd290; line_x1 = 11'd300; line_y0 = 11'd175; line_y1 = 11'd170; end
				16'd27: begin line_x0 = 11'd300; line_x1 = 11'd310; line_y0 = 11'd170; line_y1 = 11'd175; end
				16'd28: begin line_x0 = 11'd310; line_x1 = 11'd305; line_y0 = 11'd175; line_y1 = 11'd190; end
				16'd29: begin line_x0 = 11'd305; line_x1 = 11'd295; line_y0 = 11'd190; line_y1 = 11'd190; end
				16'd30: begin line_x0 = 11'd295; line_x1 = 11'd290; line_y0 = 11'd190; line_y1 = 11'd175; end
			
				//left ear
				16'd31: begin line_x0 = 11'd185; line_x1 = 11'd140; line_y0 = 11'd150; line_y1 = 11'd180; end
				16'd32: begin line_x0 = 11'd140; line_x1 = 11'd110; line_y0 = 11'd180; line_y1 = 11'd230; end
				16'd33: begin line_x0 = 11'd110; line_x1 = 11'd100; line_y0 = 11'd230; line_y1 = 11'd290; end
				16'd34: begin line_x0 = 11'd100; line_x1 = 11'd110; line_y0 = 11'd290; line_y1 = 11'd340; end
				16'd35: begin line_x0 = 11'd110; line_x1 = 11'd135; line_y0 = 11'd340; line_y1 = 11'd365; end
				16'd36: begin line_x0 = 11'd135; line_x1 = 11'd165; line_y0 = 11'd365; line_y1 = 11'd350; end
				16'd37: begin line_x0 = 11'd165; line_x1 = 11'd175; line_y0 = 11'd350; line_y1 = 11'd300; end
				16'd38: begin line_x0 = 11'd175; line_x1 = 11'd180; line_y0 = 11'd300; line_y1 = 11'd240; end
				
				//right ear
				16'd39: begin line_x0 = 11'd365; line_x1 = 11'd410; line_y0 = 11'd150; line_y1 = 11'd180; end
				16'd40: begin line_x0 = 11'd410; line_x1 = 11'd440; line_y0 = 11'd180; line_y1 = 11'd230; end
				16'd41: begin line_x0 = 11'd440; line_x1 = 11'd450; line_y0 = 11'd230; line_y1 = 11'd290; end
				16'd42: begin line_x0 = 11'd450; line_x1 = 11'd440; line_y0 = 11'd290; line_y1 = 11'd340; end
				16'd43: begin line_x0 = 11'd440; line_x1 = 11'd415; line_y0 = 11'd340; line_y1 = 11'd365; end
				16'd44: begin line_x0 = 11'd415; line_x1 = 11'd385; line_y0 = 11'd365; line_y1 = 11'd350; end
				16'd45: begin line_x0 = 11'd385; line_x1 = 11'd375; line_y0 = 11'd350; line_y1 = 11'd300; end
				16'd46: begin line_x0 = 11'd375; line_x1 = 11'd370; line_y0 = 11'd300; line_y1 = 11'd240; end
		
				//collar 
				16'd47: begin line_x0 = 11'd230; line_x1 = 11'd250; line_y0 = 11'd375; line_y1 = 11'd380; end
				16'd48: begin line_x0 = 11'd250; line_x1 = 11'd275; line_y0 = 11'd380; line_y1 = 11'd382; end
				16'd49: begin line_x0 = 11'd275; line_x1 = 11'd300; line_y0 = 11'd382; line_y1 = 11'd380; end
				16'd50: begin line_x0 = 11'd300; line_x1 = 11'd335; line_y0 = 11'd380; line_y1 = 11'd375; end
				
				//collar tag 
				16'd51: begin line_x0 = 11'd270; line_x1 = 11'd280; line_y0 = 11'd382; line_y1 = 11'd382; end
				16'd52: begin line_x0 = 11'd280; line_x1 = 11'd280; line_y0 = 11'd382; line_y1 = 11'd392; end
				16'd53: begin line_x0 = 11'd280; line_x1 = 11'd270; line_y0 = 11'd392; line_y1 = 11'd392; end
				16'd54: begin line_x0 = 11'd270; line_x1 = 11'd270; line_y0 = 11'd392; line_y1 = 11'd382; end

				default: begin line_x0 = 11'd0; line_y0 = 11'd0; line_x1 = 11'd0; line_y1 = 11'd0; end
		endcase
	end
	
	assign LEDR[9] = done;

endmodule  // DE1_SoC

*/