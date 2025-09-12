`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/04 00:59:24
// Design Name: 
// Module Name: electric_clock_tb
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


module electric_clock_tb2();
    reg Clk;
    reg Reset_n;
    reg [3:0]Key;
    wire[3:0]LED;
    wire [7:0]SEL;
    wire [7:0]SEG;
    
    electric_clock electric_clock(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Key(Key),
    .LED(LED),
    .SEL(SEL),
    .SEG(SEG)
    );
    defparam electric_clock.MCNT_F=2_500_000;
    defparam electric_clock.MCNT_S=2_500_0000;
    defparam electric_clock.MCNT_2S=5_000_000;
    
    initial Clk=1;
    always #10 Clk=~Clk;
    
    initial begin
    Reset_n=0;
    Key=4'b1111;
    #201;
    Reset_n=1;
    #1000;
    //调整时间仿真
     Key=4'b0111;
    #30_000_000;
    Key=4'b1111;
    #30_000_000;
     Key=4'b0111;
    #30_000_000;
    Key=4'b1111;
    #30_000_000;
     Key=4'b0111;
    #30_000_000;
    Key=4'b1111;
    #30_000_000;//切换到日期调整功能
    Key=4'b1011;
    #30_000_000;
    Key=4'b1111;
    #30_000_000;//切换到月调整
    Key=4'b1101;
    #30_000_000;
    Key=4'b1111;
    #30_000_000;//分钟增加1
    Key=4'b1110;
    #30_000_000;
    Key=4'b1111;
    #100_000_000;//分钟减少1
    $stop;
end
endmodule 