`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/04 14:24:26
// Design Name: 
// Module Name: top
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


module top(clk, rst, start, TXD);

(*keep = "ture"*)input clk, rst, start;
(*keep = "ture"*)output  TXD;


(*keep = "ture"*)wire layer1_done, layer2_done, layer3_done, layer4_done, layer5_done, layer6_done, layer7_done, predict_done;

(*keep = "ture"*)wire [8:0] addr_layer1;
(*keep = "ture"*)wire [7:0] addr_layer2;
(*keep = "ture"*)wire [9:0]  addr_layer3; 
(*keep = "ture"*)wire [8:0] addr_layer4;
(*keep = "ture"*)wire [6:0] addr_layer5;
(*keep = "ture"*)wire [6:0] addr_layer6;
(*keep = "ture"*)wire [3:0] addr_layer7;

(*keep = "ture"*)wire signed [131:0] dout_layer1;
(*keep = "ture"*)wire signed [65:0] dout_layer2;
(*keep = "ture"*)wire signed [21:0] dout_layer3;
(*keep = "ture"*)wire signed [10:0] dout_layer4;
(*keep = "ture"*)wire signed [10:0] dout_layer5;
(*keep = "ture"*)wire signed [10:0] dout_layer6;
(*keep = "ture"*)wire signed [10:0] dout_layer7;
(*keep = "ture"*)wire [7:0] dout_predict;

(*keep = "ture"*)wire done;
(*keep = "ture"*)wire clk_uart, clk_cnn;
(*keep = "ture"*)wire locked;
clk_wizard1 x0(.clk_in1(clk), .locked(locked), .clk_out1(clk_cnn));
//clk_divider x1(.clk(clk), .clk_out(clk_uart));

layer1 u0(.clk(clk_cnn), .rst(rst), .start(start), .addr_layer1(addr_layer1), .dout(dout_layer1), .done(layer1_done)); 
layer2 u1(.clk(clk_cnn), .rst(rst), .start(layer1_done), .dout_layer1(dout_layer1), .addr_layer1(addr_layer1), .addr_layer2(addr_layer2),.dout(dout_layer2), .done(layer2_done));
layer3 u2(.clk(clk_cnn), .rst(rst), .start(layer2_done), .dout_layer2(dout_layer2), .addr_layer2(addr_layer2), .addr_layer3(addr_layer3),.dout(dout_layer3), .done(layer3_done));
layer4 u3(.clk(clk_cnn), .rst(rst), .start(layer3_done), .dout_layer3(dout_layer3), .addr_layer3(addr_layer3), .addr_layer4(addr_layer4), .dout(dout_layer4), .done(layer4_done));
layer5 u4(.clk(clk_cnn), .rst(rst), .start(layer4_done), .dout_layer4(dout_layer4), .addr_layer4(addr_layer4), .addr_layer5(addr_layer5), .dout(dout_layer5), .done(layer5_done));
layer6 u5(.clk(clk_cnn), .rst(rst), .start(layer5_done), .dout_layer5(dout_layer5), .addr_layer5(addr_layer5), .addr_layer6(addr_layer6), .dout(dout_layer6), .done(layer6_done));
layer7 u6(.clk(clk_cnn), .rst(rst), .start(layer6_done), .dout_layer6(dout_layer6), .addr_layer6(addr_layer6), .addr_layer7(addr_layer7), .dout(dout_layer7), .done(layer7_done));
predict u7(.clk(clk_cnn), .start(layer7_done), .rst(rst), .dout_layer7(dout_layer7), .addr_layer7(addr_layer7), .predict_dout(dout_predict), .done(predict_done));
TX u8(.clk(clk_cnn), .start(predict_done), .rst(rst), .din(dout_predict), .tx_data(TXD));
endmodule
