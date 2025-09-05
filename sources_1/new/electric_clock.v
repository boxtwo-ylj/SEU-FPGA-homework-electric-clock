`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/04 00:40:55
// Design Name: 
// Module Name: electric_clock
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


module electric_clock(
    Clk,
    Reset_n,
    Key,
    SEL,
    SEG
    );
    input Clk;
    input Reset_n;
    input [3:0]Key;
    output [7:0]SEL;
    output [7:0]SEG;
    
    reg [31:0]Data;
    reg [2:0]state1;
    reg [2:0]state2;
    
    wire[3:0]Point;
    wire [3:0]Key_P_flag;
    wire [3:0]Key_R_flag;
    
    assign Point=4'hA;
    //数码管驱动
    hex8 hex8_inst(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Disp_Data(Data),
    .SEL(SEL),
    .SEG(SEG)
    );
    //按键消抖
    key_filter key_filter_inst0( 
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Key(Key[0]),
    .Key_P_flag(Key_P_flag[0]),
    .Key_R_flag(Key_R_flag[0])
    );
    key_filter key_filter_inst1( 
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Key(Key[1]),
    .Key_P_flag(Key_P_flag[1]),
    .Key_R_flag(Key_R_flag[1])
    );
    key_filter key_filter_inst2( 
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Key(Key[2]),
    .Key_P_flag(Key_P_flag[2]),
    .Key_R_flag(Key_R_flag[2])
    );
    key_filter key_filter_inst3( 
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Key(Key[3]),
    .Key_P_flag(Key_P_flag[3]),
    .Key_R_flag(Key_R_flag[3])
    );
    reg[29:0]cnt_s;
    reg[3:0]cnt_0;
    reg[3:0]cnt_1;
    reg[3:0]cnt_2;
    reg[3:0]cnt_3;
    reg[3:0]cnt_4;
    reg[3:0]cnt_5;
    reg [5:0]cnt_inc;
//    reg cnt_inc1;
//    reg cnt_inc2;
//    reg cnt_inc3;
//    reg cnt_inc4;
//    reg cnt_inc5;
    reg f_clear;
    
    
    parameter MCNT_S=50_000_000-1;
    
    localparam CLOCK=0;
    localparam CLOCK_C=1;
    localparam CALENDAR=2;
    localparam CALENDAR_C=3;
    localparam ALARM=4;
    localparam COUNTER_D=5;
    
    //时分秒计时显示
    
    always@(posedge Clk or negedge Reset_n)
        if(!Reset_n) begin
            cnt_s<=0;
            cnt_0<=0;
            cnt_1<=0;
            cnt_2<=0;
            cnt_3<=0;
            cnt_4<=0;
            cnt_5<=0;
            f_clear<=0;
        end
        else begin
            //1秒计时器
            if(cnt_s==MCNT_S)
                cnt_s<=0;
            else 
                cnt_s<=cnt_s+1'b1;
            
            //秒表个位计数    
            if(cnt_inc[0]==1)begin
                if(cnt_0==9)begin
                    cnt_0<=0;
                    cnt_inc[1]<=1;
                end
                else 
                    cnt_0<=cnt_0+1'b1;
            end  
            else if (cnt_inc[1]==1)
                cnt_inc[1]<=0;      
            else if(cnt_s==MCNT_S)begin
                if(cnt_0==9)
                    cnt_0<=0;
                else
                    cnt_0<=cnt_0+1'b1;
            end    
            
        //秒表十位计数    
            if(cnt_inc[1]==1)begin
                if(cnt_1==5)
                    cnt_1<=0;
                else
                    cnt_1<=cnt_1+1'b1;
            end
            else if((cnt_0==9)&&(cnt_s==MCNT_S))begin
                if(cnt_1==5)
                    cnt_1<=0;
                else
                    cnt_1<=cnt_1+1'b1;
            end    
            
        //分钟个位计数
            if(cnt_inc[2]==1)
                if(cnt_2==9)begin
                    cnt_2<=0;
                    cnt_inc[3]<=1;
                end
                else 
                    cnt_2<=cnt_2+1'b1;
            else if (cnt_inc[3]==1)
                cnt_inc[3]<=0;   
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S))
                if(cnt_2==9)
                    cnt_2<=0;
                else
                    cnt_2<=cnt_2+1'b1;
        
        //分钟十位计数
            if(cnt_inc[3]==1)
                if(cnt_3==5)
                    cnt_3<=0;
                else
                    cnt_3<=cnt_3+1'b1;
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9))
                if(cnt_3==5)
                    cnt_3<=0;
                else
                    cnt_3<=cnt_3+1'b1; 
        
        //时钟个位计数
            if(cnt_inc[4]==1)begin
                if((cnt_5==2)&&(cnt_4==3))begin
                    cnt_4<=0;
                    f_clear<=1;
                end
                else if(cnt_4==9)begin
                    cnt_4<=0;
                    cnt_inc[5]<=1;
                end
                else 
                    cnt_4<=cnt_4+1'b1;
            end 
            else if (cnt_inc[5]==1)
                cnt_inc[5]<=0; 
            else if (f_clear==1)
                f_clear<=0;
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9)&&(cnt_3==5)&&(cnt_4==3)&&(cnt_5==2))begin
                f_clear<=1;
                cnt_4<=0;
            end  
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9)&&(cnt_3==5))
                if(cnt_4==9)
                    cnt_4<=0;
                else
                    cnt_4<=cnt_4+1'b1;
        //时钟十位计数
            if(f_clear==1)
                cnt_5<=0;
            else if(cnt_inc[5]==1)
                cnt_5<=cnt_5+1'b1;
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9)&&(cnt_3==5)&&(cnt_4==9))
                    cnt_5<=cnt_5+1'b1;
        end
    //状态机
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)begin
        state1<=0;
        state2<=0;
    end
    else if(cnt_inc[0]==1)
        cnt_inc[0]<=0;
    else if(cnt_inc[2]==1)
        cnt_inc[2]<=0;
    else if(cnt_inc[4]==1)
        cnt_inc[4]<=0;
    else case(state1)
            CLOCK:
                if(Key_P_flag[3]==1)
                    state1<=CLOCK_C;
            CLOCK_C:
                if(Key_P_flag[3]==1)
                    state1<=CALENDAR;
                else if(cnt_s!=MCNT_S)
                    case(state2)
                        0:
                            if(Key_P_flag[2]==1)
                                state2<=1;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[0]<=1;
                        1:
                            if(Key_P_flag[2]==1)
                                state2<=2;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[2]<=1;
                        2:
                            if(Key_P_flag[2]==1)
                                state2<=0;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[4]<=1;
                        default:
                            state2<=0;
                    endcase
            CALENDAR:
                if(Key_P_flag[3]==1)
                    state1<=CALENDAR_C;
            CALENDAR_C:
                if(Key_P_flag[3]==1)
                    state1<=CLOCK;
            default:
                state1<=CLOCK;
        endcase
    
    always@(posedge Clk)
        Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
    
endmodule
