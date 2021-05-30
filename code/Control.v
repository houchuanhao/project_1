`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/31 00:21:51
// Design Name: 
// Module Name: Control
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


module Control(
input clk,
output read_I,
input[63:0] Idata,
output read_W,
input wdata,
output write_o,
output Odata,
input start_conv,
output end_cov,
input[8:0] cfg_ci, //通道数默认32
input[1:0] cfg_co //kernel个数默认32
    );
reg [16383:0] feature_row[0:63];
reg [511:0] kernel_row[0:3];
reg [24:0] result[0:244];
reg [7:0] kernel[0:16*32*32-1];
reg [7:0] fMap[0:64*64*32-1];
genvar i,j,k;
integer m;
generate 
	for(i=0;i<64;i=i+1)begin: ccc
		if(i<4) begin
			for(j=i;j>0;j=j-1)begin 
			//行号：j
			//列号: i-j
			//PE号：j+(i-j)*4
				PE pe(clk,feature_row[i],kernel_row[j],cfg_ci,result[j+(i-j)*4]);
			end
		end 
		else begin
			//行号：j
			//列号: j+1
			//PE号：j+(j+1)*4
			for(j=i;j>=0&&j+1<64;j=j-1)begin 
				PE pe(clk,feature_row[i],kernel_row[j],cfg_ci,result[j+(j+1)*4]);
			end
		end
	end
endgenerate
	reg [7:0]row_number;
	reg [7:0]in_row_id; //0-256
    reg[7:0] status=0;
    integer c;
    always@(posedge clk)begin
    	if(start_conv==0)begin
    		status=1;
    	end
    	c=in_row_id;
    	if(status==1)begin
    		
    	end
    end
endmodule
