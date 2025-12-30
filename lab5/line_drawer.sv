/*
EE/CSE 371
Nov 16, 2025
Lab 5 
*/

/* Given two points on the screen this module draws a line between
 * those two points by coloring necessary pixels
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   reset  - resets the module and starts over the drawing process
 *   x0     - x coordinate of the first end point
 *   y0     - y coordinate of the first end point
 *   x1     - x coordinate of the second end point
 *   y1     - y coordinate of the second end point
 *
 * Outputs:
 *   x      - x coordinate of the pixel to color
 *   y      - y coordinate of the pixel to color
 *   done   - flag that line has finished drawing
 
Description: The module steps through a line one pixel at a time using a hardware version of Bresenham’s algorithm.
When reset high, it compares horizontal and vertical differences to see whether line is steep, and if so it 
swaps coordinates so progression always moves along dominant axis. It also decides direction, picks start and 
end points and initializes error term along with step used to move vertically. 
Each clock tick outputs one pixel coordinate. The algorithm keeps running error
nudging secondary axis when accumulated error rises above zero. Once the advancing coordinate reaches 
end point, the module asserts done */
 
module line_drawer(clk, reset, x0, y0, x1, y1, x, y, done);
    input logic clk, reset;
    input logic [10:0] x0, y0, x1, y1;
    output logic done;
    output logic [10:0] x, y;
    
    logic signed [11:0] error;
    logic [10:0] x_plot, y_plot, x_end;
    logic [10:0] deltax, deltay;
    logic signed [11:0] y_step;
    logic is_steep;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            //check if steep abs(y1-y0) > abs(x1-x0)
            is_steep <= ((y1 > y0 ? y1 - y0 : y0 - y1) > (x1 > x0 ? x1 - x0 : x0 - x1));
            
            //init based on steepness and direction
            if ((y1 > y0 ? y1 - y0 : y0 - y1) > (x1 > x0 ? x1 - x0 : x0 - x1)) begin
                //if teep swap x and y
                if (y0 > y1) begin
                    x_plot <= y1;
                    y_plot <= x1;
                    x_end <= y0;
                    deltax <= y0 - y1;
                    deltay <= (x0 > x1) ? (x0 - x1) : (x1 - x0);
                    y_step <= (x1 < x0) ? 12'sd1 : -12'sd1;
                end else begin
                    x_plot <= y0;
                    y_plot <= x0;
                    x_end <= y1;
                    deltax <= y1 - y0;
                    deltay <= (x1 > x0) ? (x1 - x0) : (x0 - x1);
                    y_step <= (x0 < x1) ? 12'sd1 : -12'sd1;
                end
            end else begin
                //not steep: normal orientation
                if (x0 > x1) begin
                    x_plot <= x1;
                    y_plot <= y1;
                    x_end <= x0;
                    deltax <= x0 - x1;
                    deltay <= (y0 > y1) ? (y0 - y1) : (y1 - y0);
                    y_step <= (y1 < y0) ? 12'sd1 : -12'sd1;
                end else begin
                    x_plot <= x0;
                    y_plot <= y0;
                    x_end <= x1;
                    deltax <= x1 - x0;
                    deltay <= (y1 > y0) ? (y1 - y0) : (y0 - y1);
                    y_step <= (y0 < y1) ? 12'sd1 : -12'sd1;
                end
            end
            
            error <= 12'sd0;  //will be set properly in first cycle
            done <= 1'b0;
            
        end else if (!done) begin
            //init error on first active cycle
            if (error == 12'sd0 && x_plot <= x_end) begin
                error <= -$signed({1'b0, deltax[10:1]});  // -(deltax/2)
            end
            
            //output current pixel
            if (is_steep) begin
                x <= y_plot;
                y <= x_plot;
            end else begin
                x <= x_plot;
                y <= y_plot;
            end
            
            //check if done
            if (x_plot == x_end) begin
                done <= 1'b1;
            end else begin
                //update for next pixel
                error <= error + $signed({1'b0, deltay});
                
                if ((error + $signed({1'b0, deltay})) >= 12'sd0) begin
                    y_plot <= y_plot + y_step[10:0];
                    error <= error + $signed({1'b0, deltay}) - $signed({1'b0, deltax});
                end
                
                x_plot <= x_plot + 11'd1;
            end
        end
    end
endmodule  // line_drawer
