//Hits position core
module hits_positions
#(
	parameter IN_SIZE = 7 //Bits of input
)
(
	//Clock and reset signals
	input clk, rst,
	//Random number input
	input [IN_SIZE-1:0] in,
	// Desired occupancy
	input [IN_SIZE-1:0] occupancy,
	// hit bit (1 - YES | 0 - NO)
	output reg hit = 0
);

always @(posedge clk or posedge rst)
begin
	if (rst) begin
		hit <= 1'd0;
	end else begin
		//If it is true, there was a collision
		if (in < occupancy) begin
			hit <= 1'd1;
		end
		else begin
			hit <= 1'd0;
		end
	end
	
end

endmodule


