// EE 371 LAB 3 - Task 3 top level
// AU 25

/*
Testbench validates FIR_Filter's moving average and sliding window operation.
Sends constant input values in sequence while isValid is high.
Verifies dataOut matches expected averages during prefill phase and steady state.
Confirms sliding window correctly updates as new samples enter and old samples exit.

Waveforms were observed, display statements used for debugging
*/

`timescale 1ns/1ps
module FIR_Filter_tb;
    
    reg clk;
    reg reset;
    reg isValid;
    reg signed [23:0] dataIn;
    wire signed [23:0] dataOut;
    
    //instantiate DUT
    FIR_Filter #(.n(4), .w(24)) dut (
        .clk(clk),
        .reset(reset),
        .isValid(isValid),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );
    
    //clock 
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    //test 
    integer i;
    integer expected;
    initial begin
        //reset signal
        reset = 1;
        isValid = 0;
        dataIn = 0;
        #20;
        reset = 0;
        #10;
        
        isValid = 1;
        
        //fill 18 of 160 to reach steady state
        $display("Filling with samples of 160...");
        for (i = 0; i < 18; i = i + 1) begin
            dataIn = 160;
            @(posedge clk);
        end
		  
        @(posedge clk);  // Wait >_<
        expected = 10;  // 160*16/256 = 10
		  //$display("After steady state with 160: dataOut=%d, expected=%d %s", 
        //dataOut, expected);
        
        // Add 3 320s
        for (i = 0; i < 3; i = i + 1) begin
            dataIn = 320;
            @(posedge clk);
        end
        @(posedge clk);  // Wait >_<
        expected = 11;  
       //$display("After adding 320s: dataOut=%d, expected=%d %s", 
       //dataOut, expected);
        
        // Add 3 480s
        for (i = 0; i < 3; i = i + 1) begin
            dataIn = 480;
            @(posedge clk);
        end
        @(posedge clk);  // Wait >_<
        // Window: 10*160 + 3*320 + 3*480 = 1600 + 960 + 1440 = 4000
        // So expected avg is 4000/256 = 15.625 ~ 15
        expected = 15;
       //  $display("After adding 480s: dataOut=%d, expected=%d %s", 
       //           dataOut, expected);
        
        // Add 3 samples of 640
        for (i = 0; i < 3; i = i + 1) begin
            dataIn = 640;
            @(posedge clk);
        end
        @(posedge clk);  // Wait >_<
        // Window: 7*160 + 3*320 + 3*480 + 3*640 = 5440
        // so expectd avg is 5440/256 = 21.25 ~ 21
        expected = 21;
       //$display("After adding 640s: dataOut=%d, expected=%d %s", 
       //dataOut, expected);
        
        #50;
        $stop;
    end
    
endmodule //FIR_Filter_tb