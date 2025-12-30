# ee371-digital-circuits-systems-design-labs
This repository contains EE/CSE 371 labs for Design of Digital Circuits and Systems at the University of Washington, implemented on FPGA using LabsLand, with accompanying reports detailing design, architecture and results.

Lab 1: A parking lot occupancy counter increments when a car enters and decrements when a car exits, differentiating between cars, pedestrians and invalid sequences. 

Lab 2: Introduced RAM usage in FPGA designs and explored multiple methods of instantiating RAM in SystemVerilog. Created RAM modules capable of reading and writing and implemented switching between target RAMs. 

Lab 3: Implemented musical output using an FPGA audio codec. Played audio from a .mif file, converted custom sounds to .mif using a Python script and built an infinite impulse response averaging filter with a FIFO buffer to reduce noise. 

Lab 4: Introduced ASMD design for modeling datapath and control. Implemented common programming algorithms on FPGA: counted ones in an 8-bit sequence and performed a binary search on a 32×8 RAM module based on user input. 

Lab 5: Introduced VGA graphics on FPGA. Used Bresenham’s line drawing algorithm to draw lines of any slope and direction on a pixel display. 

Final Project: Implemented Red Light Green Light, an interactive game with synchronized control and display logic, realized entirely in hardware on an FPGA. The design uses a modular FSM and datapath architecture to demonstrate how hardware executes real-time algorithms involving user input, randomness, and visual output through VGA graphics.
