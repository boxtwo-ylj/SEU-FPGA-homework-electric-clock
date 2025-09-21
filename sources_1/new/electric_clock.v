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
    LED,
    SEL,
    SEG
    );
    input Clk;
    input Reset_n;
    input [3:0]Key;
    output reg[3:0]LED;
    output [7:0]SEL;//数码管位选
    output [7:0]SEG;//数码管段选
    
    reg [31:0]Data;
    wire [31:0]Data_clock;
    wire [31:0]Data_calendar;
    wire [31:0]Data_alarm;
    reg [31:0]Data_alarm_s1;
    reg [31:0]Data_alarm_s2;
    reg [31:0]Data_alarm_s3;//数码管显示数据
    wire [31:0]Data_counter_down;
    reg [2:0]state1;
    reg [2:0]state2;//状态机状态变量
    reg[1:0]key_state;//按键状态变量
    reg[1:0]alarm_state;//闹钟状态变量
    
    wire[3:0]Point;
    wire [3:0]Key_P_flag;
    wire [3:0]Key_R_flag;//按键按下和释放标志
    
    assign Point=4'hA;
    
    reg[29:0]cnt_s;
    reg[29:0]cnt_flash;//1秒计时器，闪烁计时器
    reg[29:0]cnt_key_time;//按键长按计时器
    reg[29:0]cnt_alarm_time;//闹钟响铃计时器
    reg[29:0]cnt_counter_down_flash;//倒计时闪烁计时器
    reg[3:0]cnt_0;
    reg[3:0]cnt_1;
    reg[3:0]cnt_2;
    reg[3:0]cnt_3;
    reg[3:0]cnt_4;
    reg[3:0]cnt_5;//时钟计数器
    reg[5:0]cnt_inc;//按键加1标志
    reg[5:0]cnt_dec;//按键减1标志
    reg[2:0]cnt_inc_c;//时钟计数加
    reg[2:0]cnt_dec_c;//时钟计数减
    reg[2:0]cnt_inc_a;//闹钟计数加
    reg[2:0]cnt_dec_a;//闹钟计数减
    reg[2:0]cnt_inc_d;//倒计时加
    reg[2:0]cnt_dec_d;//倒计时减
    reg f_clear;//清零标志
    reg [2:0]alarm_set;//闹钟设置标志
    reg [29:0]cnt_down;//倒计时开始标志
    reg count_d;//倒计时计数标志
    reg start_flag;//倒计时开始标志
    reg reset_flag;//倒计时复位标志
    
    //参数定义
    parameter MCNT_F=25_000_000-1;
    parameter MCNT_S=50_000_000-1;
    parameter MCNT_2S =100_000_000-1; //2秒计时器;
    parameter MCNT_5S =250_000_000-1; //5秒计时器;
    parameter MCNT_10S=500_000_000-1; //10秒计时器;

    //状态机状态定义
    localparam CLOCK=0;
    localparam CLOCK_C=1;
    localparam CALENDAR=2;
    localparam CALENDAR_C=3;
    localparam ALARM=4;
    localparam COUNTER_D_SET=5;
    localparam COUNTER_D_START=6;
    
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


    //时分秒计时显示
    
    always@(posedge Clk or negedge Reset_n)begin
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
            //按键加1 
            if(cnt_inc[0]==1)
                if(cnt_0==9)begin
                    cnt_0<=0;
                    cnt_inc[1]<=1;
                end
                else 
                    cnt_0<=cnt_0+1'b1;
            //按键减1 
            else if (cnt_dec[0]==1)
                if(cnt_0==0)begin
                    cnt_0=9;
                    cnt_dec[1]<=1;
                end
                else 
                    cnt_0<=cnt_0-1'b1;
            else if (cnt_inc[1]==1)
                cnt_inc[1]<=0;
            else if (cnt_dec[1]==1)
                cnt_dec[1]<=0; //清空进位状态，防止多次进位
            //自动加1     
            else if(cnt_s==MCNT_S)
                if(cnt_0==9)
                    cnt_0<=0;
                else
                    cnt_0<=cnt_0+1'b1;
            //秒表十位计数    
            if(cnt_inc[1]==1)
                if(cnt_1==5)
                    cnt_1<=0;
                else
                    cnt_1<=cnt_1+1'b1;
            //按键加1
            else if (cnt_dec[1]==1)
                if(cnt_1==0)
                    cnt_1<=5;
                else 
                    cnt_1<=cnt_1-1'b1;
            //按键减1
            else if((cnt_0==9)&&(cnt_s==MCNT_S))begin
                if(cnt_1==5)
                    cnt_1<=0;
                else
                    cnt_1<=cnt_1+1'b1;
            end   
            //自动加1
            
        //分钟个位计数
            if(cnt_inc[2]==1)
                if(cnt_2==9)begin
                    cnt_2<=0;
                    cnt_inc[3]<=1;
                end
                else 
                    cnt_2<=cnt_2+1'b1;
            //按键加1
            else if (cnt_dec[2]==1)
                if(cnt_2==0)begin
                    cnt_2<=9;
                    cnt_dec[3]<=1;
                end
                else 
                    cnt_2<=cnt_2-1'b1;
            //按键减1
            else if (cnt_dec[3]==1)
                cnt_dec[3]<=0; 
            else if (cnt_inc[3]==1)
                cnt_inc[3]<=0;  
            //清空进位状态，防止多次进位
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S))
                if(cnt_2==9)
                    cnt_2<=0;
                else
                    cnt_2<=cnt_2+1'b1;
            //自动加1
        
        //分钟十位计数
            if(cnt_inc[3]==1)
                if(cnt_3==5)
                    cnt_3<=0;
                else
                    cnt_3<=cnt_3+1'b1;
            //按键加1
            else if (cnt_dec[3]==1)
                if(cnt_3==0)
                    cnt_3<=5;
                else 
                    cnt_3<=cnt_3-1'b1;
            //按键减1
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9))
                if(cnt_3==5)
                    cnt_3<=0;
                else
                    cnt_3<=cnt_3+1'b1; 
        
        //时钟个位计数
            if(cnt_inc[4]==1)
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
            //按键加1
            else if (cnt_dec[4]==1)
                if(cnt_4==0)begin
                    if(cnt_5==0)
                        cnt_4<=3;
                    else 
                        cnt_4<=9;
                    cnt_dec[5]<=1;
                end
                else 
                    cnt_4<=cnt_4-1'b1;
            //按键减1
            else if (cnt_dec[5]==1)
                cnt_dec[5]<=0; 
            else if (cnt_inc[5]==1)
                cnt_inc[5]<=0;
            //清空进位状态，防止多次进位 
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
            //按键加1
            else if (cnt_dec[5]==1)
                if(cnt_5==0)
                    cnt_5<=2;
                else 
                    cnt_5<=cnt_5-1'b1;
            //按键减1
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9)&&(cnt_3==5)&&(cnt_4==9))
                    cnt_5<=cnt_5+1'b1;
            //自动加1
        end
    end 
    //日历计数显示
    calendar calendar_inst(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .cnt_inc(cnt_inc_c),
    .cnt_dec(cnt_dec_c),
    .full_flag(f_clear),
    .Data(Data_calendar)
    );
    //闹钟设置显示
    alarm alarm_inst1(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .cnt_inc(cnt_inc_a),
    .cnt_dec(cnt_dec_a),
    .Data(Data_alarm)
    );
    //倒计时设置显示
    counter_down counter_down_inst(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .cnt_inc(cnt_inc_d),
    .cnt_dec(cnt_dec_d),
    .cnt_down(count_d),
    .start_flag(start_flag),
    .reset_flag(reset_flag),
    .Data(Data_counter_down)
    );
    //状态机
    always@(posedge Clk or negedge Reset_n)begin
    if(!Reset_n)begin
        state1<=0;
        state2<=0;
        alarm_set<=0;
        Data_alarm_s1<=32'hffff_ffff;
        Data_alarm_s2<=32'hffff_ffff;
        Data_alarm_s3<=32'hffff_ffff;
        count_d<=0;
        cnt_down<=0;
        start_flag<=0;
        reset_flag<=0;
    end
    else if(cnt_inc[0]==1)
        cnt_inc[0]<=0;
    else if(cnt_inc[2]==1)
        cnt_inc[2]<=0;
    else if(cnt_inc[4]==1)
        cnt_inc[4]<=0;
    else if(cnt_dec[0]==1)
        cnt_dec[0]<=0;
    else if(cnt_dec[2]==1)
        cnt_dec[2]<=0;
    else if(cnt_dec[4]==1)
        cnt_dec[4]<=0;
    else if(cnt_inc_c[0]==1)
        cnt_inc_c[0]<=0;
    else if(cnt_inc_c[1]==1)
        cnt_inc_c[1]<=0;
    else if(cnt_inc_c[2]==1)
        cnt_inc_c[2]<=0;
    else if(cnt_dec_c[0]==1)
        cnt_dec_c[0]<=0;
    else if(cnt_dec_c[1]==1)
        cnt_dec_c[1]<=0;
    else if(cnt_dec_c[2]==1)
        cnt_dec_c[2]<=0;
    else if(cnt_inc_a[0]==1)
        cnt_inc_a[0]<=0;
    else if(cnt_inc_a[1]==1)
        cnt_inc_a[1]<=0;
    else if(cnt_inc_a[2]==1)
        cnt_inc_a[2]<=0;
    else if(cnt_dec_a[0]==1)
        cnt_dec_a[0]<=0;
    else if(cnt_dec_a[1]==1)
        cnt_dec_a[1]<=0;
    else if(cnt_dec_a[2]==1)
        cnt_dec_a[2]<=0;
    else if(cnt_inc_d[0]==1)
        cnt_inc_d[0]<=0;
    else if(cnt_inc_d[1]==1)
        cnt_inc_d[1]<=0;
    else if(cnt_inc_d[2]==1)
        cnt_inc_d[2]<=0;
    else if(cnt_dec_d[0]==1)
        cnt_dec_d[0]<=0;
    else if(cnt_dec_d[1]==1)
        cnt_dec_d[1]<=0;
    else if(cnt_dec_d[2]==1)
        cnt_dec_d[2]<=0;
    else case(state1)
            CLOCK:begin//时钟显示
                state2<=0;
                if(Key_P_flag[3]==1)
                    state1<=CLOCK_C;
            end
            CLOCK_C:begin//时钟设置
                if(Key_P_flag[3]==1)
                    state1<=CALENDAR;
                else if(cnt_s!=MCNT_S)
                    
                    case(state2)
                        0:
                            if(Key_P_flag[2]==1)
                                state2<=1;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[0]<=1;//按键1，秒表个位加1
                            else if(Key_P_flag[0]==1)
                                cnt_dec[0]<=1;//按键0，秒表个位减1
                        1:
                            if(Key_P_flag[2]==1)
                                state2<=2;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[2]<=1;
                            else if(Key_P_flag[0]==1)
                                cnt_dec[2]<=1;
                        2:
                            if(Key_P_flag[2]==1)
                                state2<=0;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[4]<=1;
                            else if(Key_P_flag[0]==1)   
                                cnt_dec[4]<=1;
                        default:
                            state2<=0;
                    endcase
            end
            CALENDAR:begin  //日期显示
                state2<=0;
                if(Key_P_flag[3]==1)
                    state1<=CALENDAR_C;
            end
            CALENDAR_C:begin
                if(Key_P_flag[3]==1)
                    state1<=ALARM;
                else
                    case(state2)
                            0:
                                if(Key_P_flag[2]==1)
                                    state2<=1;
                                else if(Key_P_flag[1]==1)
                                    cnt_inc_c[0]<=1;
                                else if(Key_P_flag[0]==1)
                                    cnt_dec_c[0]<=1;
                            1:
                                if(Key_P_flag[2]==1)
                                    state2<=2;
                                else if(Key_P_flag[1]==1)
                                    cnt_inc_c[1]<=1;
                                else if(Key_P_flag[0]==1)
                                    cnt_dec_c[1]<=1;
                            2:
                                if(Key_P_flag[2]==1)
                                    state2<=0;
                                else if(Key_P_flag[1]==1)
                                    cnt_inc_c[2]<=1;
                                else if(Key_P_flag[0]==1)
                                    cnt_dec_c[2]<=1;
                            default:
                                state2<=0;
                endcase//按键控制日期
            end
            ALARM:begin
                if(Key_P_flag[3]==1)begin
                    state1<=COUNTER_D_SET;
                    state2<=0;
                end
                else if(key_state==3)begin
                    if(alarm_set[0]==0)begin
                        alarm_set[0]<=1;
                        Data_alarm_s1<=Data_alarm;
                    end
                    else if(alarm_set[1]==0)begin
                        alarm_set[1]<=1;
                        Data_alarm_s2<=Data_alarm;
                    end
                    else if(alarm_set[2]==0)begin
                        alarm_set[2]<=1;
                        Data_alarm_s3<=Data_alarm;
                    end
                    else begin
                        Data_alarm_s1<=32'hffff_ffff;
                        Data_alarm_s2<=32'hffff_ffff;
                        Data_alarm_s3<=32'hffff_ffff;
                        alarm_set<=0;
                    end    
                end   
                else
                    case(state2)
                        0:
                            if(key_state==2)//短按切换闹钟位数
                                state2<=1;
                            else if(Key_P_flag[1]==1)
                                cnt_inc_a[0]<=1;
                            else if(Key_P_flag[0]==1)
                                cnt_dec_a[0]<=1;
                        1:
                            if(key_state==2)
                                state2<=2;
                            else if(Key_P_flag[1]==1)
                                cnt_inc_a[1]<=1;
                            else if(Key_P_flag[0]==1)
                                cnt_dec_a[1]<=1;
                        2:
                            if(key_state==2)
                                state2<=0;
                            else if(Key_P_flag[1]==1)
                                cnt_inc_a[2]<=1;
                            else if(Key_P_flag[0]==1)   
                                cnt_dec_a[2]<=1;
                        default:
                            state2<=0;
                    endcase
            end
            COUNTER_D_SET:begin
                reset_flag<=0;
                if(Key_P_flag[3]==1)
                    state1<=CLOCK;
                else if(key_state==3)begin//长按开始倒计时
                    state1<=COUNTER_D_START;
                    start_flag<=1;
                    state2<=0;
                end
                else
                    case(state2)
                        0:
                            if(key_state==2)//短按切换倒计时位数
                                state2<=1;
                            else if(Key_P_flag[1]==1)
                                cnt_inc_d[0]<=1;
                            else if(Key_P_flag[0]==1)
                                cnt_dec_d[0]<=1;
                        1:
                            if(key_state==2)
                                state2<=2;
                            else if(Key_P_flag[1]==1)
                                cnt_inc_d[1]<=1;
                            else if(Key_P_flag[0]==1)
                                cnt_dec_d[1]<=1;
                        2:
                            if(key_state==2)
                                state2<=0;
                            else if(Key_P_flag[1]==1)
                                cnt_inc_d[2]<=1;
                            else if(Key_P_flag[0]==1)   
                                cnt_dec_d[2]<=1;
                        default:
                            state2<=0;
                    endcase
            end
            COUNTER_D_START:begin
                start_flag<=0;
                case(state2)
                    0:begin//倒计时开始
                        
                        if(key_state==2)begin
                            state2<=1;
                            cnt_down<=0;
                        end
                        else if(Key_P_flag[3]==1)begin
                            state1<=CLOCK;
                            state2<=0;
                            cnt_down<=0;
                        end
                        
                        else if(Data_counter_down=={4'h0,4'h0,4'hA,4'h0,4'h0,4'hA,4'h0,4'h0})begin
                            count_d<=0;
                            cnt_down<=0;
                            state2<=2;
                        end
                        else if(cnt_down==MCNT_S)begin
                            cnt_down<=0;
                            count_d<=1;
                        end
                        else begin
                            count_d<=0;
                            cnt_down<=cnt_down+1'b1;
                        end
                    end
                    1:begin//倒计时暂停
                        count_d<=0;
                        if(key_state==2)
                            state2<=0;
                        else if(key_state==3)begin//长按复位
                            reset_flag<=1;
                            cnt_down<=0;
                            state2<=0;
                            state1<=COUNTER_D_SET;
                        end
                        else if(Key_P_flag[3]==1)begin
                            state1<=CLOCK;
                            state2<=0;
                            cnt_down<=0;
                        end
                    end
                    2:begin//倒计时结束闪烁
                        cnt_counter_down_flash<=cnt_counter_down_flash+1'b1;
                        if(cnt_counter_down_flash==MCNT_5S)begin
                            cnt_counter_down_flash<=0;
                            state2<=0;
                            state1<=CLOCK;
                        end
                        if(Key_P_flag[3]==1)begin
                            state1<=CLOCK;
                            state2<=0;
                            cnt_counter_down_flash<=0;
                        end

                    end

                    default:begin
                        state2<=0;
                        count_d<=0;
                    end
                endcase
                    
            end

            default:
                state1<=CLOCK;
        endcase
    end
    //按键长按检测
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            key_state<=0;
        end
        else begin
            case(key_state)
                0:
                    if(Key_P_flag[2]==1)begin
                        key_state<=1;
                        cnt_key_time<=0;
                    end
                        
                1:
                    if(Key_R_flag[2]==1)begin
                        key_state<=2;
                        cnt_key_time<=0;
                    end
                    else if(cnt_key_time==MCNT_2S)begin
                        key_state<=3;
                        cnt_key_time<=0;
                    end
                    else begin
                        cnt_key_time<=cnt_key_time+1;
                    end
                default:
                    key_state<=0;
            endcase
        end
    end
    //闪烁计时器
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)
            cnt_flash<=0;
        else
            if(cnt_flash==MCNT_F)
                cnt_flash<=0;
            else
                cnt_flash<=cnt_flash+1;
    end
    //数码管显示数据选择
    always@(posedge Clk)begin
        case(state1)
            CLOCK:
                Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
            CLOCK_C:
                //时钟设置闪烁
                if(cnt_flash<MCNT_F/2)
                    Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
                else if(state2==0)
                    Data<={4'hB,4'hB,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
                else if(state2==1)
                    Data<={cnt_0,cnt_1,Point,4'hB,4'hB,Point,cnt_4,cnt_5};
                else if(state2==2)
                    Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,4'hB,4'hB};
                else
                    Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
            CALENDAR:
                Data<=Data_calendar;
            CALENDAR_C:
                //日期设置闪烁
                if(cnt_flash<MCNT_F/2)
                    Data<=Data_calendar;
                else if(state2==0)
                    Data<={4'hB,4'hB,Data_calendar[23:20],Data_calendar[19:16],Data_calendar[15:12],Data_calendar[11:8],Data_calendar[7:4],Data_calendar[3:0]};
                else if(state2==1)
                    Data<={Data_calendar[31:28],Data_calendar[27:24],4'hB,4'hB,Data_calendar[15:12],Data_calendar[11:8],Data_calendar[7:4],Data_calendar[3:0]};
                else if(state2==2)
                    Data<={Data_calendar[31:28],Data_calendar[27:24],Data_calendar[23:20],Data_calendar[19:16],4'hB,4'hB,4'hB,4'hB};
                else
                    Data<=Data_calendar;
            ALARM:
                //闹钟设置闪烁
                if(cnt_flash<MCNT_F/2)
                    Data<=Data_alarm;
                else if(state2==0)
                    Data<={4'hB,4'hB,Data_alarm[23:20],Data_alarm[19:16],Data_alarm[15:12],Data_alarm[11:8],Data_alarm[7:4],Data_alarm[3:0]};
                else if(state2==1) 
                    Data<={Data_alarm[31:28],Data_alarm[27:24],Data_alarm[23:20],4'hB,4'hB,Data_alarm[11:8],Data_alarm[7:4],Data_alarm[3:0]};
                else if(state2==2)
                    Data<={Data_alarm[31:28],Data_alarm[27:24],Data_alarm[23:20],Data_alarm[19:16],Data_alarm[15:12],Data_alarm[11:8],4'hB,4'hB};
                else
                    Data<=Data_alarm;
            COUNTER_D_SET:
                //倒计时设置闪烁
                if(cnt_flash<MCNT_F/2)
                    Data<=Data_counter_down;
                else if(state2==0)
                    Data<={4'hB,4'hB,Data_counter_down[23:20],Data_counter_down[19:16],Data_counter_down[15:12],Data_counter_down[11:8],Data_counter_down[7:4],Data_counter_down[3:0]};
                else if(state2==1) 
                    Data<={Data_counter_down[31:28],Data_counter_down[27:24],Data_counter_down[23:20],4'hB,4'hB,Data_counter_down[11:8],Data_counter_down[7:4],Data_counter_down[3:0]};
                else if(state2==2)
                    Data<={Data_counter_down[31:28],Data_counter_down[27:24],Data_counter_down[23:20],Data_counter_down[19:16],Data_counter_down[15:12],Data_counter_down[11:8],4'hB,4'hB};
                else
                    Data<=Data_counter_down;
            COUNTER_D_START:
                Data<=Data_counter_down;
            default:
                Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
        endcase
    end
    always @(*) begin
        LED[2:0]=alarm_set;
    end
    //闹钟响铃控制
    assign Data_clock={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            LED[3]<=0;
            alarm_state<=0;
        end
        else if(state1==COUNTER_D_START&&state2==2)//倒计时结束闪烁
            if(cnt_flash<MCNT_F/2)
                LED[3]<=1;
            else
                LED[3]<=0;
        else
            case(alarm_state)
                0:begin
                    LED[3]<=0;
                    cnt_alarm_time<=0;
                    if(Data_clock==Data_alarm_s1||Data_clock==Data_alarm_s2||Data_clock==Data_alarm_s3)
                        alarm_state<=1;
                end
                1:begin
                    cnt_alarm_time<=cnt_alarm_time+1'b1;
                    if(Key_P_flag[2]==1)
                        alarm_state<=0;
                    else if(cnt_alarm_time==MCNT_5S)begin
                        alarm_state<=2;
                        cnt_alarm_time<=0;
                    end
                    if(cnt_flash<MCNT_F/2)
                        LED[3]<=1;
                    else
                        LED[3]<=0;
                end
                2:begin
                    cnt_alarm_time<=cnt_alarm_time+1'b1;
                    if(Key_P_flag[2]==1)
                        alarm_state<=0;
                    else if(cnt_alarm_time==MCNT_10S)begin
                        alarm_state<=3;
                        cnt_alarm_time<=0;
                    end
                    LED[3]<=0;
                end
                3:begin
                    cnt_alarm_time<=cnt_alarm_time+1'b1;
                    if(Key_P_flag[2]==1)
                        alarm_state<=0;
                    else if(cnt_alarm_time==MCNT_5S)begin
                        alarm_state<=0;
                        cnt_alarm_time<=0;
                    end
                    if(cnt_flash<MCNT_F/2)
                        LED[3]<=1;
                    else
                        LED[3]<=0;
                end
                default:
                    alarm_state<=0;
            endcase
    end
   
endmodule
