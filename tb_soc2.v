`timescale 1ns / 1ps
/* 
Test program (tb_soc2.hack):
0011000000111001
1110110000010000
0000000000000000
1110001100001000
0000000000001010
1110110000010000
0000000000010100
1110000010010000
0000000000000001
1110001100001000
0000000000000101
1110110000010000
0000000000000101
1110010011010000
0000000000000010
1110001100001000
0000000000010110
1110001100000010
0000000000000011
1110111010001000
0000000000011000
1110101010000111
0000000000000011
1110111111001000
0000000000000101
1110110000010000
0000000000010000
1110001100001000
0000000000000000
1110110000010000
0000000000010001
1110001100001000
0000000000010000
1111110000010000
0000000000101010
1110001100000010
0000000000010001
1111000010001000
0000000000010000
1111110010001000
0000000000100000
1110101010000111
0000000000010001
1111110000010000
0000000000000100
1110001100001000
0000000000101110
1110101010000111
*/

module tb_soc2;

    // Inputs
    reg clk;
    reg clk_mem;
    reg reset;

    // Outputs
    wire [14:0] pc_out;
    wire [15:0] instruction;
    wire [14:0] addressM;

        // Instantiate SOC
    soc uut (
        .i_clk(clk),
        .i_clk_mem(clk_mem),
        .i_reset(reset),
        
        .i_sw(8'b0),
        .i_keys(4'b0),
        .o_ledg(), // Leave unconnected
        
        .o_pc_out(pc_out),
        .o_instruction(instruction),
        .o_addressM(addressM)
    );


    // Clock Generation
    always begin
        clk = 0; clk_mem = 1; #50;
        clk = 1; clk_mem = 0; #50;
    end

    integer cycles = 0;

    initial begin
        $display("--------------------------------------------------------------------------");
        $display("STARTING COMPREHENSIVE CPU TEST");
        $display("  This test requires tb_soc2.hack to be loaded into instruction memory.");
        $display("--------------------------------------------------------------------------");
        
        // 1. Reset
        reset = 1;
        #200;
        reset = 0;
        
        // 2. Run
        // The test program halts at PC=46. We set a cycle limit to prevent hanging.
        while (pc_out !== 15'd46 && cycles < 1000) begin
            @(posedge clk);
            cycles = cycles + 1;
        end
        
        // Allow the final write to settle
        #200;

        $display("Simulation halted at PC: %d (Cycles: %d)", pc_out, cycles);
        $display("-------------------------------------------------------------");

        // 3. Verify RAM Contents
        
        // Test 1: Load 12345 into RAM[0]
        if (uut.ram.memory[0] === 16'd12345) 
            $display("[PASS] Test 1: Constant Load (RAM[0]=12345)");
        else 
            $display("[FAIL] Test 1: Constant Load. Expected 12345, Got %d", uut.ram.memory[0]);

        // Test 2: 10 + 20 = 30 into RAM[1]
        if (uut.ram.memory[1] === 16'd30) 
            $display("[PASS] Test 2: ALU Add (10+20=30)");
        else 
            $display("[FAIL] Test 2: ALU Add. Expected 30, Got %d", uut.ram.memory[1]);

        // Test 3: 5 - 5 = 0 into RAM[2]
        if (uut.ram.memory[2] === 16'd0) 
            $display("[PASS] Test 3: ALU Sub (5-5=0)");
        else 
            $display("[FAIL] Test 3: ALU Sub. Expected 0, Got %d", uut.ram.memory[2]);

        // Test 4: Jump if Zero (should write 1 to RAM[3], -1 on fail)
        if (uut.ram.memory[3] === 16'd1) 
            $display("[PASS] Test 4: JEQ Conditional Jump");
        else 
            $display("[FAIL] Test 4: JEQ Jump. Expected 1, Got %d", uut.ram.memory[3]);

        // Test 5: Sum Loop 1..5 = 15 into RAM[4]
        if (uut.ram.memory[4] === 16'd15) 
            $display("[PASS] Test 5: Loop Logic (Sum 1..5 = 15)");
        else 
            $display("[FAIL] Test 5: Loop. Expected 15, Got %d", uut.ram.memory[4]);

        $display("-------------------------------------------------------------");
        $stop;
    end

endmodule
