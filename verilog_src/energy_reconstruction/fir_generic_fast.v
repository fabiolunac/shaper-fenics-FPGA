//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2025 15:26:11
// Design Name: 
// Module Name: fir_generic_fast
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


module fir_generic_fast
#(
	parameter NBDATA = 10,
	parameter NBITS_OUT = 25,
	parameter NB_WEIGHT = 10,
	parameter ORDER = 11,
	parameter BIAS = 0,
	parameter WEIGHTS_FILE = "weight_ls_pzc_a13.mif"
)
(
	input clk,
	input clk_fast,
	input clr,
	input signed [NBDATA-1:0] data_in,
	output reg signed [NBITS_OUT-1:0] data_out = 0
);



reg signed [NB_WEIGHT-1:0] weights [ORDER+BIAS-1:0];
reg signed [NBDATA-1:0] out_mux1;
reg signed [NBDATA-1:0] out_mux2;



reg rst_restart = 0;


reg signed [NBITS_OUT-1:0] acc = 0;
reg [2:0] state = 0;

reg [2:0] state2 = 0;

initial $readmemb(WEIGHTS_FILE, weights);

reg signed [NBDATA-1:0] delay [ORDER+BIAS-2:0];

integer i;
integer ii;
integer iii;

initial begin
  for (iii = 0; iii < ORDER+BIAS-1; iii = iii + 1) begin
    delay[iii] = 0;
  end
end

wire rst_restart_pulse = rst_restart & clk_fast;
wire signed [NBDATA*2-1:0] mult = out_mux1 * out_mux2;


// deslocamento dos dados
always @(posedge clk or posedge clr or posedge rst_restart_pulse) begin
	if (clr | rst_restart_pulse) begin
		state <= 0;
		

		
	end
	else begin
		
		state <= 1;
		
	
		delay[0] <= data_in;
		
		for(i = 0; i < ORDER+BIAS-2; i = i + 1)
			delay[i+1] <= delay[i];
			
	end	

	
end

always @(posedge clk_fast or posedge clr or posedge rst_restart_pulse)
begin
	if (clr) begin
		state2 <= 1'd0;
		acc <= 0;
		rst_restart <= 0;
	end
	else begin
		if (rst_restart_pulse)	begin
			rst_restart <= 0;
		end
		else begin
			if (state) begin
				state2 <= state2 + 1'd1;
				acc <= acc + mult;				
			end
			else
			begin
				state2 <= 0;
				acc <= 0;
				rst_restart <= 0;
			end
			
			if (state2 == 3) begin
				rst_restart <= 1;
			end
			else begin
				rst_restart <= 0;
			end
			
			if (state2 == 4) begin
				data_out <= acc + out_mux1 * out_mux2;
				state2 <= 0;
				acc <= 0;
			end
			
		end
			
		
	end
	

end


//One DSP only
always @(*) begin

  if (state) begin
		
		case(state2)
			0 : begin
				//out_mux1 <= weights[0];
				out_mux1 <=  {{(NBDATA-NB_WEIGHT){weights[0][NB_WEIGHT-1]}},weights[0]};
				out_mux2 <= data_in; 
			end
			
			1 : begin
				//out_mux1 <= weights[1];
				out_mux1 <=  {{(NBDATA-NB_WEIGHT){weights[1][NB_WEIGHT-1]}},weights[1]};
				out_mux2 <= delay[0];
			end
			
			2 : begin
				//out_mux1 <= weights[2];
				out_mux1 <=  {{(NBDATA-NB_WEIGHT){weights[2][NB_WEIGHT-1]}},weights[2]};
				out_mux2 <= delay[1];
			end
			
			3 : begin
				//out_mux1 <= weights[3];
				out_mux1 <=  {{(NBDATA-NB_WEIGHT){weights[3][NB_WEIGHT-1]}},weights[3]};
				out_mux2 <= delay[2]; 
			end
			
			4 : begin
				//out_mux1 <= weights[4];
				out_mux1 <=  {{(NBDATA-NB_WEIGHT){weights[4][NB_WEIGHT-1]}},weights[4]};
				out_mux2 <= delay[3];  
			end
			
			default : begin
				out_mux1 <= 0;
				out_mux2 <= 0;  
			end
			
		endcase
		
  end
  
end

//assign data_out = acc;


endmodule

