// Define the Hits positions 
module Hits_Bunch_train
#(
	parameter RAND_BITS = 7,                       //Bits of random number generator to hits positions
	parameter BUNCH_MEM = "bunch_train_mask.mif",  //Memory name of the Bunch train pattern
	parameter BUNCH_POS = 3564,                    //Number of positions of bunch train pattern memory
	parameter BUNCH_TRAIN_ACTIVE = 1               //Activate the bunch train pattern
)
(
	//Clock and reset signals
	input clk, rst,
	//Occupancy of the cell (0 - 0%; 127 - 100%)
	input [RAND_BITS-1:0] occupancy,
	// Hits + Bunch train pattern output
	output hits_out, 
	// Hits without Bunch train pattern output
	output hits_orig, 
	// Bunch train pattern mask output
	output bt_mask_out
);

//Random number generator
wire [RAND_BITS-1:0] rand_hits;

random_number_generator
#(
	.RAND_OUT_SIZE(RAND_BITS),
	.LFSR_B(42),
	.SEED0(64'd461934351),
	.SEED1(64'd363409739),
	.SEED2(64'd209805534),
	.SEED3(64'd3049884771),
	.SEED4(64'd2859598492),
	.SEED5(64'd352859598492),
	.SEED6(64'd42859998594)
) rng_hits
(
	.clk(clk), 
	.rst(rst),
	.rand_out(rand_hits)
);

//Defining the positions of the hits with the occupancy
wire hits;

hits_positions
#(
	.IN_SIZE(RAND_BITS)
) hits_pos
(
	.clk(clk), 
	.rst(rst),
	.in(rand_hits),
	.occupancy(occupancy),	
	.hit(hits)
);

//Bunch train pattern mask
wire bt_out;

bunch_train_mask
#(
	.BUNCH_MEM(BUNCH_MEM),
	.BUNCH_POS(BUNCH_POS)
)bt_mask
(
	.clk(clk),
	.rst(rst),
	.out(bt_out)
);

//Adjusting the outputs
assign hits_orig = hits; 
assign bt_mask_out = bt_out | ~BUNCH_TRAIN_ACTIVE[0];
assign hits_out = hits & bt_mask_out;

endmodule
