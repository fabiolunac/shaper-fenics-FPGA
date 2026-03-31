//Selects which LFSR output will be used
module select_rand
#(
	parameter num_rands = 5,    //Number of LFSRs
	parameter DATA_OUT_SIZE = 7 //Bits of the rabdom number output
)
(
	//Clock and reset signals
	input clk, rst,
	//Input (all LFSR outputs conctenated)
	input [num_rands*DATA_OUT_SIZE-1:0] in,
	//Random number output
	output reg [DATA_OUT_SIZE-1:0] out = 0
);

//State to define the LFSR used
reg [$clog2(num_rands)-1:0] selector = 0;

always@(posedge clk or posedge rst)
begin
	if (rst)
	begin
		selector = 0;
	end else begin
		//Pass to other LFSR
		selector = selector + 1'd1;
		
		//Check if reached the number of LFSRs
		if (selector == num_rands) begin
			selector = 0;
		end
		
		//Select which bit ranges (or LFSR) will be used in the output
		case(selector)
			0 : out <= in[1*DATA_OUT_SIZE-1:0*DATA_OUT_SIZE];
			1 : out <= in[2*DATA_OUT_SIZE-1:1*DATA_OUT_SIZE];
			2 : out <= in[3*DATA_OUT_SIZE-1:2*DATA_OUT_SIZE];
			3 : out <= in[4*DATA_OUT_SIZE-1:3*DATA_OUT_SIZE];
			4 : out <= in[5*DATA_OUT_SIZE-1:4*DATA_OUT_SIZE];
			5 : out <= in[6*DATA_OUT_SIZE-1:5*DATA_OUT_SIZE];
			6 : out <= in[7*DATA_OUT_SIZE-1:6*DATA_OUT_SIZE];
		endcase
		
	end
end


endmodule