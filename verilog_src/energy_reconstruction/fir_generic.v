module fir_generic
#(
	parameter NBDATA = 10,
	parameter NBITS_OUT = 25,
	parameter NB_WEIGHT = 10,
	parameter ORDER = 11,
	parameter BIAS = 0,
	parameter WEIGHTS_FILE = "weight_ls.mif"
)
(
	input clk,
	input clr,
	input signed [NBDATA-1:0] data_in,
	output reg signed [NBITS_OUT-1:0] data_out = 0
);

reg signed [NB_WEIGHT-1:0] weights [ORDER+BIAS-1:0];
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

// deslocamento dos dados
always @(posedge clk) begin
	delay[0] <= data_in;
	for(i = 0; i < ORDER+BIAS-2; i = i + 1)
		delay[i+1] <= delay[i];
end

reg signed [NBITS_OUT-1:0] acc;

// cálculo do FIR
always @(*) begin
	acc = 0;

	if (BIAS) begin
		//acc = weights[0];
		acc = weights[0] + weights[1] * data_in;
		for (ii = 1; ii < ORDER+BIAS-1; ii = ii + 1)
			acc = acc + weights[ii+1] * delay[ii-1];
	end else begin
		acc = weights[0] * data_in;
		for (ii = 0; ii < ORDER+BIAS-1; ii = ii + 1)
			acc = acc + weights[ii+1] * delay[ii];
	end

	data_out = acc;
end

endmodule
