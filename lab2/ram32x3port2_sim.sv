// ram32x3port2_sim.sv
module ram32x3port2_sim (
    input clock,
    input [2:0] data,
    input [4:0] rdaddress,
    input [4:0] wraddress, 
    input wren,
    output reg [2:0] q
);
    
    reg [2:0] memory [0:31];
    
    // Initialize with test data
    initial begin
        $display("SIM_RAM: Initializing with test data...");
        for (int i = 0; i < 32; i++) begin
            memory[i] = i[2:0];  // Address 0=0, 1=1, 2=2, etc.
        end
    end
    
    // Write operation
    always_ff @(posedge clock) begin
        if (wren) begin
            memory[wraddress] <= data;
            $display("SIM_RAM: Writing %0d to address %0d", data, wraddress);
        end
    end
    
    // Read operation
    always_ff @(posedge clock) begin
        q <= memory[rdaddress];
        if (rdaddress < 5) begin
            $display("SIM_RAM: Reading %0d from address %0d", memory[rdaddress], rdaddress);
        end
    end
    
endmodule