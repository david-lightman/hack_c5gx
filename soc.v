`define mem_RAM         15'h4000
`define mem_SW          15'h6001
`define mem_KEYS        15'h6002
`define mem_LEDG        15'h6003
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

    // GPIO
    input [7:0]        i_sw,        // switches {9:2}
    input [3:0]        i_keys,      // keys {3:0}
    output reg [7:0]   o_ledg,      // green-leds {7:0}

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
    // multiplexor for memory-mapped I/O
    wire [15:0] cpu_inM_mux = (cpu_addressM  < `mem_RAM) ? ram_out :
                   (cpu_addressM == `mem_SW)  ? {8'b0, i_sw} :
                   (cpu_addressM == `mem_KEYS)? {12'b0, i_keys} :
                                                16'b0;

    HackCPU cpu (
        .clk(i_clk),
        .reset(i_reset),
        .inM(cpu_inM_mux),
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
    HackROM #(.INIT_FILE("rom.hack")) rom (
        .address(cpu_pc),
        .clk(i_clk_mem), 
        .q(instruction)
    );

    //--------------------------------------------------------------
    // Data Memory (RAM)
    //    Also clocked by clk_mem.
    //--------------------------------------------------------------
    wire wen = (cpu_addressM < `mem_RAM) && cpu_writeM;
    HackRAM ram (
        .clk(i_clk_mem),
        .address(cpu_addressM),
        .data_in(cpu_outM),
        .write_enable(wen),
        .data_out(ram_out)
    );

    // GPIO Outputs
    // control synchronous io (e.g. LED)
    always @(posedge i_clk_mem or posedge i_reset ) begin
        // reset
        if (i_reset) begin
            o_ledg <= 8'b0;
        end 
        
        else begin
            case (cpu_addressM)
                `mem_LEDG: begin
                    if (cpu_writeM) begin
                        o_ledg <= cpu_outM[7:0];
                    end
                end
                default: ;
            endcase
        end
    end

endmodule 
