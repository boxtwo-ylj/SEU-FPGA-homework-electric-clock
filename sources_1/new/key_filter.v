`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/02 21:07:11
// Design Name: 
// Module Name: key_filter
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


module key_filter(
    Clk,
    Reset_n,
    Key,
    Key_P_flag,
    Key_R_flag
    );
    input Clk;
    input Reset_n;
    input Key;
    output reg Key_P_flag;
    output reg Key_R_flag;
    
    reg sync_d0_Key;
    reg sync_d1_Key;
    reg Key_r;
    reg [1:0]state;
    reg [29:0]cnt;
    
    
    wire Key_pedge;
    wire Key_nedge;
    wire timewait_20ms;
    
    parameter MCNT=1_000_000;
    localparam IDLE=0;
    localparam P_FILTER=1;
    localparam WAIT_R=2;
    localparam R_FILTER=3;
    
    always@(posedge Clk)
        sync_d0_Key<=Key;
    always@(posedge Clk)
        sync_d1_Key<=sync_d0_Key;
        
    always@(posedge Clk)
        Key_r<=sync_d1_Key;
     
    assign Key_pedge=(Key_r==0)&&(sync_d1_Key==1);
    assign Key_nedge=(Key_r==1)&&(sync_d1_Key==0);
    
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        cnt<=0;
    else if((state==P_FILTER)||(state==R_FILTER))
        cnt<=cnt+1'b1;
    else
        cnt<=0;
        
    assign timewait_20ms=cnt>=MCNT;
    
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)begin
        state<=0;
        Key_P_flag<=0;
        Key_R_flag<=0;
    end
    else 
        case(state)
            IDLE:begin
                Key_R_flag<=0;
                if(Key_nedge==1)begin
                    state<=P_FILTER;
                end
            end
            P_FILTER:begin
                if(timewait_20ms)begin
                    Key_P_flag<=1;
                    state<=WAIT_R;
                end
                else if(Key_pedge==1)
                    state<=IDLE;
                else 
                    state<=state;
            end
            WAIT_R:begin
                Key_P_flag<=0;
                if(Key_pedge==1)begin
                    state<=R_FILTER;
                end
            end
            R_FILTER:begin
                if(timewait_20ms)begin
                    Key_R_flag<=1;
                    state<=IDLE;
                end
                else if(Key_nedge==1)
                    state<=WAIT_R;
                else 
                    state<=state;
            end
            endcase
endmodule
