`timescale 1ns/1ps
module test_ADDA(
	input clk,
	//AD PINS
	output AD_ECODE_A,
	output AD_ECODE_B,
	output AD_S1,
	output AD_S2,
	output AD_DFS_GAIN,
	input [9:0]AD_A,//使用AD9288时低2位无效
	input [9:0]AD_B,//使用AD9288时低2位无效
	
	input rxf,//为低时，数据可读
	input txe,//为低时，数据可写入
	output reg wr,//从高到低时，写数据
	output reg rd,//为低时获取当前，从低到高，获取下一个
	inout [7:0]d,//数据位
	output reg SI//为1时立即发送信号
	
	);
	
	wire clk_40M;
	wire clk_100M;
	
	clk2	clk2_inst (
	.inclk0 ( clk ),
	.c0 ( clk_40M ),
	.c1 ( clk_100M )
	);
	
	///////////////////////////////////////////////AD///////////////////////////////////////
	reg [9:0]AD_A_buf/*synthesis noprune*/ ;
	reg [9:0]AD_B_buf/*synthesis noprune*/ ;
	reg [9:0]tem;
	reg [9:0]tem1;
	reg [9:0]Amax;/*a取最高点*/
	reg [9:0]Amin;/*a取最低点*/
	reg [9:0]Bmax;/*a取最高点*/
	reg [9:0]Bmin;/*a取最低点*/
	
	reg [4:0]state;
	reg [7:0]buffer[0:16];
	reg [7:0]dout;
	reg div_clk;
	reg div_clk2;
	reg [7:0]cnt;
	reg [31:0]atimemax;
	reg [31:0]btimemax;
	reg [7:0]av;
	reg [7:0]bv;
	reg [7:0]tv;
	reg [7:0]tvb;
	reg [23:0]cnt1;
	reg [31:0]atime;
	reg [31:0]btime;
	reg [31:0]count;
	reg [31:0]rx;
	reg [31:0]nrx;
	reg  [1:0]b;
	wire e;
	wire p;
   parameter MAX=24'd11999999;
	
	
	xjy1 inst(
	.clk(clk),
	.c(AD_B[9]),
	.e(e)

	);
	
		xjy inst1(
	.clk(clk),
	.c(AD_A[9]),
	.e(p)

	);
	
	initial
	begin
	
	atimemax<=32'd0;
	btimemax<=32'd0;
	rx<=32'd0;
	nrx<=32'd0;
	tv<=8'd0;
	tvb<=8'd0;
	count<=0;
	
		state <= 0;
		wr <= 0;
		rd <= 1;
		SI <= 1;
	end
	
	always @(posedge clk_40M)
	begin
		AD_A_buf <= AD_A;
		AD_B_buf <= AD_B;
		
		
		
	end
	
	always @(posedge clk)begin
    if(cnt1==MAX)begin
		cnt1<=0;	
		

	Amax<=10'd0;
	Amin<=10'd1023;
	Bmax<=10'd0;
	Bmin<=10'd1023;
		
	 end else begin 
		cnt1<=cnt1+1'b1;	
		
		if(Amax<AD_A)
		Amax<=AD_A;
		if(Amin>AD_A)
		Amin<=AD_A;
		
		if(Bmax<AD_B)
		Bmax<=AD_B;
		if(Bmin>AD_B)
		Bmin<=AD_B;
		
		
		
		end
   end
	
	


	
	always @(posedge clk)begin

	
	if(b==0)
	
		rx<=rx+32'd1;
	else if(b==2)
	rx<=rx+32'd1;
   else if (b==1)
	begin
		nrx<=rx;
		rx<=0;
	end
	


	end
	
	always @(posedge clk)begin
	
	
	
	
	if(Amax==AD_A)
	b<=0;
   else if(Amax==AD_B)

	b<=1;
	else 
	b<=2;
	
	
	end
	
	
	
	

	always @(posedge clk_100M)
	
	begin
	if(count==32'd100000000)begin
	count<=32'd0;
	btimemax<=btime;
	btime<=0;
	atimemax<=atime;
	atime<=0;
	end
	else begin
	count<=count+1;
	if(e==1)
	btime<=btime+1;
	if(p==1)
	atime<=atime+1;
	end
	

	
	end


always @(posedge clk_40M)
begin
   tem<=Amax-Amin;
	av<=tem[9:3];
	tv<=Amax[9:2]-av-8'd128;
	tem1<=Bmax-Bmin;
	bv<=tem1[9:3];
	tvb<=Bmax[9:2]-bv-8'd128;

end

	assign AD_ECODE_A = ~clk_40M;
	assign AD_ECODE_B = ~clk_40M;
	
	assign AD_S1 = 1;
	assign AD_S2 = 0;
	assign AD_DFS_GAIN = 0;
	
	
	
	
	always @(posedge clk)
	begin	
		div_clk <= ~div_clk;
	end
	always @(posedge div_clk)
	begin	
		div_clk2 <= ~div_clk2;
	end	
	always @(posedge div_clk2)
	begin
		case(state)
			5'd0:   begin
						if(rxf == 0)begin
							rd <= 0;
							if(d==8'd1)begin
							state <= 1;
							cnt<=0;end
							else
							state<=0;
						end
					end
			5'd1:	begin
						
						rd <= 1;
						state <= 2;
					end
			5'd2:	begin
						if(txe == 0)begin
							wr <= 1;
	
							dout <= buffer[cnt];
							cnt<=cnt+1;
							state <= 5'd3;
						end
					end
			5'd3:	begin
						wr <= 0;
						if(cnt==8'd16)
						state <= 5'd4;
						else
						state <=5'd2;
					end
			5'd4:	begin
						SI <= 0;
						state <= 5'd5;
					end	
			5'd5:	begin
						SI <= 1;
						state <= 5'd0;
					end						
			default:state <= 0;
		endcase
	end
	

always @(posedge clk)
begin	
	buffer[0]<=av;
	buffer[1]<=atimemax[31:24];
	buffer[2]<=atimemax[23:16];
	buffer[3]<=atimemax[15:8];
	buffer[4]<=atimemax[7:0];
	buffer[5]<=tv;
	buffer[6]<=bv;
	buffer[7]<=btimemax[31:24];
	buffer[8]<=btimemax[23:16];
	buffer[9]<=btimemax[15:8];
	buffer[10]<=btimemax[7:0];
	buffer[11]<=tvb;
	buffer[12]<=nrx[31:24];
	buffer[13]<=nrx[23:16];
	buffer[14]<=nrx[15:8];
	buffer[15]<=nrx[7:0];
end

	assign d = (state==5'd3)?dout:8'bzzzz_zzzz;
	
	////////////////////////////////////////////////DA/////////////////////////////////////
	
endmodule 