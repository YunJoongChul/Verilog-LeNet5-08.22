`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/03 14:28:20
// Design Name: 
// Module Name: layer1_tb
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


module layer1_tb();
reg clk, rst, start;
wire   [7:0] dout;
top DUT(clk, rst, start, dout);
always #12.5 clk = ~clk;

initial begin
clk = 0; rst = 0; start = 0;
#425; 
#75 rst = 1;
#75 rst = 0;
#50000 start = 1;
#25 start = 0;
#42500;
end


endmodule

