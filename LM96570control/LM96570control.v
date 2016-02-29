module LM96570control(inclk0,RESET,sRD/*,TX_EN2*/,EN,RST,clkout,sWR,sCLK,sLE,TX_EN,led);
input wire inclk0;
input wire RESET;
input wire sRD;
/**/input wire EN;
//output wire TX_EN2;
output wire clkout;
output wire sWR;
output wire sCLK;
output wire sLE;
output wire TX_EN;   //激发信号使能
output wire RST;
output wire [2:0]led;
wire c1,c2,TX_EN1;
assign RST=!RESET;
assign TX_EN=(TX_EN1&&count&&EN);  

reg [3:0]count;
always @(posedge c2 or negedge RESET)
  if(!RESET)
   count<=4'b0;
  else
   count<=count+1'b1;    
PLL_clk U2(.areset(RST),.inclk0(inclk0),.c0(clkout),.c1(c1),.c2(c2));    //c0 40M c1 1M
LM96570 U1(.addr(),.DATAIN(),.clk(c1),.WR(),.RD(),.RESET(RESET),.sRD(sRD),.DATAback(),.ACK(),.sWR(sWR),.sCLK(sCLK),.sLE(sLE),.TX_EN1(TX_EN1),.led(led)); 
endmodule 
