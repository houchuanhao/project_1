// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "04/06/2021 02:36:44"
                                                                                
// Verilog Test Bench template for design : p1
// 
// Simulation tool : ModelSim-Altera (Verilog)
// 

`timescale 1 ps/ 1 ps
module tb_code1();
// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg [7:0] Idata0;
reg [7:0] Idata1;
reg [7:0] Idata2;
reg [7:0] Idata3;
reg [7:0] Idata4;
reg [7:0] Idata5;
reg [7:0] Idata6;
reg [7:0] Idata7;
reg [1:0] cfg_ci;
reg [1:0] cfg_co;
reg clk;
reg start_conv;
// wires                                               
//wire [49:0]  Odata;
wire [24:0] Odata0;
wire [24:0] Odata1;
wire end_conv;
wire [7:0]  ostate;
wire read_I;
wire read_w;
wire write_o;

// assign statements (if any)                          
code1 i1 (
// port map - connection between master ports and signals/registers   
	.Idata0(Idata0),
	.Idata1(Idata1),
	.Idata2(Idata2),
	.Idata3(Idata3),
	.Idata4(Idata4),
	.Idata5(Idata5),
	.Idata6(Idata6),
	.Idata7(Idata7),
//	.Odata(Odata),
	Odata0,
	Odata1,
	.cfg_ci(cfg_ci),
	.cfg_co(cfg_co),
	.clk(clk),
	.end_conv(end_conv),
	.ostate(ostate),
	.read_I(read_I),
	.read_w(read_w),
	.start_conv(start_conv),
	.write_o(write_o)
);
reg[7:0] map[0:512];
reg[20:0] position;
integer i;
initial                                                
begin                                                  
// code that executes only once                        
// insert code here --> begin
	start_conv=0;
	clk=1'b0;
	position=0;
	for(i=0;i<512;i=i+1)begin
		map[i]=i %16+1;
	end
	#45 start_conv=1; 
                                                       
// --> end                                             
$display("Running testbench");                       
end                                                    
always 
begin         
	#10;
	clk=~clk;
	if(clk==1)begin
			if(start_conv==1&&position<100)begin
					Idata0<=map[position+0];
					Idata1<=map[position+1];
					Idata2<=map[position+2];
					Idata3<=map[position+3];
					Idata4<=map[position+4];
					Idata5<=map[position+5];
					Idata6<=map[position+6];
					Idata7<=map[position+7];
					position<=position+8;
			end
		end
// optional sensitivity list                           
// @(event1 or event2 or .... eventn)                  
                                                 
// code executes for every event on sensitivity list   
// insert code here --> begin                          
                                                       
//@eachvec;                                              
// --> end                                             
end                                                    
endmodule




