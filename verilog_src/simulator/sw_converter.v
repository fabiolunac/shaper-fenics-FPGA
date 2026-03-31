module sw_converter
#(
	parameter IN_SIZE = 4,
	parameter OUT_SIZE_OCC = 7,
	parameter OUT_SIZE_PED = 12
)
(
	input clk, rst,
	input [IN_SIZE-1:0] in,
	output reg [OUT_SIZE_OCC-1:0] occ_out = 0,
	output reg [OUT_SIZE_PED-1:0] ped_out = 0
);


always @(posedge clk or posedge rst)
begin
	if (rst) begin
		occ_out <= 1'd0;
		ped_out <= 1'd0;
	end else begin
		
		if (in[0] == 1) begin
			occ_out <= 7'd25;
			ped_out <= ped_out;
		end
		else begin
			if (in[1] == 1) begin
				occ_out <= 7'd121;
				ped_out <= ped_out;
			end
			else begin
			
				if (in[2] == 1) begin
					occ_out <= occ_out;
					ped_out <= 200;
				end
				else begin
					if (in[3] == 1) begin
						occ_out <= occ_out;
						ped_out <= 500;
					end
					else begin
						occ_out <= occ_out;
						ped_out <= ped_out;
					end
				end
			
			end
		end
	end
	
end

endmodule

