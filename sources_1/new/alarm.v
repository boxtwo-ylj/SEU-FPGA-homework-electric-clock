`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/07 20:53:08
// Design Name: 
// Module Name: alarm
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


module alarm(
    Clk,
    Reset_n,
    cnt_inc,
    cnt_dec,
    Data
    );
    input Clk;
    input Reset_n;
    input [2:0]cnt_inc;
    input [2:0]cnt_dec;
    output reg[31:0]Data;

    reg [3:0]cnt_0;
    reg [3:0]cnt_1;
    reg [3:0]cnt_2;
    reg [3:0]cnt_3;
    reg [3:0]cnt_4;
    reg [3:0]cnt_5;

    always @(posedge Clk or negedge Reset_n) begin
        if (!Reset_n) begin
            cnt_0 <= 0;
            cnt_1 <= 0;
            cnt_2 <= 0;
            cnt_3 <= 0;
            cnt_4 <= 0;
            cnt_5 <= 0;
        end else begin
            if(cnt_inc[0]==1)
                if(cnt_0==9)begin
                    cnt_0<=0;
                    if(cnt_1==5)begin
                        cnt_1<=0;
                    end
                    else
                        cnt_1<=cnt_1+1;
                end
                else
                    cnt_0<=cnt_0+1;
            else if(cnt_dec[0]==1)
                if(cnt_0==0)begin
                    cnt_0<=9;
                    if(cnt_1==0)begin
                        cnt_1<=5;
                    end
                    else
                        cnt_1<=cnt_1-1;
                end
                else
                    cnt_0<=cnt_0-1;
            if(cnt_inc[1]==1)
                if(cnt_2==9)begin
                    cnt_2<=0;
                    if(cnt_3==5)begin
                        cnt_3<=0;
                    end
                    else
                        cnt_3<=cnt_3+1;
                end
                else
                    cnt_2<=cnt_2+1;
            else if(cnt_dec[1]==1)
                if(cnt_2==0)begin
                    cnt_2<=9;
                    if(cnt_3==0)begin
                        cnt_3<=5;
                    end
                    else
                        cnt_3<=cnt_3-1;
                end
                else
                    cnt_2<=cnt_2-1;
            if(cnt_inc[2]==1)
                if(cnt_4==2&&cnt_5==1)begin
                    cnt_4<=0;
                    cnt_5<=0;
                end
                else if(cnt_4==9&&cnt_5==0)begin
                    cnt_4<=0;
                    cnt_5<=cnt_5+1;
                end
                else
                    cnt_4<=cnt_4+1;
            else if(cnt_dec[2]==1)
                if(cnt_4==0)begin
                    if(cnt_5==0)begin
                        cnt_4<=2;
                        cnt_5<=1;
                    end
                    else begin
                        if(cnt_5==1)begin
                            cnt_4<=9;
                            cnt_5<=0;
                        end
                    end
                end
                else
                    cnt_4<=cnt_4-1;
        end
    end
    always@(*) begin
        Data={cnt_0,cnt_1,4'hA,cnt_2,cnt_3,4'hA,cnt_4,cnt_5};
    end

endmodule
