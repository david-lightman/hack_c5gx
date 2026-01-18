/*
    HackCPU.v
    Implementation of the Hack CPU as per the Hack computer architecture.
    This module integrates the A and D registers, ALU, and Program Counter (PC).
*/
module HackCPU (
    input  wire        clk,
    input  wire        reset,      // Active high reset
    input  wire [15:0] inM,        // Data from RAM
    input  wire [15:0] instruction,// Instruction from ROM
    output wire [15:0] outM,       // Data to RAM
    output wire        writeM,     // Write enable to RAM
    output wire [14:0] addressM,   // Address to RAM
    output wire [14:0] pc          // Address to ROM
);

    reg [15:0] A, D;
    reg [14:0] PC_reg;
    wire [15:0] alu_out, a_in;
    wire zr, ng;
    
    // Decoding
    wire is_C = instruction[15];
    wire is_A = ~instruction[15];
    
    // Control Bits (C-Inst)
    wire a_bit = instruction[12];
    wire d1 = instruction[5]; // Dest A
    wire d2 = instruction[4]; // Dest D
    wire d3 = instruction[3]; // Dest M
    wire j1=instruction[2], j2=instruction[1], j3=instruction[0]; // Jump

    // A Register
    wire load_A = is_A | (is_C & d1);
    assign a_in = is_A ? instruction : alu_out;
    
    always @(posedge clk or posedge reset) begin
        if (reset) A <= 0;
        else if (load_A) A <= a_in;
    end
    assign addressM = A[14:0];

    // D Register
    always @(posedge clk or posedge reset) begin
        if (reset) D <= 0;
        else if (is_C & d2) D <= alu_out;
    end

    // ALU
    HackALU alu (
        .x(D), .y(a_bit ? inM : A),
        .zx(instruction[11]), .nx(instruction[10]), 
        .zy(instruction[9]),  .ny(instruction[8]), 
        .f(instruction[7]),   .no(instruction[6]),
        .out(alu_out), .zr(zr), .ng(ng)
    );

    assign outM = alu_out;
    assign writeM = is_C & d3;

    // PC Logic
    wire jump = is_C & ((j1 & ng) | (j2 & zr) | (j3 & ~ng & ~zr));
    
    always @(posedge clk or posedge reset) begin
        if (reset) PC_reg <= 0;
        else if (jump) PC_reg <= A[14:0];
        else PC_reg <= PC_reg + 1'b1;
    end
    assign pc = PC_reg;

endmodule
