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
    output [7:0]SEL;//�����λѡ
    output [7:0]SEG;//����ܶ�ѡ
    
    reg [31:0]Data;
    wire [31:0]Data_calendar;
    reg [2:0]state1;
    reg [2:0]state2;//״̬��״̬����
    
    wire[3:0]Point;
    wire [3:0]Key_P_flag;
    wire [3:0]Key_R_flag;//�������º��ͷű�־
    
    assign Point=4'hA;
    
    reg[29:0]cnt_s;
    reg[29:0]cnt_flash;//1���ʱ������˸��ʱ��
    reg[3:0]cnt_0;
    reg[3:0]cnt_1;
    reg[3:0]cnt_2;
    reg[3:0]cnt_3;
    reg[3:0]cnt_4;
    reg[3:0]cnt_5;//ʱ�Ӽ�����
    reg[5:0]cnt_inc;//������1��־
    reg[5:0]cnt_dec;//������1��־
    reg[2:0]cnt_inc_c;//ʱ�Ӽ�����
    reg[2:0]cnt_dec_c;//ʱ�Ӽ�����
    reg f_clear;//�����־
    
    //��������
    parameter MCNT_F=25_000_000-1;
    parameter MCNT_S=50_000_000-1;
    
    //״̬��״̬����
    localparam CLOCK=0;
    localparam CLOCK_C=1;
    localparam CALENDAR=2;
    localparam CALENDAR_C=3;
    localparam ALARM=4;
    localparam COUNTER_D=5;
    
    //���������
    hex8 hex8_inst(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .Disp_Data(Data),
    .SEL(SEL),
    .SEG(SEG)
    );
    //��������
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


    //ʱ�����ʱ��ʾ
    
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
            //1���ʱ��
            if(cnt_s==MCNT_S)
                cnt_s<=0;
            else 
                cnt_s<=cnt_s+1'b1;
            
            //����λ����   
            //������1 
            if(cnt_inc[0]==1)
                if(cnt_0==9)begin
                    cnt_0<=0;
                    cnt_inc[1]<=1;
                end
                else 
                    cnt_0<=cnt_0+1'b1;
            //������1 
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
                cnt_dec[1]<=0; //��ս�λ״̬����ֹ��ν�λ
            //�Զ���1     
            else if(cnt_s==MCNT_S)
                if(cnt_0==9)
                    cnt_0<=0;
                else
                    cnt_0<=cnt_0+1'b1;
            //���ʮλ����    
            if(cnt_inc[1]==1)
                if(cnt_1==5)
                    cnt_1<=0;
                else
                    cnt_1<=cnt_1+1'b1;
            //������1
            else if (cnt_dec[1]==1)
                if(cnt_1==0)
                    cnt_1<=5;
                else 
                    cnt_1<=cnt_1-1'b1;
            //������1
            else if((cnt_0==9)&&(cnt_s==MCNT_S))begin
                if(cnt_1==5)
                    cnt_1<=0;
                else
                    cnt_1<=cnt_1+1'b1;
            end   
            //�Զ���1
            
        //���Ӹ�λ����
            if(cnt_inc[2]==1)
                if(cnt_2==9)begin
                    cnt_2<=0;
                    cnt_inc[3]<=1;
                end
                else 
                    cnt_2<=cnt_2+1'b1;
            //������1
            else if (cnt_dec[2]==1)
                if(cnt_2==0)begin
                    cnt_2<=9;
                    cnt_dec[3]<=1;
                end
                else 
                    cnt_2<=cnt_2-1'b1;
            //������1
            else if (cnt_dec[3]==1)
                cnt_dec[3]<=0; 
            else if (cnt_inc[3]==1)
                cnt_inc[3]<=0;  
            //��ս�λ״̬����ֹ��ν�λ
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S))
                if(cnt_2==9)
                    cnt_2<=0;
                else
                    cnt_2<=cnt_2+1'b1;
            //�Զ���1
        
        //����ʮλ����
            if(cnt_inc[3]==1)
                if(cnt_3==5)
                    cnt_3<=0;
                else
                    cnt_3<=cnt_3+1'b1;
            //������1
            else if (cnt_dec[3]==1)
                if(cnt_3==0)
                    cnt_3<=5;
                else 
                    cnt_3<=cnt_3-1'b1;
            //������1
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9))
                if(cnt_3==5)
                    cnt_3<=0;
                else
                    cnt_3<=cnt_3+1'b1; 
        
        //ʱ�Ӹ�λ����
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
            //������1
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
            //������1
            else if (cnt_dec[5]==1)
                cnt_dec[5]<=0; 
            else if (cnt_inc[5]==1)
                cnt_inc[5]<=0;
            //��ս�λ״̬����ֹ��ν�λ 
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
        //ʱ��ʮλ����
            if(f_clear==1)
                cnt_5<=0;
            else if(cnt_inc[5]==1)
                cnt_5<=cnt_5+1'b1;
            //������1
            else if (cnt_dec[5]==1)
                if(cnt_5==0)
                    cnt_5<=2;
                else 
                    cnt_5<=cnt_5-1'b1;
            //������1
            else if((cnt_1==5)&&(cnt_0==9)&&(cnt_s==MCNT_S)&&(cnt_2==9)&&(cnt_3==5)&&(cnt_4==9))
                    cnt_5<=cnt_5+1'b1;
            //�Զ���1
        end
    end 
    //����������ʾ
    calendar calendar_inst(
    .Clk(Clk),
    .Reset_n(Reset_n),
    .cnt_inc(cnt_inc_c),
    .cnt_dec(cnt_dec_c),
    .full_flag(f_clear),
    .Data(Data_calendar)
    );
    //״̬��
    always@(posedge Clk or negedge Reset_n)begin
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
        //��ս�λ״̬����ֹ��ν�λ

    else case(state1)
            CLOCK:begin//ʱ����ʾ
                state2<=0;
                if(Key_P_flag[3]==1)
                    state1<=CLOCK_C;
            end
            CLOCK_C:begin//ʱ������
                if(Key_P_flag[3]==1)
                    state1<=CALENDAR;
                else if(cnt_s!=MCNT_S)
                    
                    case(state2)
                        0:
                            if(Key_P_flag[2]==1)
                                state2<=1;
                            else if(Key_P_flag[1]==1)
                                cnt_inc[0]<=1;//����1������λ��1
                            else if(Key_P_flag[0]==1)
                                cnt_dec[0]<=1;//����0������λ��1
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
            CALENDAR:begin  //������ʾ
                state2<=0;
                if(Key_P_flag[3]==1)
                    state1<=CALENDAR_C;
            end
            CALENDAR_C:begin
                if(Key_P_flag[3]==1)
                    state1<=CLOCK;
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
                endcase//������������
            end
            default:
                state1<=CLOCK;
        endcase
    end
    //��˸��ʱ��
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)
            cnt_flash<=0;
        else
            if(cnt_flash==MCNT_F)
                cnt_flash<=0;
            else
                cnt_flash<=cnt_flash+1;
    end
    //�������ʾ����ѡ��
    always@(posedge Clk)begin
        case(state1)
            CLOCK:
                Data<={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
            CLOCK_C:
                //ʱ��������˸
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
                //����������˸
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
            default:
                state1<=CLOCK;
        endcase
    end
endmodule
