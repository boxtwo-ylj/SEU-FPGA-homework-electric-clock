# <center>东南大学FPGA大作业——多功能电子表</center>

## 一.简介
1. ***基本要求：***
[![pV4LwcQ.png](https://s21.ax1x.com/2025/09/22/pV4LwcQ.png)](https://imgse.com/i/pV4LwcQ)
2. ***完成情况***
   用四个按键通过短按长按组合实现全部功能。
3. ***使用方法***
   打开sources_1/new文件夹，导入所有.v文件，随后可根据需要导入sim_1文件夹中的.tb仿真文件。
## 二.实现思路
1. ***基本数码管显示***
   这个网上应该有很多教程，总之就是利用视觉暂留进行循环点亮。为了方便我使用六个计数器cnt来分别表示时分秒/年月日的个位十位，这样不需要转换进制其中年份我只修改后两位，这样时钟和日历正好都可以用6个计数器。
2. ***计时功能***

    这里只展示1s计时器和秒钟的计时功能以及按键切换，分钟时钟效果类似，时钟只需要在数值达到24后清零即可
    ```
    //1秒计时器
    if(cnt_s==MCNT_S)
        cnt_s<=0;
    else 
        cnt_s<=cnt_s+1'b1;
    ```
    ```
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
    ```
3. ***日期及其切换***
   本质上与时钟原理类似，只不过不需要接收来自1s计时器的进位信号，只需要接收时钟计满24小时的一个脉冲信号进行进位即可（其实我个人感觉不加也行，验收时可能也不咋看）同样仅展示日期计数器 cnt_inc &cnt_dec为其他模块（如状态机按键）发出的一个周期的加减脉冲信号
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
            //日计数器
    ```
    当时钟计满24小时后会发出一个周期的脉冲信号，使日期更新
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
    关于闰年和大小月，这里我是用判断是否为4的倍数决定闰年平年，大小月则是枚举
    ```
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
    ```
4. ***闹钟功能***
    闹钟的基本原理和时钟类似，只不过不需要再接收来自1s计数器的信号，按键3长按可以确认设置闹钟
    ```
    else if(key_state==3)begin//长按设置闹钟
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
    设置好闹钟后会暂存到一个reg中，当当前时间等于此值时led闪烁
    ```
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
    ```
5. ***倒计时功能***
   设计倒计时的原理和设置时钟类似，同样也是长按按键3开始倒计时，开始后短按按键3可以暂停/重新开始，暂停时长按按键3倒计时返回初始值，同样利用状态机实现。
   ```
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
   ```
6. ***主状态机***
    一共七个状态，通过按键4循环（倒计时开始状态需要长按按键3进入，倒计时结束后自动切换回状态1）在主状态机下又有子状态机实现时分秒的切换等功能。
    ```
    代码太长不贴了，大家打开文件自己看吧
    ```
7. ***其他小模块***
   - *3-8译码器*

        没啥说的，数码管显示附带的
   - *按键消抖*
        基本就是检测到边沿后等20ms再检验，我这里采用的方式时检测到边沿后如果20ms没有其他边沿则确定按下/释放
   - *按键长短按*
        利用了状态机
        ```
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
        ```
   - *LED闪烁*
        使用各种定时器实现闪烁和亮几秒停几秒之类的
## 三.演示效果
演示视频：https://www.bilibili.com/video/BV1KcafzzEUS/#reply115168541413589
点点三连谢谢喵
## 四.总结
这是我的第一个FPGA项目，从开始学到完成也才两周，代码大部分也是自己手敲，有很多不足请见谅；同时这也是我第一个开源项目，希望能对大家学习有一定帮助，有问题可以在b站私信我，我看到一定尽量回复。
仓库地址：https://github.com/boxtwo-ylj/SEU-FPGA-homework-electric-clock