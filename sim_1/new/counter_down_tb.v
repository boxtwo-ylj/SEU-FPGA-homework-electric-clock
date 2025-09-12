`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/08 14:23:24
// Design Name: 
// Module Name: counter_down_tb
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


module counter_down_tb();
    reg Clk;
    reg Reset_n;
    reg [2:0] cnt_inc;
    reg [2:0] cnt_dec;
    reg cnt_down;
    reg start_flag;
    reg reset_flag;
    wire [31:0] Data;

    counter_down uut (
        .Clk(Clk),
        .Reset_n(Reset_n),
        .cnt_inc(cnt_inc),
        .cnt_dec(cnt_dec),
        .cnt_down(cnt_down),
        .start_flag(start_flag),
        .reset_flag(reset_flag),
        .Data(Data)
    );

    initial begin
        // Initialize Inputs
        Clk = 0;
        Reset_n = 0;
        cnt_inc = 3'b000;
        cnt_dec = 3'b000;
        cnt_down = 0;
        start_flag = 0;
        reset_flag = 0;

        // Wait for global reset to finish
        #10;
        Reset_n = 1;

        // Add stimulus here
        #20;
        cnt_inc = 3'b001; // Increment units place
        #200;
        cnt_inc = 3'b000;

        #40;
        cnt_inc = 3'b010; // Increment tens place
        #200;
        cnt_inc = 3'b000;

        #40;
        cnt_dec = 3'b001; // Decrement units place
        #200;
        cnt_dec = 3'b000;

        #40;
        cnt_dec = 3'b010; // Decrement tens place
        #200;
        cnt_dec = 3'b000;

        #40;
        cnt_dec = 3'b100; // Decrement tens place
        #200;
        cnt_dec = 3'b000;
        #40;
        start_flag = 1;
        cnt_down = 1;
        #20;
        start_flag=0;
        #10000;
        cnt_down = 0;
        reset_flag = 1;
        #40;
        reset_flag = 0;
        

        #4000;
        $finish; // End simulation
    end

    always #10 Clk = ~Clk; // Clock generation
endmodule
