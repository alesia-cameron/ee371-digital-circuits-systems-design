//EE 371 Lab4
//Nov 1, 2025


/* 
Binary Search Top-Level Module
 
This is the top-level integration module for the binary search in task 2. It connects the control FSM(binary_search_control),
datapathbinary_search_datapath), and memory module(ram32x8.v). It handles KEY0 and KEY3 synchronization for edge detection, Sets up the boards
switches (SW[7:0]), keys (KEY0 and KEY3), LEDs (LEDR9 and LEDR0) and 7-seg displays(HEX0 and HEX1) and facilitates the functioning of the binary search.
 
Inputs:
CLOCK_50: system clock 
KEY: 4bit push button inputs where KEY[0] is reset and KEY[3] is start and 
	   the rest are unused
SW: 8bit switch inputs arget search value unsigned 8-bit integer
 
Outputs:
HEX0: 7bit 7-seg display for ones digit of found location 
HEX1: 7bit 7-seg display for tens digit of found location 
LEDR: 10bit LED array where LEDR[9] is done flag, LEDR[0] is found flag, and others are unused
 */
module binary_search_top (
    input logic CLOCK_50,
    input logic [3:0] KEY,
    input logic [7:0] SW,
    output logic [6:0] HEX0, //ones digit
    output logic [6:0] HEX1, //tens digit
    output logic [9:0] LEDR
);
    logic reset, start_raw, start;     //control signals
    logic [7:0] A_in;                  //search value from switches
    logic done, found;                 //status outputs
    logic [4:0] loc;                   //found location
    
    //input from board
    assign reset = ~KEY[0];            
    assign start_raw = ~KEY[3];        
    assign A_in = SW[7:0];             //val to search for from switch inputs
    
    //synchronize start button for edge detection for one-cycle pulse
    logic start_sync1, start_sync2, start_prev;
    always_ff @(posedge CLOCK_50) 
	 begin
        if (reset) 
		  begin
            start_sync1 <= 1'b0;
            start_sync2 <= 1'b0;
            start_prev <= 1'b0;
        end else 
		  begin
            start_sync1 <= start_raw;   //1st sync 
            start_sync2 <= start_sync1; //2nd sync 
            start_prev <= start_sync2;  //delay edge detection
        end
    end
    assign start = start_sync2 & ~start_prev;  //rising edge = start pulse
    
    //memory interface signals
    logic [4:0] mem_addr; //address to memory
    logic [7:0] mem_data;  //data from memory
    
    //datapath control fsm signals
    logic load_A, init_bounds, update_mid;
    logic update_lower, update_upper, set_found, clear_found;
    logic [4:0] low, high, mid;
    logic A_eq_mem, A_lt_mem, search_done;
    logic [7:0] A;
    
    //memory instance of ram32x8.v which is a 32x8 RAM with sorted data
    ram32x8 memory (
        .address(mem_addr),
        .clock(CLOCK_50),
        .data(8'd0), //no writing
        .wren(1'b0), //disabled
        .q(mem_data) //output data
    );
    
    //datapath instance performs computations and comparisons for binaru search 
    binary_search_datapath datapath (
        .clk(CLOCK_50),
        .reset(reset),
        .A_in(A_in),
        .mem_data(mem_data),
        .load_A(load_A),
        .init_bounds(init_bounds),
        .update_mid(update_mid),
        .update_lower(update_lower),
        .update_upper(update_upper),
        .set_found(set_found),
        .clear_found(clear_found),
        .mem_addr(mem_addr),
        .low(low),
        .high(high),
        .mid(mid),
        .loc(loc),
        .found(found),
        .search_done(search_done),
        .A_eq_mem(A_eq_mem),
        .A_lt_mem(A_lt_mem),
        .A(A)
    );
    
    //control instance does search sequence and makes sure state transitioning correct
    binary_search_control control (
        .clk(CLOCK_50),
        .reset(reset),
        .start(start),
        .A_eq_mem(A_eq_mem),
        .A_lt_mem(A_lt_mem),
        .search_done(search_done),
        .load_A(load_A),
        .init_bounds(init_bounds),
        .update_mid(update_mid),
        .update_lower(update_lower),
        .update_upper(update_upper),
        .set_found(set_found),
        .clear_found(clear_found),
        .done(done)
    );
    
    //display location on HEX display
    seg7 hex0_display (
        .data(found ? loc[3:0] : 4'd0), //ones digit
        .segments(HEX0)
    );
    
    seg7 hex1_display (
        .data(found ? {3'd0, loc[4]} : 4'd0), //tens digit
        .segments(HEX1)
    );
    
    //outpu LEDs
    assign LEDR[9] = done;  //LED search complete
    assign LEDR[0] = found; //LED0 value found
    assign LEDR[8:1] = 8'd0; //off
    
endmodule //binary_search_top