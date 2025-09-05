`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 21:24:47
// Design Name: 
// Module Name: hex8_tb
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


module hex8_tb();
    reg Clk;
    reg Reset_n;
    reg [31:0]Disp_Data;
    wire [7:0]SEL;
    wire [7:0]SEG;

    hex8 hex8(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Disp_Data(Disp_Data),
    .SEL(SEL),
    .SEG(SEG)
    );
    
    initial Clk=1;
    always #10 Clk=~Clk;
    
    initial begin
        Reset_n=0;
        
        #201;
        Disp_Data=32'h01234567;
        Reset_n=1;
        #40_000_000;
        $stop;
        end
        
    
endmodule
