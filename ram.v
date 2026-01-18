/* 
    HackRAM Module
    ---------------
    A 32K x 16-bit RAM module for the Hack computer architecture.
    This module supports synchronous read and write operations.
*/
module HackRAM (
    input  wire        clk,
    input  wire [14:0] address,
    input  wire [15:0] data_in,
    input  wire        write_enable,
    output reg [15:0] data_out
);
    `ifdef ALTERA_RESERVED_QIS
        (* ramstyle = "M10K" *) 
    `endif
    reg [15:0] memory [0:16383]; // 32K

    always @(posedge clk) begin
        if (write_enable && address < 16384) 
            memory[address] <= data_in;
        data_out <= memory[address];
    end
endmodule
