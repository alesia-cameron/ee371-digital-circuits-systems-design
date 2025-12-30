//EE 371 Lab4
//Nov 1, 2025


/* Binary Search Datapath
 * 
 * Module implements datapath for binary search algorithm from task 2. It performs all arithmetic
 * operations, comparisons, and register management. It maintains search bounds (low/high),
 * calculates midpoints, interfaces with memory, and tracks whether the target value is found.
 * 
 * Inputs:
 *   clk: clock signal, using clock 50 for simulations and clock divider to 3hz for board
 *   reset: reset signal
 *   A_in: 8bit target val to search for from input switches
 *   mem_data: 8bit data read from memory at current address
 *   load_A: 1bit control signal to load A register with A_in
 *   init_bounds: 1bit control signal to init search bounds for the array size 32 
 *   update_mid: 1bit control signal to register mid as memory address
 *   update_lower: 1bit control signal to move lower bound up to search in upper half (low = mid + 1)
 *   update_upper: 1bit control signal to move upper bound down to search in lower half (high = mid - 1)
 *   set_found: 1bit control signal to set found and save location
 *   clear_found: 1bit control signal to clear found 
 * 
 * Outputs:
 *   mem_addr: 5bit registered address sent to mem module
 *   low: 5bit current lower boundsearch range
 *   high: 5bit current upper bound search range
 *   mid: 5bit calculated midpoint (low + high) / 2
 *   loc: 5bit address where target val found
 *   found: 1bit flag target val found in array
 *   search_done: 1bit flag search space exhausted (low > high)
 *   A_eq_mem: 1bit comparison result A equals mem_data
 *   A_lt_mem: 1bit comparison result A less than mem_data
 *   A: 8bit current value of search target register
 */
module binary_search_datapath (
    input logic clk,
    input logic reset,
    input logic [7:0] A_in,     //input value to search 
    input logic [7:0] mem_data, //data read from memory at current addr being searched 
    input logic load_A,         //control sig to load A register
    input logic init_bounds,    //control sig init low high bounds
    input logic update_mid,     //control sig to register mid as memory address
    input logic update_lower,   //control sig move lower bound up
    input logic update_upper,   //control sig move upper bound down
    input logic set_found,      //control sig set found 
    input logic clear_found,    //control sig clear found 
    
	 output logic [4:0] mem_addr,  //address sent to memory 
    output logic [4:0] low,      //lower search range
    output logic [4:0] high,     //upper bound search range
    output logic [4:0] mid,      //Midpoint search range which is  (low+high)/2
    output logic [4:0] loc,      //Location where target 'A' value was found
    output logic found,          //target value found
    output logic search_done,    //search space exhausted
    output logic A_eq_mem,       //A == mem_data
    output logic A_lt_mem,       //A < mem_data
    output logic [7:0] A         //Search val register
);
    //A register store the target val searched 
    always_ff @(posedge clk) 
	 begin
        if (load_A)
            A <= A_in; //loads input target val
    end
    
    //bounds registers track search range low, high and updates it 
    always_ff @(posedge clk) begin
        if (init_bounds) begin
            low <= 5'd0;    //start array
            high <= 5'd31;  //end of array 
        end else if (update_lower) begin
            low <= mid + 5'd1;  //search upper
        end else if (update_upper) begin
            high <= mid - 5'd1; //search lower 
        end
    end
    
    //mid calc computes midpoint of low, high ie the midpoitn of the search range
    logic [5:0] mid_temp;  //6 bitshold sum without overflow
    always_comb begin
        mid_temp = {1'b0, low} + {1'b0, high};  //extra bit
        mid = mid_temp[5:1];  //divide by 2 right shift
    end
    
    //found  and location register
    always_ff @(posedge clk) begin
        if (clear_found) begin
            found <= 1'b0;
            loc <= 5'd0;
        end else if (set_found) begin
            found <= 1'b1;
            loc <= mid;  //save where found 
        end
    end
    
    //memory address register  sends mid to memory and 1 cycle delay
    always_ff @(posedge clk) begin
        if (update_mid)
            mem_addr <= mid;
    end
    
    //comparison logic compares A with memory data
    assign A_eq_mem = (A == mem_data);       //found match
    assign A_lt_mem = (A < mem_data);        //A smaller, search left
    assign search_done = (low > high);       //search space empty
    
endmodule//binary_search_datapath