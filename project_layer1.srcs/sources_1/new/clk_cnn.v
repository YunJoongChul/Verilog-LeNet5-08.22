`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/21 17:57:46
// Design Name: 
// Module Name: clk_cnn
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


module clk_cnn(clk, clk_out);
input clk;
output clk_out;
wire locked;
reg [24:0] cnt;
wire clk_out1;
clk_wiz_0 DUT(.clk_in1(clk), .locked(locked), .clk_out1(clk_out1));

endmodule
