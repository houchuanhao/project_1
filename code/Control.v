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
wire [16383:0] feature_row[0:63];
wire [511:0] kernel_row[0:3];
reg [24:0] result[0:244];
reg [7:0] kernel[0:16*32*32-1];
reg [7:0] fMap[0:64*64*32-1];
genvar i,j,k;
generate
	for(j=0;j<64;j=j+1)begin
			for (i=0;i<2048;i=i+1)  begin: gfmap1  //一行
				assign  feature_row[999][i*8+7: i*8]=fMap[i];
			end
	end

		for (i=0;i<128;i=i+1)  begin: gkernel1  //一行
			assign  kernel_row[999][i*8+7: i*8]=kernel[i];
		end
endgenerate


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
