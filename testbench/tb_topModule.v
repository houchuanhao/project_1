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
	wire out_writeCtl;
	
	
	// internal variables
	reg [lenOfInput-1:0] kernel[numOfPerKnl*32*32-1:0];  	//store the value of a kernel, 32 kernels with 32 channels
	reg [lenOfInput-1:0] fMap[numOfPerFMap*32-1:0];			//Only one fMap with multiple channels
	
	// initial all data and testbench variables
	integer temp; //temporary variable
	integer i_knl,j_chnl,k_value; //variables for kernel initialization
	
	initial begin	
		//inital the value of kernel: one channel of one kernel has the same value, all kernels have the same channels
		i_knl=0; //i_knl is the id of kernel
		while(i_knl<numOfKernels) begin
			j_chnl=0; //j_chnl is the id of channel for each kernel
			while(j_chnl<numOfChannels) begin
				//k_value is the value for each channel, 4*4
				for(k_value=0;k_value<numOfPerKnl;k_value=k_value+1) begin
					temp=i_knl*numOfChannels*numOfPerKnl+j_chnl*numOfPerKnl+k_value;
					kernel[temp]=i_knl;
				end
				j_chnl=j_chnl+1;
			end
			i_knl=i_knl+1;
		end 
		
		//innitial the value of fMap
		j_chnl=0; //j_chnl is the id of channel for each data
		while(j_chnl<numOfChannels) begin
			//k_value is the value for each data, 64*64
			for(k_value=0;k_value<numOfPerFMap;k_value=k_value+1) begin
				temp=j_chnl*numOfPerFMap+k_value;
				fMap[temp]=k_value%64;
			end
			j_chnl=j_chnl+1;
		end
		
		//inital the control signal
		case(numOfChannels)
			8: in_cfg_ci=0;
			16: in_cfg_ci=1;
			24: in_cfg_ci=2;
			32: in_cfg_ci=3;
			default: in_cfg_ci=3;
		endcase
		case(numOfKernels)
			8: in_cfg_co=0;
			16: in_cfg_co=1;
			24: in_cfg_co=2;
			32: in_cfg_co=3;
			default: in_cfg_co=3;
		endcase

		//All inital works Done! 		
		in_start_conv=1;	// inital work is done and the top module can start work!
	end
	
	//inital the clk: 500ps turns, T=1000ns
	initial begin	
		forever #0.05 clk=~clk;
	end
	
	// begin to send data and count the cycle
	integer i,j;
	integer kernelCounter=0; 	// to count the id of this kernel
	integer channelCounter=0; 	// to count the id of this channel
	integer rowCounter=0;		// to count the id of the beginning row of data in this CONV, the row position of FMap
	// to count the id of this cycle, the number of cycles during CONV
	integer cycleCounter=0;	// [0,1] is read kernel; [2,3] is read the first 4*4 data; [4,33] is read flowing data in the same row
		
	always @(posedge clk) begin
		// Sending data.
		if(in_start_conv)begin	//wait until initial work is done!
			
			if(cycleCounter<2) begin	//read kernel
				temp=kernelCounter*numOfChannels*numOfPerKnl+channelCounter*numOfPerKnl;
				
				in_data0=kernel[temp+cycleCounter*8+0];
				in_data1=kernel[temp+cycleCounter*8+1];
				in_data2=kernel[temp+cycleCounter*8+2];
				in_data3=kernel[temp+cycleCounter*8+3];
				in_data4=kernel[temp+cycleCounter*8+4];
				in_data5=kernel[temp+cycleCounter*8+5];
				in_data6=kernel[temp+cycleCounter*8+6];
				in_data7=kernel[temp+cycleCounter*8+7];
			end
			else if(cycleCounter>=2) begin  	//read 4*2 data columns with column priority for each cycle!
				temp=channelCounter*numOfPerFMap;
				j=(cycleCounter-2)*2;
				
				in_data0=fMap[temp+rowCounter*64+j];
				in_data1=fMap[temp+(rowCounter+1)*64+j];
				in_data2=fMap[temp+(rowCounter+2)*64+j];
				in_data3=fMap[temp+(rowCounter+3)*64+j];
				
				in_data4=fMap[temp+rowCounter*64+j+1];
				in_data5=fMap[temp+(rowCounter+1)*64+j+1];
				in_data6=fMap[temp+(rowCounter+2)*64+j+1];
				in_data7=fMap[temp+(rowCounter+3)*64+j+1];
			end 
			
			cycleCounter=cycleCounter+1;
			if(cycleCounter==34) begin
				cycleCounter=2;	//next row data in the fMap
				rowCounter=rowCounter+1; //next row
			end
			if(rowCounter==61) begin	//One channel of fMap is over! Next channel of kernel and fMap...
				cycleCounter=0;	//this is new kernel, we should re-send the kernel data.
				rowCounter=0;
				channelCounter=channelCounter+1;
			end
			if(channelCounter==numOfChannels) begin	//One kernel is over! Next kernel and reset fMap...
				channelCounter=0;
				kernelCounter=kernelCounter+1;
			end
			/* if(kernelCounter==numOfKernels) begin 	// All works finish.
				$finish;
			end */
			if(out_end_conv==1) begin
				$finish;
			end 
		end
		
		
		// Receiving data.
		if(out_writeCtl) begin
			//Code for recieving data...
		end
	end

	topModule top( in_start_conv, clk,
		in_cfg_ci, in_cfg_co,
		in_data0, in_data1, in_data2, in_data3, in_data4, in_data5, in_data6, in_data7,  
		out_data0, out_data1,
		out_writeCtl,
		out_end_conv		);
endmodule