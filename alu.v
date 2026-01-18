/* alu.v
    Hack Computer ALU implementation in Verilog
    Inputs:
      x, y : 16-bit input values
      zx   : zero the x input
      nx   : negate the x input
      zy   : zero the y input
      ny   : negate the y input
      f    : function code (1 for add, 0 for and)
      no   : negate the output
    Outputs:
      out  : 16-bit output result
      zr   : 1 if out is zero, else 0
      ng   : 1 if out is negative, else 0
*/
module HackALU (
    input  wire [15:0] x, y,
    input  wire        zx, nx, zy, ny, f, no,
    output wire [15:0] out,
    output wire        zr, ng
);
    wire [15:0] x1 = zx ? 16'b0 : x;
    wire [15:0] x2 = nx ? ~x1   : x1;
    wire [15:0] y1 = zy ? 16'b0 : y;
    wire [15:0] y2 = ny ? ~y1   : y1;
    wire [15:0] res = f ? (x2 + y2) : (x2 & y2);
    wire [15:0] final = no ? ~res : res;
    
    assign out = final;
    assign zr = (final == 0);
    assign ng = final[15];
endmodule
