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


module layer2(clk, rst, start, dout_layer1, addr_layer1, addr_layer2, dout, done);
(*keep = "ture"*)input clk, rst, start;
(*keep = "ture"*)input [7:0] addr_layer2;

(*keep = "ture"*)input [131:0] dout_layer1;

(*keep = "ture"*)output reg [8:0] addr_layer1;
(*keep = "ture"*)output reg done;

(*keep = "ture"*)output  [65:0] dout;
(*keep = "ture"*)reg [65:0] din_layer2;
(*keep = "ture"*)reg [65:0] max_high, max_low;

(*keep = "ture"*)reg [7:0] addr_layer2_reg;

(*keep = "ture"*)reg wea ;
(*keep = "ture"*)reg [3:0] state;
(*keep = "ture"*)reg [15:0] cnt_col_stride, cnt_row_stride, cnt_entire;
(*keep = "ture"*)reg [1:0] cnt_max_ctrl;

layer2_o u0(.clka(clk) ,.wea(wea), .addra(addr_layer2_reg), .dina(din_layer2), .clkb(clk), .addrb(addr_layer2), .doutb(dout));
localparam IDLE = 3'd0, MAXPOOLING_HIGH = 3'd1, MAXPOOLING_LOW = 3'd2, DONE = 3'd3;
localparam OUT_SIZE = 8'd196, INPUT_SIZE = 9'd391;

always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
        IDLE : if(start) state <= MAXPOOLING_HIGH ; else state <= IDLE;
        MAXPOOLING_HIGH : state <= MAXPOOLING_LOW;
        MAXPOOLING_LOW : if(addr_layer2_reg == OUT_SIZE - 1'd1 && cnt_max_ctrl == 2'd1) state <=  DONE; else state <= MAXPOOLING_HIGH;
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
        MAXPOOLING_LOW : if(cnt_col_stride == 4'd13) cnt_col_stride <= 0; else cnt_col_stride <= cnt_col_stride + 1'd1;
        default : cnt_col_stride <= cnt_col_stride;
        endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_row_stride <= 16'd0;
    else
        case(state)
        MAXPOOLING_LOW : if(cnt_col_stride == 4'd13) cnt_row_stride <= cnt_row_stride + 6'd28; else cnt_row_stride <= cnt_row_stride;
        default : cnt_row_stride <= cnt_row_stride;
        endcase
end


always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_layer1 <= 13'd0;
    else
        if(addr_layer1 <= INPUT_SIZE ) // layer1 output addr final
            case(state)
            MAXPOOLING_HIGH : addr_layer1 <=  cnt_col_stride + cnt_row_stride;
            MAXPOOLING_LOW : addr_layer1 <= 7'd14 + cnt_col_stride + cnt_row_stride;
            default : addr_layer1 <= addr_layer1;
            endcase
       else
           addr_layer1 <= addr_layer1;
end
        

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_entire <= 16'd0;
    else
        case(state)
            IDLE : cnt_entire <= 16'd0;
            default cnt_entire <= cnt_entire + 1'd1;
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
            default : cnt_max_ctrl <= 2'd0;           
            endcase
end
    
always@(posedge clk or posedge rst)
begin
    if(rst)
        max_high <= 32'd0;
    else
       case(cnt_max_ctrl)
       2'd1: begin
          max_high[65:55] <= (dout_layer1[131:121] > dout_layer1[65:55] ) ?  dout_layer1[131:121] : dout_layer1[65:55];
          max_high[54:44] <= (dout_layer1[120:110] > dout_layer1[54:44] ) ?  dout_layer1[120:110] : dout_layer1[54:44];
          max_high[43:33] <= (dout_layer1[109:99] > dout_layer1[43:33] ) ?  dout_layer1[109:99] : dout_layer1[43:33];
          max_high[32:22] <= (dout_layer1[98:88] > dout_layer1[32:22] ) ?  dout_layer1[98:88] : dout_layer1[32:22];
          max_high[21:11] <= (dout_layer1[87:77] > dout_layer1[21:11] ) ?  dout_layer1[87:77] : dout_layer1[21:11];
          max_high[10:0]  <= (dout_layer1[76:66] > dout_layer1[10:0] ) ?  dout_layer1[76:66] : dout_layer1[10:0];
          end
       default : max_high <= max_high;
       endcase
end        
        
always@(posedge clk or posedge rst)
begin
    if(rst)
        max_low <= 32'd0;
    else
       case(cnt_max_ctrl)
       2'd2 : begin
           max_low[65:55] <= (dout_layer1[131:121] > dout_layer1[65:55] ) ?  dout_layer1[131:121] : dout_layer1[65:55];
           max_low[54:44] <= (dout_layer1[120:110] > dout_layer1[54:44] ) ?  dout_layer1[120:110] : dout_layer1[54:44];
           max_low[43:33] <= (dout_layer1[109:99] > dout_layer1[43:33] ) ?  dout_layer1[109:99] : dout_layer1[43:33];  
           max_low[32:22] <= (dout_layer1[98:88] > dout_layer1[32:22] ) ?  dout_layer1[98:88] : dout_layer1[32:22];    
           max_low[21:11] <= (dout_layer1[87:77] > dout_layer1[21:11] ) ?  dout_layer1[87:77] : dout_layer1[21:11];    
           max_low[10:0]  <= (dout_layer1[76:66] > dout_layer1[10:0] ) ?  dout_layer1[76:66] : dout_layer1[10:0];      
           end 
       default : max_low <= max_low;
       endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
        din_layer2 <= 66'd0;
    else
        case(state)
        MAXPOOLING_LOW : begin
                         din_layer2[65:55] <= (max_high[65:55] > max_low[65:55]) ? max_high[65:55] : max_low[65:55];
                         din_layer2[54:44] <= (max_high[54:44] > max_low[54:44]) ? max_high[54:44] : max_low[54:44];
                         din_layer2[43:33] <= (max_high[43:33] > max_low[43:33]) ? max_high[43:33] : max_low[43:33];
                         din_layer2[32:22] <= (max_high[32:22] > max_low[32:22]) ? max_high[32:22] : max_low[32:22];
                         din_layer2[21:11] <= (max_high[21:11] > max_low[21:11]) ? max_high[21:11] : max_low[21:11];
                         din_layer2[10:0] <= (max_high[10:0] > max_low[10:0]) ? max_high[10:0] : max_low[10:0];
                         end
        default : din_layer2 <= din_layer2;
        endcase
end 

always@(posedge clk or posedge rst)
begin
    if(rst)
         addr_layer2_reg <= 8'd0;
    else if(cnt_entire < 16'd5)
          addr_layer2_reg <=8'd0;
    else
        case(state)
            MAXPOOLING_HIGH :if(cnt_max_ctrl == 2'd2) addr_layer2_reg <= addr_layer2_reg + 1'd1; else  addr_layer2_reg <= addr_layer2_reg;
            default : addr_layer2_reg <= addr_layer2_reg;         
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
        default : wea <= 1'd0;
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
