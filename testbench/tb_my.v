`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/27 19:50:56
// Design Name: 
// Module Name: tb_my
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


module tb_my();

    reg clk, in_a, in_b, in_c;
    wire out_a, out_b, out_c;
    
    my my1( clk, in_a, in_b, in_c, out_a, out_b, out_c);
    initial begin
        clk=0;
        forever 
            begin 
              #0.001 clk=~clk;
            end
        


       #0.1 $finish;
    end 
    
    initial begin
        in_a=1;
        in_b=1;
        in_c=1;
    end




endmodule
