`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/06 02:19:38
// Design Name: 
// Module Name: calendar
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


module calendar(
    Clk,
    Reset_n,
    cnt_inc,
    full_flag,
    Data
    );
    input Clk;
    input Reset_n;
    input [2:0]cnt_inc;
    input full_flag;
    output reg[31:0]Data;

    reg [3:0]cnt_0;
    reg [3:0]cnt_1;
    reg [3:0]cnt_2;
    reg [3:0]cnt_3;
    reg [3:0]cnt_4;
    reg [3:0]cnt_5;

    reg month_b; //月份的大小月标志
    reg leap_year; //闰年标志
    reg year_full;
    reg month_full;
    reg day_full;

    always @(*) begin
        if(cnt_3==0)
            case(cnt_2)
                1,3,5,7,8:month_b=1; //大月
                default:month_b=0; //小月
            endcase
        else if(cnt_3==1)
            case(cnt_2)
                0,2:month_b=1; //大月
                default:month_b=0; //小月
            endcase
    end

    always @(*) begin
        if((cnt_4+cnt_5*10)%4==0)
            leap_year=1; //闰年
        else
            leap_year=0; //平年
    end

    always @(*) begin
        //年满标志
        if((cnt_5==9)&&(cnt_4==9))
            year_full=1;
        else
            year_full=0;
        //月满标志
        if ((cnt_3==1)&&(cnt_2==2)) 
            month_full=1;
        else
            month_full=0;
        //日满标志
        if(month_b==1) begin
            if((cnt_1==3)&&(cnt_0==1))
                day_full=1;
            else
                day_full=0;//大月
        end
        else if((month_b==0)&&(cnt_2==2))begin
            if(leap_year==1) begin
                if((cnt_1==2)&&(cnt_0==9))
                    day_full=1;
                else
                    day_full=0;//闰年二月
            end
            else if(leap_year==0) begin
                if((cnt_1==2)&&(cnt_0==8))
                    day_full=1;
                else
                    day_full=0;//平年二月
            end
        end
        else if(month_b==0) begin
            if((cnt_1==3)&&(cnt_0==0))
                day_full=1;
            else
                day_full=0;//小月
        end
    end

    always @(posedge Clk or negedge Reset_n) begin
        if(!Reset_n)begin
            cnt_0<=4'b0001;
            cnt_1<=4'b0000;
            cnt_2<=4'b0001;
            cnt_3<=4'b0000;
            cnt_4<=4'b0000;
            cnt_5<=4'b0000;
        end
        else begin
            if (cnt_inc[0]==1)
                if(day_full==1) begin
                    cnt_0<=1;
                    cnt_1<=0;
                end
                else if(cnt_0==9) begin
                    cnt_0<=0;
                    cnt_1<=cnt_1+1;
                end
                else
                    cnt_0<=cnt_0+1;
                
            //日计数器
            if(cnt_inc[1]==1)
                if(month_full==1)begin
                    cnt_2<=1;
                    cnt_3<=0;
                end
                else if((cnt_2==9))begin
                    cnt_2<=0;
                    cnt_3<=cnt_3+1;
                end
                else
                    cnt_2<=cnt_2+1;
            //月计数器
            if(cnt_inc[2]==1)
                if((year_full==1)) begin
                    cnt_4<=0;
                    cnt_5<=0;
                end
                else if((cnt_4==9))begin
                    cnt_4<=0;
                    cnt_5<=cnt_5+1;
                end
                else
                    cnt_4<=cnt_4+1;
            //年计数器
            else if(full_flag==1) begin
                if(day_full==1)begin
                    cnt_0<=1;
                    cnt_1<=0;
                    if(month_full==1)begin
                        cnt_2<=1;
                        cnt_3<=0;
                        if(year_full==1) begin
                            cnt_4<=0;
                            cnt_5<=0;
                        end
                        else if((cnt_4==9))begin
                            cnt_4<=0;
                            cnt_5<=cnt_5+1;
                        end
                        else
                            cnt_4<=cnt_4+1;
                    end
                    else if((cnt_2==9))begin
                        cnt_2<=0;
                        cnt_3<=cnt_3+1;
                    end
                    else
                        cnt_2<=cnt_2+1;
                end
                else if(cnt_0==9) begin
                    cnt_0<=0;
                    cnt_1<=cnt_1+1;
                end
                else
                    cnt_0<=cnt_0+1;
            end
        end
    end
    always@(posedge Clk)begin
        Data<={cnt_0,cnt_1,cnt_2,cnt_3,cnt_4,cnt_5,4'b0000,4'b0010};
    end

endmodule
