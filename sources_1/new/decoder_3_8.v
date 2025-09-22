`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/28 20:36:57
// Design Name: 
// Module Name: decoder_3_8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decoder_3_8(
    a,
    b,
    c,
    out
   );
   
   input a;
   input b;
   input c;
   output [7:0]out;
   reg[7:0]out;
   
   always@(*)begin
        case({a,b,c})
            3'b000:out=8'b11111110;
            3'b001:out=8'b11111101;
            3'b010:out=8'b11111011;
            3'b011:out=8'b11110111;
            3'b100:out=8'b11101111;
            3'b101:out=8'b11011111;
            3'b110:out=8'b10111111;
            3'b111:out=8'b01111111;
        endcase         
   end
endmodule
