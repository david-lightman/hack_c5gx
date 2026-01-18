/*
    HackROM.v

    A 32K x 16-bit read-only memory module for the Hack computer.
    The contents of the ROM are initialized from a specified file.

    Parameters:
        INIT_FILE: The file from which to initialize the ROM contents (default: "rom.hack").

    Inputs:
        address: 15-bit address input to select the memory location.
        clk: Clock input for synchronous read operation.

    Outputs:
        q: 16-bit data output corresponding to the selected address.
*/
module HackROM #(
    parameter INIT_FILE = "rom.hack"
)(
    input  wire [14:0] address,
    input  wire        clk,
    output reg [15:0] q
);

    // force M10K block RAM style on Altera FPGAs
    `ifdef ALTERA_RESERVED_QIS
        (* ramstyle = "M10K" *) 
    `endif
    reg [15:0] memory [0:32767]; // 32K

    initial $readmemb(INIT_FILE, memory);

    always @(posedge clk) begin
        q <= memory[address];
    end
endmodule
