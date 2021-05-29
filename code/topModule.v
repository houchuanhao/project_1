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

module topModule( //in_start_conv, in_cfg_ci, out_cfg_co, out_end_conv    
    in_start_conv, clk, 
	in_data0, in_data1, in_data2, in_data3, in_data4, in_data5, in_data6, in_data7,  
	out_data0, out_data1
);
    parameter lenOfInput=8;    //the number of input-data bits 
    parameter lenOfOutput=25;  //the number of output-data bits
    parameter numOfPerKnl=16;  //the number of kernel value
    //parameter numOfFMapValue=16;  //the number of kernel value
     
     // input data
	input clk, in_start_conv;    //the start signal of CONV
    input [lenOfInput-1:0] in_data0,  in_data1,  in_data2,  in_data3,  in_data4,  in_data5,  in_data6,  in_data7;
	
    output [lenOfOutput-1:0] out_data0, out_data1;
    
    // now we assume that the number of kernels and channels are 1. 
/*
    
    input [2:0] in_cfg_ci;  //the number of input fMap,  		0 means 8, 1 means 16, 3 means 24, 3 means 32
    output out_cfg_co;      //the number of ouput fMap,         0 means 8, 1 means 16, 3 means 24, 3 means 32
    output out_end_conv;    //the finish signal of CONV
*/
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

	//the output of conv, we can turn it into out_data0 or out_data1 later.
	wire [lenOfOutput-1:0] convOut;
	reg [lenOfOutput-1:0] reg_out_data0, reg_out_data1; // two register for MUX outputing results.

	// the relationship between CONV
	assign out_data0=reg_out_data0;
	assign out_data1=reg_out_data1;
	
	convMod conv1( data00, data01, data02, data03, data10, data11, data12, data13, data20, data21, data22, data23, data30, data31, data32, data33,	kernel00, kernel01, kernel02, kernel03, kernel10, kernel11, kernel12, kernel13, kernel20, kernel21, kernel22, kernel23, kernel30, kernel31, kernel32, kernel33, 	convOut );



    integer cycleCounter=0; //the number of cycles during CONV
	
    // begin to recieve data and count the cycle
	integer i,j,k;
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
			else if(cycleCounter==2) begin  	//read data: 1st-2nd column
				data00=in_data0;
				data10=in_data1;
				data20=in_data2;
				data30=in_data3;
				
				data01=in_data4;
				data11=in_data5;
				data21=in_data6;
				data31=in_data7;
			end
			else if(cycleCounter==3) begin		//read data: 3rd-4th column
				data02=in_data0;
				data12=in_data1;
				data22=in_data2;
				data32=in_data3;
				
				data03=in_data4;
				data13=in_data5;
				data23=in_data6;
				data33=in_data7;
								
				// call once CONV
				reg_out_data0 = convOut;
				//conv1( data00, data01, data02, data03, data10, data11, data12, data13, data20, data21, data22, data23, data30, data31, data32, data33,	kernel00, kernel01, kernel02, kernel03, kernel10, kernel11, kernel12, kernel13, kernel20, kernel21, kernel22, kernel23, kernel30, kernel31, kernel32, kernel33, 	out_data0 );
						
			end 
			else begin 	//read 4*2 data columns and calculte 2 CONV for each cycle!				
				// Left move 1 column
				data00=data01;
				data10=data11;
				data20=data21;
				data30=data31;
				
				data01=data02;
				data11=data12;
				data21=data22;
				data31=data32;
				
				data02=data03;
				data12=data13;
				data22=data23;
				data32=data33;
								
				// read one new colunm from in_data[0:3]
				data03=in_data0;
				data13=in_data1;
				data23=in_data2;
				data33=in_data3;
				
				// call once CONV
				reg_out_data0 = convOut;
				//conv1( data00, data01, data02, data03, data10, data11, data12, data13, data20, data21, data22, data23, data30, data31, data32, data33,	kernel00, kernel01, kernel02, kernel03, kernel10, kernel11, kernel12, kernel13, kernel20, kernel21, kernel22, kernel23, kernel30, kernel31, kernel32, kernel33, 	out_data0 );
				
				// Left move 1 column
				data00=data01;
				data10=data11;
				data20=data21;
				data30=data31;
				
				data01=data02;
				data11=data12;
				data21=data22;
				data31=data32;
				
				data02=data03;
				data12=data13;
				data22=data23;
				data32=data33;
								
				// read one new colunm from in_data[4:7]
				data03=in_data4;
				data13=in_data5;
				data23=in_data6;
				data33=in_data7;
				
				// call once CONV
				reg_out_data1 = convOut;
				//conv1( data00, data01, data02, data03, data10, data11, data12, data13, data20, data21, data22, data23, data30, data31, data32, data33,	kernel00, kernel01, kernel02, kernel03, kernel10, kernel11, kernel12, kernel13, kernel20, kernel21, kernel22, kernel23, kernel30, kernel31, kernel32, kernel33, 	out_data1 );
				
			end
			
			cycleCounter=cycleCounter+1;
			if(cycleCounter==34) begin
				cycleCounter=0;	//next row data in the fMap
			end
		end
    end
	
endmodule
