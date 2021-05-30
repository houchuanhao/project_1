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
output read_I,
input[63:0] Idata,
output read_W,
input wdata,
output write_o,
output Odata,
input start_conv,
output end_cov,
input cfg_ci[1:0], //
input cfg_co[1:0]
    );
reg [16383:0] feature_row[0:63];
reg [511:0] kernel_row[0:3];
    
    
endmodule
