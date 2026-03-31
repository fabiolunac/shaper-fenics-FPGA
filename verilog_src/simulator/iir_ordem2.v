// IIR FILTER - 2nd ORDER
module iir_ordem2

#(
	parameter BITS_IN = 33,      //Bits of input
	parameter G_ENTRADA = 2**32, //Gain of input
	parameter G_SAIDA_LOG = 10,  //Gain of the weights
	//IIR weights
	parameter signed b0 =  -788, 
	parameter signed b1 =  -399, 
	parameter signed a1 =  -618,
	parameter signed a2 =   1362
)

(
	//Clock input
	input  clock,
	//IIR input
	input  signed [BITS_IN-1:0] in,
	//IIR output
	output signed [BITS_IN+16:0] out
	);
	
	//feedback registers
	reg signed  [BITS_IN:0] rx1 = 0;
	reg signed  [BITS_IN+16:0] ry1 = 0, ry2 = 0;
	//Nominator
	wire signed [BITS_IN+16:0] yz;
	//Denominator
	wire signed [BITS_IN+G_SAIDA_LOG+16:0] yp;
		
	
	
	assign yz =   b0*in + b1*rx1;
	assign yp = - a1*ry1 - a2*ry2;
	assign out =   yz + (yp >>> G_SAIDA_LOG);//Feedback without the gain of weight to prevent issues
	
	always @(posedge clock)
	begin
	rx1 <= in;  // delaying the input
	ry2 <= ry1; //delaying the 2nd output
   ry1 <= out; //delaying the output
	end
	
	
endmodule
