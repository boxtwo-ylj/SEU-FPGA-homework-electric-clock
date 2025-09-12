`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/06 15:03:35
// Design Name: 
// Module Name: calendar_tb
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


module calendar_tb();
    reg Clk;
    reg Reset_n;
    reg [2:0]cnt_inc;
    reg [2:0]cnt_dec;
    reg full_flag;
    wire [31:0]Data;
    calendar calendar(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .cnt_inc(cnt_inc),
    .cnt_dec(cnt_dec),
    .full_flag(full_flag),
    .Data(Data)
    );
    initial Clk=0;
    always#10 Clk=~Clk;
    initial begin
        Reset_n=0;
        cnt_inc=3'b000;
        cnt_dec=3'b000;
        full_flag=0;
        #101;
        Reset_n=1;
        #100;
        cnt_inc=3'b001;//日期加1
        #100;
        cnt_inc=3'b000;
        #20;
        cnt_inc=3'b010;//月份加1
        #100;
        cnt_inc=3'b000;
        #20;
        cnt_inc=3'b100;//年份加1
        #100;
        cnt_inc=3'b000;
        #20;
        cnt_dec=3'b001;//日期减1
        #100;
        cnt_dec=3'b000;
        #20;
        cnt_dec=3'b010;//月份减1
        #100;
        cnt_dec=3'b000;
        #20;
        cnt_dec=3'b100;//年份减1
        #100;
        cnt_dec=3'b000;
        #20;
        $stop;
    end

endmodule
