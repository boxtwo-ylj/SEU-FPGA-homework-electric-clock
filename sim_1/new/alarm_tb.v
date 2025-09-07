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
    always #10 Clk = ~Clk; // 10nsʱ������

    initial begin
        // ��ʼ���ź�
        Reset_n = 0;
        cnt_inc = 3'b000;
        cnt_dec = 3'b000;

        // �ͷŸ�λ�ź�
        #201;
        Reset_n = 1;

        // ģ���������
        #1000;
        cnt_inc = 3'b001; // ����1
        #20000;
        cnt_inc = 3'b000; // ֹͣ����

        #200;
        cnt_inc = 3'b010; // ����2
        #20000;
        cnt_inc = 3'b000; // ֹͣ����
        #200;
        cnt_inc = 3'b100; // ����2
        #2000;
        cnt_inc = 3'b000; // ֹͣ����

        // ģ���������
        #200;
        cnt_dec = 3'b001; // ����1
        #20000;
        cnt_dec = 3'b000; // ֹͣ����

        #200;
        cnt_dec = 3'b010; // ����2
        #20000;
        cnt_dec = 3'b000; // ֹͣ����
        #200;
        cnt_dec = 3'b100; // ����2
        #2000;
        cnt_dec = 3'b000;
        // �ȴ�һ��ʱ���Թ۲����
        #100;

        // ��������
        $finish;
    end
endmodule
