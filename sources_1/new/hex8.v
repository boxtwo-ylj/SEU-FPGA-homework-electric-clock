`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/03 20:45:22
// Design Name: 
// Module Name: hex8
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


module hex8(
    Clk,
    Reset_n,
    Disp_Data,
    SEL,
    SEG
    );
    input Clk;
    input Reset_n;
    input [31:0]Disp_Data;
    output wire[7:0]SEL;
    output reg[7:0]SEG;
    
    reg [29:0]cnt;
    reg [2:0]cnt_sel;
    reg [3:0]data_temp;
    
    
    parameter MCNT=50_000-1;
    parameter MCNT_sel=8-1;
    
    
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        cnt<=0;
    else if(cnt==MCNT)
        cnt<=0;
    else 
        cnt<=cnt+1'b1;
        
    always@(posedge Clk or negedge Reset_n)
    if(!Reset_n)
        cnt_sel<=0;
    else if(cnt==MCNT)begin
        if(cnt_sel==MCNT_sel)
            cnt_sel<=0;
        else
            cnt_sel<=cnt_sel+1'b1;
        end
     
    decoder_3_8 decoder_3_8_inst(
    .a(cnt_sel[2]),
    .b(cnt_sel[1]),
    .c(cnt_sel[0]),
    .out(SEL)
   );
//    always@(posedge Clk)
//    case(cnt_sel)
//        0:SEL<=8'b0000_0001;
//        1:SEL<=8'b0000_0010;
//        2:SEL<=8'b0000_0100;
//        3:SEL<=8'b0000_1000;
//        4:SEL<=8'b0001_0000;
//        5:SEL<=8'b0010_0000;
//        6:SEL<=8'b0100_0000;
//        7:SEL<=8'b1000_0000;
//    endcase
   
    always@(posedge Clk)
    case(data_temp)
        0:SEG<=8'b1100_0000;
        1:SEG<=8'b1111_1001;
        2:SEG<=8'b1010_0100;            
        3:SEG<=8'b1011_0000;
        4:SEG<=8'b1001_1001;
        5:SEG<=8'b1001_0010;
        6:SEG<=8'b1000_0010;
        7:SEG<=8'b1111_1000;
        8:SEG<=8'b1000_0000;
        9:SEG<=8'b1001_0000;
        10:SEG<=8'b1011_1111;
        default:SEG<=8'b0000_0000;
    endcase
   
    always@(*)
    case(cnt_sel)
        0:data_temp<=Disp_Data[3:0];
        1:data_temp<=Disp_Data[7:4];
        2:data_temp<=Disp_Data[11:8];
        3:data_temp<=Disp_Data[15:12];
        4:data_temp<=Disp_Data[19:16];
        5:data_temp<=Disp_Data[23:20];
        6:data_temp<=Disp_Data[27:24];
        7:data_temp<=Disp_Data[31:28];
    endcase
    
    
endmodule
