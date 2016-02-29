`timescale 1ns/1ns
module test;
wire ACK,sWR,sCLK,sLE;
reg [4:0]addr;
reg [63:0]DATAIN;
reg clk;
reg WR,RST;
LM97570  U1(.addr(addr),.DATAIN(DATAIN),.clk(clk),.WR(WR),.RD(),.RST(RST),.sRD(),.DATAback(),.ACK(ACK),.sWR(sWR),.sCLK(sCLK),.sLE(sLE));
initial
begin
addr=0;
DATAIN=0;
clk=0;
WR=0;
RST=1;
#480;
RST=0;
#330;
repeat(20)@(posedge ACK)
  begin
    addr=$random;
	 DATAIN=$random;
	 #120;
	 WR=1;
	 #400;
	 WR=0;
  end 
end
always #50 clk=~clk;
endmodule 
