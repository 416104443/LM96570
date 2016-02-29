//*************************LM97570 register map*************************************************************************//
/* register:    data:   coarse Delay        fine Delay    chanel:     current state:                   width:address+data
        00h     00 000  0_0000_0000_0000_0  000b          ch1         no user-programmed delay         6+22
		  01h     00 000  0_0000_0000_0001_0  001b          ch2         2  coarse delays + 1 fine delay  6+22
		  02h     00 000  0_0000_0000_0010_0  010b          ch3         4  coarse delays + 2 fine delay  6+22 
		  03h     00 000  0_0000_0000_0011_0  011b          ch4         6  coarse delays + 3 fine delay  6+22
		  04h     00 000  0_0000_0000_0100_0  100b          ch5         8  coarse delays + 4 fine delay  6+22
		  05h     00 000  0_0000_0000_0101_0  101b          ch6         10 coarse delays + 5 fine delay  6+22
		  06h     00 000  0_0000-0000_0110_0  110b          ch7         12 coarse delays + 6 fine delay  6+22
		  07h     00 000  0_0000_0000_0111_0  111b          ch8         14 coarse delays + 7 fine delay  6+22
   register:    data:                                     chanel:     current state:                   width:address+data
        08h     5555_5555_5555_5555h                      ch1 P       default                          6+64
		  09h     5555_5555_5555_5555h                      ch2 P       default                          6+64
		  0Ah     5555_5555_5555_5555h                      ch3 P       default                          6+64
		  0Bh     5555_5555_5555_5555h                      ch4 P       default                          6+64
		  0Ch     5555_5555_5555_5555h                      ch5 P       default                          6+64
		  0Dh     5555_5555_5555_5555h                      ch6 P       default                          6+64
		  0Eh     5555_5555_5555_5555h                      ch7 P       default                          6+64
		  0Fh     5555_5555_5555_5555h                      ch8 P       default                          6+64
	register:    data:                                     chanel:     current state:                   width:address+data	  
		  10h     AAAA_AAAA_AAAA_AAAAh                      ch1 N       default                          6+64
		  11h     AAAA_AAAA_AAAA_AAAAh                      ch2 N       default                          6+64
		  12h     AAAA_AAAA_AAAA_AAAAh                      ch3 N       default                          6+64
		  13h     AAAA_AAAA_AAAA_AAAAh                      ch4 N       default                          6+64
		  14h     AAAA_AAAA_AAAA_AAAAh                      ch5 N       default                          6+64
		  15h     AAAA_AAAA_AAAA_AAAAh                      ch6 N       default                          6+64
		  16h     AAAA_AAAA_AAAA_AAAAh                      ch7 N       default                          6+64
		  17h     AAAA_AAAA_AAAA_AAAAh                      ch8 N       default                          6+64
	register:    data:                                     chanel:     current state:                   width:address+data		  
		  18h     5555_5555_5555_5555h                      All P       default                          6+64
        19h     AAAA_AAAA_AAAA_AAAAh                      ALL N       default                          6+64	
	register:    data:                                                 current state:                   width:address+data		  
		  1Ah     0001_0001111_111b                                     default                          6+14
		  1Bh     0000_0000b                                            default                          6+8                  */
///**************************************************************************************************************************/
module LM96570(addr,DATAIN,clk,WR,RD,RESET,sRD,DATAback,ACK,sWR,sCLK,sLE,TX_EN1,led);
input [4:0]addr;           //外部输入5位地址信息
input [63:0]DATAIN;        //外部最大64位数据输入
input clk,WR,RD,RESET,sRD;
output reg [63:0]DATAback;  //从芯片接收回来的最大64位数据
output reg ACK,sLE,TX_EN1;
output wire sWR,sCLK;
output reg[2:0]led;  //输出3个LED用于显示状态
//integer i;
//****************************状态寄存器*************************************//
//reg start;                 //时钟稳定状态标志位 
reg INF;                   //启动上升沿读数据
reg [5:0]state;
//****************************开关控制***************************************//
reg link_sWR;
reg link_sCLK;
reg addr_data;             //发送移位寄存其选择，1选地址移位寄存器，0选数据移位寄存器
//****************************发送移位寄存器**********************************//
reg [5:0]addr_buf;         //发送地址移位寄存器
reg [63:0]data_buf;        //发送数据移位寄存器
reg [63:0]datain_buf;
//****************************计数器组***************************************//
reg [1:0]cnt_cfg;        //配置计数器
reg [2:0]cnt_addr;         //数据位宽计数器
reg [5:0]cnt_data;
//****************************初始化寄存器组**********************************//
reg [4:0]addr_cfg[3:1];
reg [63:0]data_cfg[3:1];
//******************************状态机状态定义********************************//
parameter IDLE      =6'b000001,
          ADDR_OUT  =6'b000010,
          DATA_OUT  =6'b000100,
			 DATA_IN   =6'b001000,
			 OUT_ACK   =6'b010000,
			 IN_ACK    =6'b100000;
//*******************************开关定义************************************//
parameter YES  =1'b1,
          NO   =1'b0;
