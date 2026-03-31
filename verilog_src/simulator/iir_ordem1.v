// IIR FILTER - 1st ORDER
module iir_ordem1

#( 
	parameter BITS_IN = 33,      //Bits of input
	parameter G_ENTRADA = 2**32, //Gain of input
	parameter G_SAIDA_LOG = 10,  //Gain of the weights
	//IIR weights
	parameter signed b0 =   785,  
	parameter signed a1 =  -1366
)

(
	//Clock input
	input  clock,
	//IIR input
	input  signed [BITS_IN-1:0] in,
	//IIR output
	output signed [BITS_IN+16:0] out
	);
	
	//feedback register
	reg signed  [BITS_IN+16:0] ry = 0;
	//Nominator
	wire signed [BITS_IN+16:0] yz;
	//Denominator
	wire signed [BITS_IN+G_SAIDA_LOG+16:0] yp;
		
	
	
	assign yz =   b0*in;
	assign yp = - a1*ry;
	assign out =   yz + (yp >>> G_SAIDA_LOG); //Feedback without the gain of weight to prevent issues
	
	
	always @(posedge clock)
	begin
		ry <= out; // delaying the output
	end
	
	
endmodule