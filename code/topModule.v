`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 21:49:58
// Design Name: 
// Module Name: topModule
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

// This is the top level module of the CONV project.
// The bandwidth of input data and kernel is 8 bit.
// The bandwidth of output result is 25bit.

module topModule(     
    in_start_conv, clk, 
	in_cfg_ci, in_cfg_co, 	////the number of channels, and the number of kernels,
	in_data0, in_data1, in_data2, in_data3, in_data4, in_data5, in_data6, in_data7,  
	out_data0, out_data1,
	out_end_conv
);
    parameter lenOfInput=8;    //the number of input-data bits 
    parameter lenOfOutput=25;  //the number of output-data bits
    parameter numOfPerKnl=16;  //the number of kernel value
	parameter numOfPerOutFmp=61*61; 	//the number of values in out-fMap
     
     // input data
	input clk, in_start_conv;    //the start signal of CONV
    input [lenOfInput-1:0] in_data0,  in_data1,  in_data2,  in_data3,  in_data4,  in_data5,  in_data6,  in_data7;
	input [2:0] in_cfg_ci;  //the number of channels,  		0 means 8, 1 means 16, 3 means 24, 3 means 32
	input [2:0] in_cfg_co;      //the number of kernels,         0 means 8, 1 means 16, 3 means 24, 3 means 32
	//output data
    output [lenOfOutput-1:0] out_data0, out_data1;
    output out_end_conv;    //the finish signal of CONV, 1 means finish

    //kernel 4*4, store the value of a kernel, 4*4
    reg [lenOfInput-1:0] kernel00, kernel01, kernel02, kernel03, 
			kernel10, kernel11, kernel12, kernel13, 
			kernel20, kernel21, kernel22, kernel23, 
			kernel30, kernel31, kernel32, kernel33;
	
	//data 4*4, store the value of a data, 4*4
	reg [lenOfInput-1:0] data00, data01, data02, data03, 
			data10, data11, data12, data13, 
			data20, data21, data22, data23, 
			data30, data31, data32, data33;
		
	// the data should be moved.
	reg [lenOfInput-1:0] tmpData0,tmpData1,tmpData2,tmpData3;
	//wire for recieving the data from CONVs
	wire [lenOfOutput-1:0] convOut0,convOut1; //the output of conv0 and conv1.
	
	// set three CONV modules. One for the first CONV, and two for consecutive CONVs
	convMod conv0( tmpData0, data01, data02, data03, tmpData1, data11, data12, data13, tmpData2, data21, data22, data23, tmpData3, data31, data32, data33,	kernel00, kernel01, kernel02, kernel03, kernel10, kernel11, kernel12, kernel13, kernel20, kernel21, kernel22, kernel23, kernel30, kernel31, kernel32, kernel33, 	convOut0 );
	convMod conv1( data00, data01, data02, data03, data10, data11, data12, data13, data20, data21, data22, data23, data30, data31, data32, data33,	kernel00, kernel01, kernel02, kernel03, kernel10, kernel11, kernel12, kernel13, kernel20, kernel21, kernel22, kernel23, kernel30, kernel31, kernel32, kernel33, 	convOut1 );

	//set one reg to connect out_end_conv
	reg reg_out_end_conv=0;	
	assign out_end_conv=reg_out_end_conv;

	// read the control information from the crontrol signal
	integer numOfKernels;
	integer numOfChannels;
	always @(*) begin 
		if(in_start_conv) begin
			case(in_cfg_ci) // set numOfChannels
				'b00: numOfChannels=8;
				'b01: numOfChannels=16;
				'b10: numOfChannels=24;
				'b11: numOfChannels=32;
			endcase
			case(in_cfg_co) // set numOfKernels
				'b00: numOfKernels=8;
				'b01: numOfKernels=16;
				'b10: numOfKernels=24;
				'b11: numOfKernels=32;
			endcase
		end
	end 
	
	// the memory for results.
	reg [lenOfOutput-1:0] convResults [numOfPerOutFmp*32-1:0];
	// initial the convResults
	integer i_conv;
	initial begin //just inital the first kernel of convResults for speeding up
		for(i_conv=0;i_conv<numOfChannels*numOfPerOutFmp;i_conv=i_conv+1) begin
			convResults[i_conv]=0;
		end
	end
	
	integer kernelCounter=0; 	// to count the id of this kernel
	integer channelCounter=0; 	// to count the id of this channel
	integer rowCounter=0;		// to count the id of the beginning row of data in this CONV, the row position of FMap
	integer cycleCounter=0; //the number of cycles during CONV
    // begin to recieve data and count the cycle
	integer temp; //temporary variable
    always @(posedge clk)
    begin
		if(in_start_conv) begin	//wait until initial work is done!
			if(cycleCounter==0) begin			//read kernel: 1st-2nd row
				kernel00=in_data0;
				kernel01=in_data1;
				kernel02=in_data2;
				kernel03=in_data3;
				
				kernel10=in_data4;
				kernel11=in_data5;
				kernel12=in_data6;
				kernel13=in_data7;
			end
			else if(cycleCounter==1) begin		//read kernel: 3rd-4th row
				kernel20=in_data0;
				kernel21=in_data1;
				kernel22=in_data2;
				kernel23=in_data3;
				
				kernel30=in_data4;
				kernel31=in_data5;
				kernel32=in_data6;
				kernel33=in_data7;
			end
			else if(cycleCounter==2) begin  	//read data: 0st-1nd column
				data00=in_data0;
				data10=in_data1;
				data20=in_data2;
				data30=in_data3;
				
				data01=in_data4;
				data11=in_data5;
				data21=in_data6;
				data31=in_data7;
			end
			else if(cycleCounter==3) begin		//read data: 2rd-3th column
				data02=in_data0;
				data12=in_data1;
				data22=in_data2;
				data32=in_data3;
				
				data03=in_data4;
				data13=in_data5;
				data23=in_data6;
				data33=in_data7;
								
				// call once CONV
				temp=kernelCounter*numOfChannels*numOfPerOutFmp+channelCounter*numOfPerOutFmp;
				convResults[temp] = convResults[temp]+convOut1;
			end 
			else begin 	//read 4*2 data columns and calculte 2 CONV for each cycle!				
				// Left move 2 column
				tmpData0=data01;
				tmpData1=data11;
				tmpData2=data21;
				tmpData3=data31;
				
				data00=data02;
				data10=data12;
				data20=data22;
				data30=data32;
				
				data01=data03;
				data11=data13;
				data21=data23;
				data31=data33;
				
				data02=in_data0;
				data12=in_data1;
				data22=in_data2;
				data32=in_data3;
								
				data03=in_data4;
				data13=in_data5;
				data23=in_data6;
				data33=in_data7;
				
				// call two CONVs
				temp=kernelCounter*numOfChannels*numOfPerOutFmp+channelCounter*numOfPerOutFmp+rowCounter*61+(cycleCounter-4)*2+1;
				convResults[temp] = convResults[temp]+convOut0;
				convResults[temp+1] = convResults[temp+1]+convOut1;
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
			if(channelCounter==numOfChannels) begin	//One fMap is over! Next kernel and fMap...
				channelCounter=0;
				kernelCounter=kernelCounter+1;
				
				// inital next area (kernel) of convResults
				if(kernelCounter!=numOfKernels) begin	//In case of being out of bound in convResults
					for(i_conv=i_conv;i_conv<kernelCounter*numOfChannels*numOfPerOutFmp;i_conv=i_conv+1) begin
						convResults[i_conv]=0;
					end
				end
			end
			if(kernelCounter==numOfKernels) begin 	// All works finish.
				reg_out_end_conv=1;	// the signal to finish!
			end
		end
    end
	
endmodule
