//EE 371 Lab2
//Oct 10, 2025

/*
Input:
Address [4:0] 5-bit address line connected to task1 module  
clk 1-bit clock signal 
DataIn [2:0] 3-bit data input 
Write  1-bit control signal (1 = write, 0 = read)  

Output:
DataOut [2:0] 3-bit data output 

Description: Task 3 incorporates an IP catalog designed M10K 32x3 dual 
port RAM with separate addresses for reading and writing alongside the 
single-port RAM from Task 2. A Memory Initialization File, ram32x3.mif, 
is created and initialized with integer values. A new top level module, 
task3_toplevel includes Task 2 single port logic alongside the logic for 
the dual port RAM. A new switch, SW9, selects between the two memory 
modules for operation and chooses one. When SW9 = 0, the design utilizes
task 2 memory, writing and reading data from the single-port RAM. 
When SW9= 1, it utilizes Task 3 memory where the dual-port RAM 
(ram32x3port2) allows simultaneous read and write using separate address ports. 
The output data between the two modules (DataTask2Out or DataTask3Out) 
is selected using a MUX and displayed on a seven segment display. 
*/

//vsim work.task1_tb -L altera_mf_ver -L lpm_ver -L work //to run on modlesim

`timescale 1ns/1ps
module lab2toplevel_Part3_tb;
    logic [9:0] SW;
    logic [4:0] KEY;
    logic CLOCK_50;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    lab2toplevel_Part3 dut (
        .SW(SW),
        .KEY(KEY),
        .CLOCK_50(CLOCK_50),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0)
    );

    initial CLOCK_50 = 0;
    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        //initialize switches and keys
        SW[0]=0; SW[1]=0; SW[2]=0; SW[3]=0; SW[4]=0; SW[5]=0; SW[6]=0; SW[7]=0; SW[8]=0; SW[9]=0;
        KEY[0]=1; KEY[1]=1; KEY[2]=1; KEY[3]=1;

        //test reset pulse
        @(posedge CLOCK_50);
        KEY[3]=0;
        @(posedge CLOCK_50);
        KEY[3]=1;

        //test normal write Task 2
        @(posedge CLOCK_50);
        SW[9]=0;
        SW[8]=0; SW[7]=0; SW[6]=0; SW[5]=0; SW[4]=1;
        SW[3]=0; SW[2]=1; SW[1]=0;
        SW[0]=1;

        //test different data input combination
        @(posedge CLOCK_50);
        SW[8]=0; SW[7]=1; SW[6]=0; SW[5]=1; SW[4]=0;
        SW[3]=1; SW[2]=1; SW[1]=0;
        SW[0]=1;

        // test switching to Task 3 mode
        @(posedge CLOCK_50);
        SW[9]=1;
        SW[8]=1; SW[7]=0; SW[6]=1; SW[5]=0; SW[4]=0;
        SW[3]=1; SW[2]=0; SW[1]=1;
        SW[0]=1;

        //test other data write in Task 3
        @(posedge CLOCK_50);
        SW[8]=1; SW[7]=1; SW[6]=1; SW[5]=1; SW[4]=1;
        SW[3]=0; SW[2]=1; SW[1]=0;
        SW[0]=1;

        //test return to Task 2 mode
        @(posedge CLOCK_50);
        SW[9]=0;
        SW[8]=0; SW[7]=0; SW[6]=1; SW[5]=0; SW[4]=1;
        SW[3]=1; SW[2]=0; SW[1]=0;
        SW[0]=1;

        @(posedge CLOCK_50);
        $stop;
    end
endmodule
