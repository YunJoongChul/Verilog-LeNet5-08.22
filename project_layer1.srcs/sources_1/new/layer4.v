`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/04 14:18:26
// Design Name: 
// Module Name: layer2
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


module layer4(clk, rst, start, dout_layer3, addr_layer3, addr_layer4, dout, done);
(*keep = "ture"*)input clk, rst, start;
(*keep = "ture"*)input [8:0] addr_layer4;

(*keep = "ture"*)input signed [21:0] dout_layer3;

(*keep = "ture"*)output reg [9:0] addr_layer3;
(*keep = "ture"*)output reg done;

(*keep = "ture"*)output signed [10:0] dout;
(*keep = "ture"*)reg signed [10:0] din_layer4;
(*keep = "ture"*)reg signed [10:0] max_high, max_low;

(*keep = "ture"*)reg [8:0] addr_layer4_reg;

(*keep = "ture"*)reg wea ;
(*keep = "ture"*)reg [3:0] state;
(*keep = "ture"*)reg [15:0] cnt_col_stride, cnt_row_stride, cnt_entire;
(*keep = "ture"*)reg [1:0] cnt_max_ctrl;


layer4_o u0(.clka(clk) ,.wea(wea), .addra(addr_layer4_reg), .dina(din_layer4), .clkb(clk), .addrb(addr_layer4), .doutb(dout));


localparam IDLE = 3'd0, MAXPOOLING_HIGH = 3'd1, MAXPOOLING_LOW = 3'd2, DONE = 3'd3;
localparam OUT_SIZE = 9'd400, INPUT_SIZE = 10'd800;


always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
        IDLE : if(start) state <= MAXPOOLING_HIGH ; else state <= IDLE;
        MAXPOOLING_HIGH : state <= MAXPOOLING_LOW;
        MAXPOOLING_LOW : if(addr_layer4_reg == OUT_SIZE - 1'd1 && cnt_max_ctrl == 2'd1) state <=  DONE; else state <= MAXPOOLING_HIGH;
        //DONE : if(addr_layer4 == 399) state <= IDLE; else state <= DONE; //good write?  confirm
        DONE : state <= IDLE;
        default : state <= IDLE;
        endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_col_stride <= 16'd0;
    else
        case(state)
        MAXPOOLING_LOW : if(cnt_col_stride == 3'd4) cnt_col_stride <= 16'd0; else cnt_col_stride <= cnt_col_stride + 1'd1;
        default : cnt_col_stride <= cnt_col_stride;
        endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row_stride <= 16'd0;
    else
        case(state)
        MAXPOOLING_LOW : if(cnt_col_stride == 3'd4) cnt_row_stride <= cnt_row_stride + 6'd10; else cnt_row_stride <= cnt_row_stride;
        default : cnt_row_stride <= cnt_row_stride;
        endcase
end


always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_layer3 <= 13'd0;
    else
        if(addr_layer3 < INPUT_SIZE)
            case(state)
            MAXPOOLING_HIGH : addr_layer3 <=  cnt_col_stride + cnt_row_stride;
            MAXPOOLING_LOW : addr_layer3 <= 7'd5 + cnt_col_stride + cnt_row_stride;
            default : addr_layer3 <= addr_layer3;
            endcase
     else
          addr_layer3 <= addr_layer3;       
end
        

always@(posedge clk or posedge rst)
begin
    if(rst)
       cnt_entire <= 16'd0;
    else
        case(state)
            IDLE :cnt_entire <= 16'd0;
            default : cnt_entire <= cnt_entire + 1'd1;
            endcase
end
    
always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_max_ctrl <= 16'd0;
    else if(cnt_entire < 16'd2)
        cnt_max_ctrl <= 16'd0;
    else
        case(state)
            MAXPOOLING_HIGH : cnt_max_ctrl <= 2'd1;
            MAXPOOLING_LOW :  cnt_max_ctrl <= 2'd2;
            default : cnt_max_ctrl <= 0;           
            endcase
end
    
always@(posedge clk or posedge rst)
begin
    if(rst)
        max_high <= 32'd0;
    else
       case(cnt_max_ctrl)
       2'd1: max_high <= (dout_layer3[21:11] > dout_layer3[10:0] ) ?  dout_layer3[21:11] : dout_layer3[10:0];
       default : max_high <= max_high;
       endcase
end        
        
always@(posedge clk or posedge rst)
begin
    if(rst)
        max_low <= 32'd0;
    else
       case(cnt_max_ctrl)
       2'd2 : max_low <=(dout_layer3[21:11] > dout_layer3[10:0] ) ?  dout_layer3[21:11] : dout_layer3[10:0];
       default : max_low <= max_low;
       endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
        din_layer4 <= 32'd0;
    else
        case(state)
        MAXPOOLING_LOW : din_layer4 <= (max_high > max_low) ? max_high : max_low;
        default : din_layer4 <= din_layer4;
        endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
         addr_layer4_reg <= 9'd0;
    else if(cnt_entire < 16'd5)
          addr_layer4_reg <= 9'd0;
    else
        case(state)
            MAXPOOLING_HIGH :if(cnt_max_ctrl == 2'd2) addr_layer4_reg <= addr_layer4_reg + 1'd1; else  addr_layer4_reg <= addr_layer4_reg;
            default : addr_layer4_reg <= addr_layer4_reg;         
            endcase
end

 always@(posedge clk or posedge rst)
begin
    if(rst)
        wea <= 1'd0;
    else if(cnt_entire < 16'd4)
             wea <= 1'd0;
     else
        case(state)
        MAXPOOLING_LOW : if(cnt_max_ctrl == 2'd1) wea <= 1'd1; else wea <= 1'd0;
        default : wea <=1'd0;
        endcase
end                         
always@(posedge clk or posedge rst)
begin
    if(rst)
        done <= 1'd0;
    else
        case(state)
        DONE : done <= 1'd1;
        default : done <= 1'd0;
        endcase
end

   
endmodule