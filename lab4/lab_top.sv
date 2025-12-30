//EE 371 Lab4
//Nov 1, 2025


/* 
Combined Top Module chooses between two tasks
SW9 = 0 bit counter algorithm Task 1
SW9 = 1 binary search Task 2

Inputs:
SW[7:0] for input of 8 bit binary num

Outputs:
LEDR0: shows if value was found for task 2, 1 bit output, not used in task1
LEDR9: shows if computation of no. of 1's was done in task 1, 
		 shows if search completed in task 2 one bit output
HEX0: displays num of 1's in input number for task 1, 
		displays ones place of address of found data for task 2, 7 bit output
HEX1: displays tens place of address found in task 2, 
		not used in task 1, 7 bit output
 */
module lab_top (
    input logic CLOCK_50,
    input  logic [3:0] KEY,
    input  logic [9:0] SW,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3,
    output logic [6:0] HEX4,
    output logic [6:0] HEX5,
    output logic [9:0] LEDR
);
    //clock divider that uses provided clock divider module from lab 1 (or lab 2 I don't remember) 
    logic [31:0] divided_clocks;
    clock_divider clk_div (
        .clock(CLOCK_50),
        .divided_clocks(divided_clocks)
    );
    
    //~3Hz clock for slow operation to ensure we can see output
    logic slow_clock;
    assign slow_clock = divided_clocks[22];
    
    logic taskno;
    assign taskno = SW[9];  //task selection switch with 0=bit counter, 1=binary search
    
    //Task 1 output signals
    logic [6:0] hex0_task1;
    logic [9:0] ledr_task1;
    
    //Task 2 output signals
    logic [6:0] hex0_task2, hex1_task2;
    logic [9:0] ledr_task2;
    
    //task 1 instance of  bit counter using slow clock
    bit_counting_algorithm task1 (
		 .CLOCK_50(CLOCK_50),
		 .KEY(KEY),
		 .SW(SW[7:0]),
		 .HEX0(hex0_task1),
		 .HEX1(),
		 .HEX2(),
		 .HEX3(),
		 .HEX4(),
		 .HEX5(),
		 .LEDR(ledr_task1)
);
    
    //task 2 instance of binary search using slow clock
    binary_search_top task2 (
        .CLOCK_50(slow_clock),
        .KEY(KEY),
        .SW(SW[7:0]),
        .HEX0(hex0_task2),
        .HEX1(hex1_task2),
        .LEDR(ledr_task2)
    );
    
    //choose out based on SW9 selection with 0 task 1 and 1task 2. 
	 //set what LED's and HEX displays are used
    always_comb begin
        if (taskno == 1'b0) 
		  begin
            //Task 1 selected, set up board for bit counter outputs
            HEX0 = hex0_task1;
            HEX1 = 7'b1111111;  // Off
            LEDR = ledr_task1;
        end else 
		  begin
            //Task 2 selected, set up board for binary search outputs
            HEX0 = hex0_task2;
            HEX1 = hex1_task2;
            LEDR = ledr_task2;
        end
    end
	 
    
    //turn off unused displays 
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    
endmodule //lab_top



