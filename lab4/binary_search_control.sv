//EE 371 Lab4
//Nov 1, 2025


/* Binary Search Control FSM
 * 
 * This module implements the control fsm for binary search from task 2 It
 * manages state transitions and generates the control signals for the datapath. It also coordinates
 * the search sequence including initialization, memory access timing (with 2-cycle latency as the data is in registers),
 * comparison of the input 'A' with the value in the search address, and result reporting.
 * 
 * Inputs:
 *   clk: 1 bit system clock signal, using clock 50 for simulations and clock divider to 3hzs for board
 *   reset: 1 bit synchronous reset, the returnsthe FSM to idle state
 *   start: 1 bit pulse to begin new search operation
 *   A_eq_mem: 1 bit status variable from datapath that is indicating if search value at search addr equals memory data 'A'
 *   A_lt_mem : 1-bit status variable from datapath that is indicating if search value at addr is less than memory data 'A'
 *   search_done: 1-bit status variable from datapath that is indicating if search space exhausted (i.e.: low > high)
 * 
 * Outputs:
 *   load_A: 1-bit control signal to load search value 'A' from input switches
 *   init_bounds: 1-bit control signal to initialize search bounds for the array of size 32 (low=0, high=31)
 *   update_mid: 1-bit control signal to calculate and register middle address for binary searching
 *   update_lower: 1-bit control signal to update lower bound and increment it to above middle to search in upper half (low = mid + 1)
 *   update_upper: 1-bit control signal to update upper bound  and decrement it to below the middle to search in lower half(high = mid - 1)
 *   set_found: 1-bit control signal to mark value as found and save location
 *   clear_found: 1-bit control signal to clear found flag
 *   done: 1-bit output indicating  the binary search operation complete
 * 
 * States: idle, init, mid_calculate, mem_wait1, mem_wait2, compare, doneState
 */
module binary_search_control (
    input logic clk,
    input logic reset,
    input logic start,                //start the binary search
    input logic A_eq_mem,             //indicates A equals memory value at mid
    input logic A_lt_mem,             //indicates A is less than memory value at mid
    input logic search_done,          //indicates that we've exhausted the search space low > high
    output logic load_A,               //send a signal to load search value A from input
    output logic init_bounds,          //init array bounds based on our .nif with low=0, high=31
    output logic update_mid,           //send signal to calculate and register new middle address
    output logic update_lower,         //send signal to move lower bound up (mid + 1)
    output logic update_upper,         //send signal to move upper bound down (mid - 1)
    output logic set_found,            //mark val as found
    output logic clear_found,          //clear found
    output logic done                  //sets the search complete signal
);
    typedef enum logic [2:0] {
        idle,       
        init,       
        mid_calculate,   
        mem_wait1,  //1st memory wait
        mem_wait2,  //2nd cycle of memory wait-- had to change this because I was accounting for some memory latency, but I only had one state. this made the results wrong for a very long time, and I couldn't figure it out for a while)
        compare,    
        doneState  
    } state_t;
    
    state_t curr_state, next_state;
    
    always_ff @(posedge clk) 
	 begin
        if (reset)
            curr_state <= idle;
        else
            curr_state <= next_state;
    end
    
    //next state logic indicates what each states next state is
    always_comb 
	 begin
        case (curr_state)
            idle: 
                next_state = start ? init : idle;
            
            init: 
                next_state = mid_calculate;
            
            mid_calculate: 
                next_state = mem_wait1;  //start waiting for memory, this is the first cycle wait
            
            mem_wait1: 
                next_state = mem_wait2;  //continue waiting for the secong wait cycle
            
            mem_wait2:
                next_state = compare;    //data should now be ready after 2 wait cycles
            
            compare: begin  
                if (A_eq_mem || search_done)
                    next_state = doneState; //goes to done if we found something equal to A inmemory, or if we've exhausted all our search options
                else
                    next_state = mid_calculate; 
            end
            
            doneState: 
                next_state = start ? doneState : idle;
            
            default: 
                next_state = idle;
        endcase
    end
    
    //output logic, combinational logic indicates what each state does
    always_comb 
	 begin
        load_A = 1'b0;
        init_bounds = 1'b0;
        update_mid = 1'b0;
        update_lower = 1'b0;
        update_upper = 1'b0;
        set_found = 1'b0;
        clear_found = 1'b0;
        done = 1'b0;
        
        case (curr_state)
            idle: begin
                clear_found = 1'b1; //clear the found and ensure off. prevents mixup from a previous round
            end
            
            init: begin
                load_A = 1'b1;      //load the value of A from the input and set to 1
                init_bounds = 1'b1; //initialize seach bounds for a 32 word array, 0 to 32
            end
            
            mid_calculate: begin
                update_mid = 1'b1; 
            end
            
            mem_wait1, mem_wait2: begin
                //wait for memory for a clock cycle each
            end
            
            compare: begin
                if (A_eq_mem) begin
                    set_found = 1'b1;   //turn the found flag on if the memory value is equal to A
                end else if (!search_done) 
					 begin
                    if (A_lt_mem)
                        update_upper = 1'b1; //updates 
                    else
                        update_lower = 1'b1;
                end
            end
            
            doneState: begin
                done = 1'b1;
            end
        endcase
    end
    
endmodule //binary_search_control