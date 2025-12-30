//EE 371 Lab4
//Nov 1, 2025


/*
Testbench applies reset, searches multiple values in binary search 
module by toggling start signal & setting SW inputs. 
Checks correct address results for present values and 
verifies behavior when value not in array
*/

`timescale 1ns / 1ps

module binary_search_tb;
    logic CLOCK_50;
    logic [3:0] KEY;
    logic [7:0] SW;
    logic [6:0] HEX0, HEX1;
    logic [9:0] LEDR;
    
    binary_search_top dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .LEDR(LEDR)
    );
    
    //clock
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end
	 
    initial begin
        KEY[0] = 1;  
        KEY[3] = 1; 
        SW = 8'd0;
        
        //reset
        @(posedge CLOCK_50);
        KEY[0] = 1'b0;  //assert reset
        @(posedge CLOCK_50);
        KEY[0] = 1'b1;  //unassert reset
        
        //search 80 at address 15
        @(posedge CLOCK_50);
        SW = 8'd80;
       // $display("[%0t] Test 1: SW=%d", $time, SW);
        @(posedge CLOCK_50);
        KEY[3] = 1'b0;  //start
        @(posedge CLOCK_50);
        KEY[3] = 1'b1;  //start release
        #2000;
        
        //search 160 at address 31
        @(posedge CLOCK_50);
        SW = 8'd160;
       // $display("[%0t] Test 2: SW=%d", $time, SW);
        @(posedge CLOCK_50);
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        KEY[3] = 1'b1;
        #2000;
        
        //search 5 at address 0
        @(posedge CLOCK_50);
        SW = 8'd5;
        //$display("[%0t] Test 3: SW=%d", $time, SW);
        @(posedge CLOCK_50);
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        KEY[3] = 1'b1;
        #2000;
        
        //search 50 at address 9
        @(posedge CLOCK_50);
        SW = 8'd50;
        //$display("[%0t] Test 4: SW=%d", $time, SW);
        @(posedge CLOCK_50);
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        KEY[3] = 1'b1;
        #2000;
        
        //search for 42 - not present in array
        @(posedge CLOCK_50);
        SW = 8'd42;
       // $display("[%0t] Test 5: SW=%d", $time, SW);
        @(posedge CLOCK_50);
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        KEY[3] = 1'b1;
        #2000;
        
        $stop;
    end
    
endmodule //binary_search_tb
