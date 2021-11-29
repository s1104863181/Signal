module xjy(
input c,
input clk,
output reg e

);

reg[0:0] d1;
wire clk_40M;
wire clk_100M;

	clk2	clk2_inst (
	.inclk0 ( clk ),
	.c0 ( clk_40M ),
	.c1 ( clk_100M )
	);

initial begin
	e  <= 1'b0;
	d1  <= 1'b0;
end

always @(posedge clk_100M)begin
	d1 <= c;
	e <= d1 & (~c);
	end
endmodule 