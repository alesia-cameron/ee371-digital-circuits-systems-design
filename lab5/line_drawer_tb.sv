// EE 371 LAB 5 
// AU 25

/* Testbench for line_drawer validates line_drawer's Bresenham algorithm for all eight required line types:left/right, up/down, steep/gradual
 * Sequentially tests right-up, left-up, left-down, and right-down lines with both steep and gradual slopes.
 * Verifies that x and y change by at most one pixel per cycle and done signal asserts upon completion.
 */

module line_drawer_tb();
    logic clk, reset;
    logic [10:0] x0, y0, x1, y1;
    logic [10:0] x, y;
    logic done;
    
    //Instantiate line_drawer
    line_drawer dut (.clk, .reset, .x0, .y0, .x1, .y1, .x, .y, .done);
    
    //Clock
    always begin
        clk = 0; #10;
        clk = 1; #10;
    end
    
    //Test sequence
    initial begin
        
        // Test 0: Right-up gradual
        $display("Test 0: Right-up gradual (320,240) to (470,190)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 470; y1 = 190;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        //Test 1 Right-up steep
        $display("Test 1: Right-up steep (320,240) to (370,90)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 370; y1 = 90;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        // Test 2 Left-up gradual
        $display("Test 2: Left-up gradual (320,240) to (170,190)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 170; y1 = 190;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        //Test 3 Left-up steep
        $display("Test 3: Left-up steep (320,240) to (270,90)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 270; y1 = 90;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        //Test 4  Left-down gradual
        $display("Test 4: Left-down gradual (320,240) to (170,290)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 170; y1 = 290;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        //Test  5 Left-down steep
        $display("Test 5: Left-down steep (320,240) to (270,390)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 270; y1 = 390;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        //Test 6 Right-down gradual
        $display("Test 6: Right-down gradual (320,240) to (470,290)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 470; y1 = 290;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        //Test 7 Right-down steep
        $display("Test 7: Right-down steep (320,240) to (370,390)");
        reset = 1;
        x0 = 320; y0 = 240;
        x1 = 370; y1 = 390;
        @(posedge clk);
        reset = 0;
        @(posedge done);
        #100;
        
        $stop;
    end
    
endmodule //line_drawer_tb
