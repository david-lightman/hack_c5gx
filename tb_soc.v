`timescale 1ns / 1ps

module tb_soc;
    reg clk;
    reg clk_mem;
    reg reset;
    wire [17:0] pc_out; // Note: Your soc uses 15 bits, wire should match
    wire [15:0] instruction;
    wire [14:0] addressM;

    soc uut (
        .i_clk(clk),
        .i_clk_mem(clk_mem),
        .i_reset(reset),
        .o_pc_out(pc_out),
        .o_instruction(instruction),
        .o_addressM(addressM)
    );

    // Clock Generation
    always begin
        clk = 0; clk_mem = 1; #50;
        clk = 1; clk_mem = 0; #50;
    end

    initial begin
        reset = 1;
        #200;
        reset = 0;
        #2000;
        
        if (uut.ram.memory[0] === 16'd30)
            $display("SUCCESS: RAM[0] contains 30.");
        else
            $display("FAILURE: RAM[0] contains %d.", uut.ram.memory[0]);
            
        $stop;
    end
endmodule
