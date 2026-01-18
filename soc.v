/* 
    soc.v

    Top-level System-on-Chip module integrating the Hack CPU,
    instruction memory (ROM), and data memory (RAM).

    Inputs:
        - i_clk: Main clock signal for the CPU.
        - i_clk_mem: Clock signal for memory components.
        - i_reset: Reset signal for the CPU.

    Outputs:
        - o_pc_out: Current program counter value from the CPU.
        - o_instruction: Current instruction fetched from instruction memory.
        - o_addressM: Address for data memory access.

    Note:
        The instruction memory is initialized with a program file "rom.hack".
*/
module soc (
    input wire          i_clk,
    input wire          i_clk_mem,
    input wire          i_reset,

    output [17:0]       o_pc_out,
    output [15:0]       o_instruction,
    output [14:0]       o_addressM 
);

    // Interconnect Signals
    wire [15:0] instruction;
    wire [15:0] ram_out;
    wire [15:0] cpu_outM;
    wire        cpu_writeM;
    wire [14:0] cpu_addressM;
    wire [14:0] cpu_pc;

    assign o_instruction = instruction;
    assign o_addressM = cpu_addressM;

    //--------------------------------------------------------------
    // CPU
    //--------------------------------------------------------------
    HackCPU cpu (
        .clk(i_clk),
        .reset(i_reset),
        .inM(ram_out),
        .instruction(instruction),
        .outM(cpu_outM),
        .writeM(cpu_writeM),
        .addressM(cpu_addressM),
        .pc(cpu_pc)
    );

    // Output PC for visibility
    assign o_pc_out = cpu_pc;

    //--------------------------------------------------------------
    // Instruction Memory (ROM)
    //    Clocked by clk_mem to provide data "instantly" relative 
    //    to the next CPU rising edge.
    //--------------------------------------------------------------
    // REPLACE "Pong.mif" with your actual program file
    HackROM #(.INIT_FILE("rom.hack")) rom (
        .address(cpu_pc),
        .clk(i_clk_mem), 
        .q(instruction)
    );

    //--------------------------------------------------------------
    // Data Memory (RAM)
    //    Also clocked by clk_mem.
    //--------------------------------------------------------------
    HackRAM ram (
        .clk(i_clk_mem),
        .address(cpu_addressM),
        .data_in(cpu_outM),
        .write_enable(cpu_writeM),
        .data_out(ram_out)
    );

endmodule 
