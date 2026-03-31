// Generates a uniformly distributed random number
module random_number_generator
#(
	parameter RAND_OUT_SIZE = 7, //Bits of the random number output
	parameter LFSR_B = 42,       //Bits of the LFSR
	parameter SEED0 = 64'd461934351,    //SEED for the 1st LFSR
	parameter SEED1 = 64'd363409739,    //SEED for the 2nd LFSR
	parameter SEED2 = 64'd209805534,    //SEED for the 3rd LFSR
	parameter SEED3 = 64'd3049884771,   //SEED for the 4th LFSR
	parameter SEED4 = 64'd2859598492,   //SEED for the 5th LFSR
	parameter SEED5 = 64'd352859598492, //SEED for the 6th LFSR
	parameter SEED6 = 64'd42859998594   //SEED for the 7th LFSR
)
(
	//Clock and reset signals
	input clk, rst,
	//Random number output
	output [RAND_OUT_SIZE-1:0] rand_out
);
	

//Wire for extract all LFSR outputs
wire [RAND_OUT_SIZE-1:0] rand0, rand1, rand2, rand3, rand4,rand5,rand6;

// 1st LFSR
rand_LFSR
#(
	.seed(SEED0),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand0
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand0)
);


// 2nd LFSR
rand_LFSR
#(
	.seed(SEED1),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand1
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand1)
);


// 3rd LFSR
rand_LFSR
#(
	.seed(SEED2),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand2
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand2)
);


// 4th LFSR
rand_LFSR
#(
	.seed(SEED3),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand3
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand3)
);


// 5th LFSR
rand_LFSR
#(
	.seed(SEED4),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand4
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand4)
);


// 6th LFSR
rand_LFSR
#(
	.seed(SEED5),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand5
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand5)
);


// 7th LFSR
rand_LFSR
#(
	.seed(SEED6),
	.DATA_OUT_SIZE(RAND_OUT_SIZE),
	.LFSR_BITS(LFSR_B)
)
mod_rand6
(
	.clk(clk),
	.rst(rst),
	.rand_out(rand6)
);


//Concatenate all LFSR outputs
wire [7*RAND_OUT_SIZE-1:0] rand_in = {rand6,rand5,rand4,rand3,rand2,rand1,rand0};

//Pool the LFSR outputs
select_rand
#(
	.num_rands(7),
	.DATA_OUT_SIZE(RAND_OUT_SIZE)
) rand_final
(
	.clk(clk), 
	.rst(rst),
	.in(rand_in),
	.out(rand_out)
);


endmodule