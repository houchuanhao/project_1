`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 21:50:42
// Design Name: 
// Module Name: tb_topModule
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



// the storage of kernel is via row priority, and we get kernel via row priority!
// the storage of data is via row priority, but we get data via column priority!!
module tb_topModule();
	// Configuration of the CONV-Project
	integer numOfKernels=8;
	integer numOfChannels=8;
	
	parameter lenOfInput=8;    //the number of input-data bits 
    parameter lenOfOutput=25;  //the number of output-data bits
	parameter numOfPerKnl=16;  //the number of kernel value
	parameter numOfPerFMap=4096;  //the number of kernel value
	
	// module variables
	//input
	reg clk=0;
	reg [lenOfInput-1:0] in_data0, in_data1,  in_data2,  in_data3,  in_data4,  in_data5,  in_data6,  in_data7;
	reg in_start_conv=0;	//start signal of the top module
	reg [2:0] in_cfg_ci;  //the number of channels,  		0 means 8, 1 means 16, 3 means 24, 3 means 32
    reg [2:0] in_cfg_co;      //the number of kernels,         0 means 8, 1 means 16, 3 means 24, 3 means 32
	//output
	wire [lenOfOutput-1:0] out_data0, out_data1;
	wire out_end_conv;
	
	
	// internal variables
	reg [lenOfInput-1:0] kernel[0:numOfPerKnl*32*32-1];   //store the value of a kernel, 32 kernels with 32 channels
	reg [lenOfInput-1:0] fMap[0:numOfPerFMap*32-1];	//per fMap, 32 fMap with 32 channels  
	
	// initial all data and testbench variables
	integer temp; //temporary variable
	integer i_knl,j_chnl,k_value; //variables for kernel initialization
	wire [16383:0] w_feature;
	wire [1023:0] w_kernelMap;
	wire [16:0] peout;
	reg [8:0] kernelNumber=2;
	initial begin	
		forever #0.05 clk=~clk;
	end
	genvar i;
	generate 
		for (i=0;i<2048;i=i+1)  begin: gfmap  //一行
			assign  w_feature[i*8+7: i*8]=fMap[i];
		end
		for (i=0;i<128;i=i+1)  begin: gkernel  //一行
			assign  w_kernelMap[i*8+7: i*8]=kernel[i];
		end
	endgenerate
	PE   pe1(clk,w_feature,w_kernelMap,kernelNumber,peout);
	initial begin	
		$readmemb("D:/project_1/testbench/weight_bin_co32xci32xk4xk4.txt",kernel);
		$readmemb("D:/project_1/testbench/ifm_bin_c32xh64xw64.txt",fMap);
	end


	
	
endmodule