`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/30 20:11:43
// Design Name: 
// Module Name: PE
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

module PE(
input clk,
input[16383:0] featureMap,  //8*64 
input [1023:0] kernelMap,
input[8:0] nc, //通道的个数  
output[1525:0] ofm 
    );
    parameter fsize=5;
    parameter ksize=3;
wire [7:0]r_fmap[0:2047];
wire [7:0]r_kernel[0:127];

genvar i;
	generate 
	for (i=0;i<2048;i=i+1)  begin: gfmap  //将fmap的一行拆开
		assign  r_fmap[i]= featureMap[8*i+7:8*i];
	end
	for (i=0;i<128;i=i+1)  begin: gkernel  //将kernel的一行拆开
			assign  r_kernel[i]= kernelMap[8*i+7:8*i];
		end
endgenerate
reg[24:0] sum [0:fsize-ksize+1-1];
integer j,k;
initial begin
	for(j=0;j<fsize-ksize+1; j=j+1)begin
	// delta=2*nc
		sum[j]=0;
	end
end
reg [24:0]temp; 
always@(posedge clk)begin
	temp=r_kernel[0]*r_fmap[0];
	for(j=0;j<fsize-ksize+1; j=j+1)begin
		// delta=2*nc
		if(sum[j]==0)begin //此处可优化 ,sumj=表示未被加过
			for(k=0;k<ksize*nc;k=k+1)begin
				sum[j]=sum[j]+r_kernel[k]*r_fmap[k+nc*j];
			end
		end
	end
end
generate 
	for (i=0;i<63;i=i+1)  begin: peout  //将fmap的一行拆开
		assign  ofm[i*25+24:i*25]= sum[i];
	end

endgenerate
//assign ofm=sum;
endmodule
