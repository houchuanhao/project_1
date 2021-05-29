`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 20:23:34
// Design Name: 
// Module Name: my
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

// This is a test model for myself to test some verilog code
module my( clk, in_a, in_b, in_c, out_a, out_b, out_c
    );
    input clk, in_a, in_b, in_c;
    output out_a, out_b, out_c;
    
	
	reg [7:0]data1,data2,data3,data4;
	/*
    always @(posedge clk)
        begin    
            
            tag1=tag1+1;
        end*/
    
    //output
    assign out_a =1;
    assign out_b =1;
    assign out_c =1;
    
    
endmodule