//**************************************************************************//
wire data_mid;
assign sWR =link_sWR?data_mid:1'b0;
assign data_mid=addr_data?addr_buf[0]:data_buf[0];
assign sCLK=link_sCLK?clk:1'b0;
//***********************延时避免初始时钟不稳定状态****************************//
/*always@(posedge clk or posedge RST)
  if(RST)
     begin 
	   i<=10000;
		start<=NO;
	  end
	else if(i)
	  begin
	   i<=i-1'b1;
		start<=NO;
	  end
	else
	  start<=YES;      //延时结束输出时钟稳定标志位*/
///*************************状态机程序***************************************//
always@(negedge clk or negedge RESET)
  if(!RESET)
     begin
      addr_cfg[3]<=5'b11010;            //地址1A
		addr_cfg[2]<=5'b11001;            //地址19
		addr_cfg[1]<=5'b11000;            //地址18
		data_cfg[3]<=64'b0000_0000_0000_0000__0000_0000_0000_0000__0000_0000_0000_000000__00_0110_0000_0111;
		//data_cfg[2]<=64'b1111_0000_1111_1110__0000_0011_1111_0000__0011_1110_0000_1111__0000_1110_0011_0010;
		//data_cfg[1]<=64'b0000_1111_0000_0001__1111_1100_0000_1111__1100_0001_1111_0000__1111_0001_1100_1101;
		data_cfg[2]<=64'b0101_0101_0101_0101__0101_0101_0101_0101__0101_0101_0101_0101__0101_0101_0101_0101;
		data_cfg[1]<=64'b1010_1010_1010_1010__1010_1010_1010_1010__1010_1010_1010_1010__1010_1010_1010_1010;
		TX_EN1    <= NO;
	   sLE       <= 1'b1;
		link_sCLK <= NO;
		link_sWR  <= NO;
      addr_data <= 1'b1;
      INF       <= NO;		   //关闭数据读回通道
		ACK       <= NO;
		cnt_cfg   <= 2'b11;
		state     <= IDLE;
		led       <= 3'b000;
	  end
  else //if(start)
	 begin
	   casex(state)
		  IDLE:begin		         
		         sLE       <=1'b1;
					link_sCLK <=NO;
		         link_sWR  <=NO;		         
					addr_data <=1'b1;
					ACK       <=NO;
					led       <= 3'b001; 
					if(cnt_cfg)
					  begin
					    addr_buf <={1'b0,addr_cfg[cnt_cfg]};
						 data_buf <=data_cfg[cnt_cfg];
						 TX_EN1    <=NO;
					    state    <=ADDR_OUT;
					  end 
					else if(WR)
					  begin
					    addr_buf <={1'b0,addr};
						 data_buf <=DATAIN;
						 TX_EN1    <=NO;
					    state<=ADDR_OUT;
					  end
					else if(RD)
					  begin
					    addr_buf <={1'b1,addr};
						 data_buf <=DATAIN;
						 TX_EN1    <=NO;
					    state<=ADDR_OUT;
					  end
					else 
					  begin 
					    TX_EN1   <=YES;
					    state    <=IDLE;
					  end
				 end
    ADDR_OUT:begin
					led       <= 3'b111; 
		         sLE       <=1'b0;
					link_sCLK <=YES;
		         link_sWR  <=YES;
					cnt_addr  <=3'b101;  //5
               casex(addr_buf[4:0])
		           5'b00???:cnt_data<=6'b01_0101;  //21
					  5'b01???:cnt_data<=6'b11_1111;  //63
					  5'b10???:cnt_data<=6'b11_1111;  //63
					  5'b1100?:cnt_data<=6'b11_1111;  //63
					  5'b11010:cnt_data<=6'b00_1101;  //13
					endcase
					cnt_cfg<=cnt_cfg-1'b1;
					if(addr_buf[5])
					  state<=DATA_IN;
					else
					  state<=DATA_OUT;
				 end 
	 DATA_OUT:if(cnt_addr)
					  shift_addr;
				 else
					begin
					  addr_data <=1'b0;
					  state     <=OUT_ACK;
			  	   end
	  DATA_IN:if(cnt_addr)
	              shift_addr;
				 else
				   begin
					  INF       <=YES;
					  state     <=IN_ACK;
					end
	  OUT_ACK:if(cnt_data)
					  shiftout_data;
				 else
				   begin
					  if(!cnt_cfg)
					    ACK<=YES;	
					  sLE       <=1'b1;
					  link_sCLK <=NO;
		           link_sWR  <=NO;					 
					  state     <=IDLE;
				   end
		IN_ACK:if(cnt_data)
					 cnt_data<=cnt_data-1'b1;
				 else
				   begin
					  INF       <= NO;
					  ACK       <= YES;
				     sLE       <= 1'b1;
					  link_sCLK <= NO;
		           link_sWR  <= NO;	
					  DATAback  <= datain_buf;
					  state     <= IDLE;
					end 
	  default:state         <=	IDLE;				
	   endcase
  end
///*************************读数据程序***************************************//
always @(posedge clk)
  begin
    if(INF)
      datain_buf<={datain_buf[62:0],sRD};
	 else
	   datain_buf<=64'b0;
  end 
///*************************发送地址任务***************************************//
task shift_addr;
  begin
    addr_buf<=addr_buf>>1'b1;
	 cnt_addr<=cnt_addr-1'b1;
  end
endtask
///*************************发送数据任务***************************************// 
task shiftout_data;
  begin
    data_buf<=data_buf>>1'b1;
	 cnt_data<=cnt_data-1'b1;
  end
endtask
endmodule
