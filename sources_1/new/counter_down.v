`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 13:58:33
// Design Name: 
// Module Name: counter_down
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


module counter_down(
    Clk,
    Reset_n,
    cnt_inc,
    cnt_dec,
    cnt_down,
    Data,
    start_flag,
    reset_flag
    );
    input Clk;
    input Reset_n;
    input [2:0] cnt_inc;
    input [2:0] cnt_dec;
    input cnt_down;
    input start_flag;
    input reset_flag;
    output reg [31:0] Data;
    reg [31:0] Data_last;
    reg start_flag_r;

    reg [3:0]cnt_0;
    reg [3:0]cnt_1;
    reg [3:0]cnt_2;
    reg [3:0]cnt_3;
    reg [3:0]cnt_4;
    reg [3:0]cnt_5;

    always @(posedge Clk or negedge Reset_n) begin
        if(!Reset_n)begin
            cnt_0 <= 4'd0;
            cnt_1 <= 4'd0;
            cnt_2 <= 4'd0;
            cnt_3 <= 4'd0;
            cnt_4 <= 4'd0;  
            cnt_5 <= 4'd0;
        end
        else if(reset_flag==1)begin
            cnt_0 <= Data_last[31:28];
            cnt_1 <= Data_last[27:24];
            cnt_2 <= Data_last[19:16];
            cnt_3 <= Data_last[15:12];
            cnt_4 <= Data_last[7:4];
            cnt_5 <= Data_last[3:0];
        end
        else begin
            if(cnt_inc[0]==1)begin
                if(cnt_0==9)begin
                    cnt_0<=0;
                    if(cnt_1==5)
                        cnt_1<=0;
                    else
                        cnt_1<=cnt_1+1;
                end
                else
                    cnt_0<=cnt_0+1;
            end
            else if(cnt_dec[0]==1)begin
                if(cnt_0==0)begin
                    cnt_0<=9;
                    if(cnt_1==0)
                        cnt_1<=5;
                    else
                        cnt_1<=cnt_1-1;
                end
                else
                    cnt_0<=cnt_0-1;
            end
            if(cnt_inc[1]==1)begin
                if(cnt_2==9)begin
                    cnt_2<=0;
                    if(cnt_3==5)
                        cnt_3<=0;
                    else
                        cnt_3<=cnt_3+1;
                end
                else
                    cnt_2<=cnt_2+1;
            end
            else if(cnt_dec[1]==1)begin
                if(cnt_2==0)begin
                    cnt_2<=9;
                    if(cnt_3==0)
                        cnt_3<=5;
                    else
                        cnt_3<=cnt_3-1;
                end
                else
                    cnt_2<=cnt_2-1;
            end
            if(cnt_inc[2]==1)begin
                if(cnt_4==3&&cnt_5==2)begin
                    cnt_4<=0;
                    cnt_5<=0;
                end
                else if(cnt_4==9)begin
                    cnt_4<=0;
                    cnt_5<=cnt_5+1;
                end
                else
                    cnt_4<=cnt_4+1;
            end
            else if(cnt_dec[2]==1)begin
                if(cnt_4==0)begin
                    if(cnt_5==0)begin
                        cnt_4<=3;
                        cnt_5<=2;
                    end
                    else begin
                            cnt_4<=9;
                            cnt_5<=cnt_5-1;
                        end
                end
                else
                    cnt_4<=cnt_4-1;
            end
            if(cnt_down==1)begin
                if(cnt_0==0)begin
                    cnt_0<=9;
                    if(cnt_1==0)begin
                        cnt_1<=5;
                        if(cnt_2==0)begin
                            cnt_2<=9;
                            if(cnt_3==0)begin
                                cnt_3<=5;
                                if(cnt_4==0)begin
                                    if(cnt_5==0)begin
                                        cnt_5<=2;
                                        cnt_4<=3;
                                    end
                                    else begin
                                        cnt_4<=9;
                                        cnt_5<=cnt_5-1;
                                    end
                                end
                                else
                                    cnt_4<=cnt_4-1;
                            end
                            else
                                cnt_3<=cnt_3-1;
                        end
                        else begin
                            cnt_2<=cnt_2-1;
                        end
                    end
                    else
                        cnt_1<=cnt_1-1;
                end
                else
                    cnt_0<=cnt_0-1;
            end
        end
    end
    always @(posedge Clk) begin
        start_flag_r<=start_flag;
    end
    always @(posedge Clk or negedge Reset_n) begin
        if(!Reset_n) begin
            Data<=0;
        end
        else if(start_flag_r==1) begin
            Data_last<={cnt_0,cnt_1,4'hA,cnt_2,cnt_3,4'hA,cnt_4,cnt_5};
        end
        else begin
            Data<={cnt_0,cnt_1,4'hA,cnt_2,cnt_3,4'hA,cnt_4,cnt_5};
        end
    end
endmodule
