# <center>���ϴ�ѧFPGA����ҵ�����๦�ܵ��ӱ�</center>

## һ.���
1. ***����Ҫ��***
[![pV4LwcQ.png](https://s21.ax1x.com/2025/09/22/pV4LwcQ.png)](https://imgse.com/i/pV4LwcQ)
2. ***������***
   ���ĸ�����ͨ���̰��������ʵ��ȫ�����ܡ�
3. ***ʹ�÷���***
   ��sources_1/new�ļ��У���������.v�ļ������ɸ�����Ҫ����sim_1�ļ����е�.tb�����ļ���
## ��.ʵ��˼·
1. ***�����������ʾ***
   �������Ӧ���кܶ�̳̣���֮���������Ӿ���������ѭ��������Ϊ�˷�����ʹ������������cnt���ֱ��ʾʱ����/�����յĸ�λʮλ����������Ҫת���������������ֻ�޸ĺ���λ������ʱ�Ӻ��������ö�������6����������
2. ***��ʱ����***

    ����ֻչʾ1s��ʱ�������ӵļ�ʱ�����Լ������л�������ʱ��Ч�����ƣ�ʱ��ֻ��Ҫ����ֵ�ﵽ24�����㼴��
    ```
    //1���ʱ��
    if(cnt_s==MCNT_S)
        cnt_s<=0;
    else 
        cnt_s<=cnt_s+1'b1;
    ```
    ```
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
    ```
3. ***���ڼ����л�***
   ��������ʱ��ԭ�����ƣ�ֻ��������Ҫ��������1s��ʱ���Ľ�λ�źţ�ֻ��Ҫ����ʱ�Ӽ���24Сʱ��һ�������źŽ��н�λ���ɣ���ʵ�Ҹ��˸о�����Ҳ�У�����ʱ����Ҳ��զ����ͬ����չʾ���ڼ����� cnt_inc &cnt_decΪ����ģ�飨��״̬��������������һ�����ڵļӼ������ź�
    ```
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
            else if (cnt_dec[0]==1)
                if(cnt_0==1&&cnt_1==0) begin
                    if(month_b==1)begin
                        cnt_0<=1;
                        cnt_1<=3;
                    end
                    else if(month_b==0&&cnt_2==2) begin
                        if(leap_year==1) begin
                            cnt_0<=9;
                            cnt_1<=2;
                        end
                        else if(leap_year==0) begin
                            cnt_0<=8;
                            cnt_1<=2;
                        end
                    end
                    else begin
                        cnt_0<=0;
                        cnt_1<=3;
                    end
                end
                else if(cnt_0==0) begin
                    cnt_0<=9;
                    cnt_1<=cnt_1-1;
                end
                else
                    cnt_0<=cnt_0-1;
            //�ռ�����
    ```
    ��ʱ�Ӽ���24Сʱ��ᷢ��һ�����ڵ������źţ�ʹ���ڸ���
    ```
    if(full_flag==1) begin
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
    ```
    ��������ʹ�С�£������������ж��Ƿ�Ϊ4�ı�����������ƽ�꣬��С������ö��
    ```
    always @(*) begin
        if(cnt_3==0)
            case(cnt_2)
                1,3,5,7,8:month_b=1; //����
                default:month_b=0; //С��
            endcase
        else if(cnt_3==1)
            case(cnt_2)
                0,2:month_b=1; //����
                default:month_b=0; //С��
            endcase
    end

    always @(*) begin
        if((cnt_4+cnt_5*10)%4==0)
            leap_year=1; //����
        else
            leap_year=0; //ƽ��
    end
    ```
4. ***���ӹ���***
    ���ӵĻ���ԭ���ʱ�����ƣ�ֻ��������Ҫ�ٽ�������1s���������źţ�����3��������ȷ����������
    ```
    else if(key_state==3)begin//������������
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
    ```
    ���ú����Ӻ���ݴ浽һ��reg�У�����ǰʱ����ڴ�ֵʱled��˸
    ```
    //�����������
    assign Data_clock={cnt_0,cnt_1,Point,cnt_2,cnt_3,Point,cnt_4,cnt_5};
    always@(posedge Clk or negedge Reset_n)begin
        if(!Reset_n)begin
            LED[3]<=0;
            alarm_state<=0;
        end
        else if(state1==COUNTER_D_START&&state2==2)//����ʱ������˸
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
    ```
5. ***����ʱ����***
   ��Ƶ���ʱ��ԭ�������ʱ�����ƣ�ͬ��Ҳ�ǳ�������3��ʼ����ʱ����ʼ��̰�����3������ͣ/���¿�ʼ����ͣʱ��������3����ʱ���س�ʼֵ��ͬ������״̬��ʵ�֡�
   ```
   COUNTER_D_SET:begin
                reset_flag<=0;
                if(Key_P_flag[3]==1)
                    state1<=CLOCK;
                else if(key_state==3)begin//������ʼ����ʱ
                    state1<=COUNTER_D_START;
                    start_flag<=1;
                    state2<=0;
                end
                else
                    case(state2)
                        0:
                            if(key_state==2)//�̰��л�����ʱλ��
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
                    0:begin//����ʱ��ʼ
                        
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
                    1:begin//����ʱ��ͣ
                        count_d<=0;
                        if(key_state==2)
                            state2<=0;
                        else if(key_state==3)begin//������λ
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
                    2:begin//����ʱ������˸
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
   ```
6. ***��״̬��***
    һ���߸�״̬��ͨ������4ѭ��������ʱ��ʼ״̬��Ҫ��������3���룬����ʱ�������Զ��л���״̬1������״̬����������״̬��ʵ��ʱ������л��ȹ��ܡ�
    ```
    ����̫�������ˣ���Ҵ��ļ��Լ�����
    ```
7. ***����Сģ��***
   - *3-8������*

        ûɶ˵�ģ��������ʾ������
   - *��������*
        �������Ǽ�⵽���غ��20ms�ټ��飬��������õķ�ʽʱ��⵽���غ����20msû������������ȷ������/�ͷ�
   - *�������̰�*
        ������״̬��
        ```
        //�����������
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
        ```
   - *LED��˸*
        ʹ�ø��ֶ�ʱ��ʵ����˸��������ͣ����֮���
## ��.��ʾЧ��
��ʾ��Ƶ��https://www.bilibili.com/video/BV1KcafzzEUS/#reply115168541413589
�������лл��
## ��.�ܽ�
�����ҵĵ�һ��FPGA��Ŀ���ӿ�ʼѧ�����Ҳ�����ܣ�����󲿷�Ҳ���Լ����ã��кܶ಻������£�ͬʱ��Ҳ���ҵ�һ����Դ��Ŀ��ϣ���ܶԴ��ѧϰ��һ�������������������bվ˽���ң��ҿ���һ�������ظ���
�ֿ��ַ��https://github.com/boxtwo-ylj/SEU-FPGA-homework-electric-clock