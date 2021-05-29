module code1(
input [1:0] cfg_ci,	
input [1:0] cfg_co,
input start_conv,
output end_conv,
input [7:0] Idata0 , //8*8
input [7:0] Idata1,
input [7:0] Idata2,
input [7:0] Idata3,
input [7:0] Idata4,
input [7:0] Idata5,
input [7:0] Idata6,
input [7:0] Idata7,
input clk,
output read_w,
output read_I,
output write_o,
output[7:0] ostate,
//output [49:0] Odata
output [24:0] Odata0,
output [24:0] Odata1
);
reg [7:0] kernel[0:511];  // 4 x 4 x cfg_ci x 1
reg [7:0] win[0:511]; //鍗风Н绐楀�?
reg [24:0] Odata_temp[0:1];	
reg [7:0] stateReg;
reg [8:0] readReg;
reg[7:0] wx;
reg[7:0] wy;
reg write_o_temp;
reg outReg;
reg end_conv_temp;
integer      j;
integer      k ;
integer	 i;
integer sum;
always@ (posedge clk or negedge start_conv)begin
    if(!start_conv)begin  // start_conv==0
        end_conv_temp=0;
        stateReg=8'b00000000;
        Odata_temp[0]=0;
        Odata_temp[1]=1;
    end
    else begin // start_conv==1
        if(stateReg==8'b00000000)begin
            stateReg<=8'b00000001; //
            readReg<= 9'b000000000;
        end
    else if(stateReg==8'b00000001) begin // read kernel
                kernel[readReg+0] =Idata0; //8*8
                kernel[readReg+1]= Idata1;
                kernel[readReg+2]= Idata2;
                kernel[readReg+3]= Idata3;
                kernel[readReg+4]= Idata4;
                kernel[readReg+5]= Idata5;
                kernel[readReg+6]= Idata6;
                kernel[readReg+7]= Idata7;
                readReg<=readReg+8;
                if(readReg==16)begin
                    stateReg<=8'b00000010;  //						
                    readReg<= 9'b000000000;
                    wx<=0;
                    wy<=0;
                end
        end
    else	if(stateReg==8'b00000010 ) begin // read image window			
                        if(wx==0)begin
                                win[readReg+0]=Idata0; //8*8
                                win[readReg+1]= Idata1;
                                win[readReg+2]= Idata2;
                                win[readReg+3]= Idata3;
                                win[readReg+4]= Idata4;
                                win[readReg+5]= Idata5;
                                win[readReg+6]= Idata6;
                                win[readReg+7]= Idata7;
                                readReg<=readReg+8;
                                if(readReg==16)begin
                                        wx<=1;
                                end
                         end
                         else begin  //wx>=1 	 caculatethe last window, and read the new window
                                wx<=wx+1;
                                sum =	win[(0+(wx-1)*4)%16]*kernel[0]+win[(1+(wx-1)*4)%16]*kernel[1]+win[(2+(wx-1)*4)%16]*kernel[2]+win[(3+(wx-1)*4)%16]*kernel[3]+
                                win[(4+(wx-1)*4)%16]*kernel[4]+win[(5+(wx-1)*4)%16]*kernel[5]+win[(6+(wx-1)*4)%16]*kernel[6]+win[(7+(wx-1)*4)%16]*kernel[7]+
                                win[(8+(wx-1)*4)%16]*kernel[8]+win[(9+(wx-1)*4)%16]*kernel[9]+win[(10+(wx-1)*4)%16]*kernel[10]+win[(11+(wx-1)*4)%16]*kernel[11]+
                                win[(12+(wx-1)*4)%16]*kernel[12]+win[(13+(wx-1)*4)%16]*kernel[13]+win[(14+(wx-1)*4)%16]*kernel[14]+win[(15+(wx-1)*4)%16]*kernel[15];
                                if(wx%2==0)begin
                                        Odata_temp[1]<=sum;
                                        write_o_temp<=1;
                                end 
                                else begin 
                                        Odata_temp[0]<=sum;
                                        write_o_temp<=0;
                                end
                         end
        end
        
    end
end
assign read_w=0;
assign read_I=1;
assign write_o=write_o_temp;
assign ostate=stateReg;
//assign Odata={Odata_temp[0],Odata_temp[1]};
assign Odata0=Odata_temp[0];
assign Odata1=Odata_temp[1];
endmodule