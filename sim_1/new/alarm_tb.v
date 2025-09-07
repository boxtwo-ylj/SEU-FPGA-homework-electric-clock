`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/07 21:09:53
// Design Name: 
// Module Name: alarm_tb
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


module alarm_tb();
    reg Clk;
    reg Reset_n;
    reg [2:0]cnt_inc;
    reg [2:0]cnt_dec;
    wire [31:0]Data;

    alarm u_alarm(
        .Clk(Clk),
        .Reset_n(Reset_n),
        .cnt_inc(cnt_inc),
        .cnt_dec(cnt_dec),
        .Data(Data)
    );

    initial Clk = 1;
    always #10 Clk = ~Clk; // 10ns时钟周期

    initial begin
        // 初始化信号
        Reset_n = 0;
        cnt_inc = 3'b000;
        cnt_dec = 3'b000;

        // 释放复位信号
        #201;
        Reset_n = 1;

        // 模拟计数增加
        #1000;
        cnt_inc = 3'b001; // 增加1
        #20000;
        cnt_inc = 3'b000; // 停止增加

        #200;
        cnt_inc = 3'b010; // 增加2
        #20000;
        cnt_inc = 3'b000; // 停止增加
        #200;
        cnt_inc = 3'b100; // 增加2
        #2000;
        cnt_inc = 3'b000; // 停止增加

        // 模拟计数减少
        #200;
        cnt_dec = 3'b001; // 减少1
        #20000;
        cnt_dec = 3'b000; // 停止减少

        #200;
        cnt_dec = 3'b010; // 减少2
        #20000;
        cnt_dec = 3'b000; // 停止减少
        #200;
        cnt_dec = 3'b100; // 减少2
        #2000;
        cnt_dec = 3'b000;
        // 等待一段时间以观察输出
        #100;

        // 结束仿真
        $finish;
    end
endmodule
