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
    parameter lenOfInput=8;    //the number of input-data bits 
    parameter lenOfOutput=25;  //the number of output-data bits
	parameter numOfPerKnl=16;  //the number of kernel value
	
	// module variables
	reg clk=0;
	reg [lenOfInput-1:0] in_data0, in_data1,  in_data2,  in_data3,  in_data4,  in_data5,  in_data6,  in_data7;
	reg in_start_conv=0;	//start signal of the top module
		
	wire  [lenOfOutput-1:0] out_data0, out_data1;
	
	reg signed [7:0] r_kernels[0:16384]; 
	reg [7:0] r_featureMaps[0:131072];
	integer file_rd;
	// internal variables
	reg [lenOfInput-1:0] kernel[numOfPerKnl-1:0];   //store the value of a kernel
	reg [lenOfInput-1:0] fMap[4095:0];	//per Map
	integer cycleCounter; //the number of cycles during CONV
	integer rowPosOfFMap;	//the row position of FMap
	
	// initial all data and testbench variables
	integer i_knl,i_data,j_data;
	initial begin	
		$readmemb("D:/project_1/testbench/weight_bin_co32xci32xk4xk4.txt",r_kernels);
		$readmemb("D:/project_1/testbench/ifm_bin_c32xh64xw64.txt",r_featureMaps);
		//inital the value of kernel: 0-15
		for(i_knl=0;i_knl<numOfPerKnl;i_knl=i_knl+1)
			kernel[i_knl]=i_knl;
		
		//initial the value of data
		//the 0st row is 0, 1st is 1, 2nd row is 2...
		for(i_data=0;i_data<64;i_data=i_data+1)
			for(j_data=0;j_data<64;j_data=j_data+1)
				fMap[i_data*64+j_data]=i_data;
		
		//inital cycleCounter
		cycleCounter=0;	// [0,1] is read kernel; [2,3] is read the first 4*4 data; [4,33] is read flowing data in the same row
		rowPosOfFMap=0;	//we send the data from the 1st row
		
		in_start_conv=1;	// inital work is done and the top module can start work!
	end
	
	//inital the clk: 500ps turns, T=1000ns
	initial begin	
		forever #0.05 clk=~clk;
	end
	
	// begin to send data and count the cycle
	integer i,j;
	always @(posedge clk) begin
		if(in_start_conv)begin	//wait until initial work is done!
			if(cycleCounter<2) begin	//read kernel
				in_data0=kernel[cycleCounter*8+0];
				in_data1=kernel[cycleCounter*8+1];
				in_data2=kernel[cycleCounter*8+2];
				in_data3=kernel[cycleCounter*8+3];
				in_data4=kernel[cycleCounter*8+4];
				in_data5=kernel[cycleCounter*8+5];
				in_data6=kernel[cycleCounter*8+6];
				in_data7=kernel[cycleCounter*8+7];
			end
			else if(cycleCounter>=2) begin  	//read 4*2 data columns with column priority for each cycle!
				j=(cycleCounter-2)*2;
				in_data0=fMap[rowPosOfFMap*64+j];
				in_data1=fMap[(rowPosOfFMap+1)*64+j];
				in_data2=fMap[(rowPosOfFMap+2)*64+j];
				in_data3=fMap[(rowPosOfFMap+3)*64+j];
				
				in_data4=fMap[rowPosOfFMap*64+j+1];
				in_data5=fMap[(rowPosOfFMap+1)*64+j+1];
				in_data6=fMap[(rowPosOfFMap+2)*64+j+1];
				in_data7=fMap[(rowPosOfFMap+3)*64+j+1];
			end 
			
			cycleCounter=cycleCounter+1;
			if(cycleCounter==34) begin
				cycleCounter=0;	//next row data in the fMap
				rowPosOfFMap=rowPosOfFMap+1; //next row
			end
		end
	end
	//wire [lenOfInput-1:0] in_data0_wire = in_data0;
	topModule top( in_start_conv, clk,
		in_data0, in_data1, in_data2, in_data3, in_data4, in_data5, in_data6, in_data7,  
		out_data0, out_data1 );
endmodule
