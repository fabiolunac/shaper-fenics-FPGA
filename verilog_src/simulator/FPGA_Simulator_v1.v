// Real-time pulse simulator
module FPGA_Simulator_v1
#(
	parameter RAND_BITS_HITS = 7, //Bits of random number generator for hits positions
	parameter BUNCH_MEM = "bunch_train_mask.mif", //Memory name of the Bunch train pattern
	parameter BUNCH_POS = 3564, //Number of positions of bunch train pattern memory
	parameter BUNCH_TRAIN_ACTIVE = 1, //Activate the bunch train pattern
	parameter RAND_BITS_ENG = 10, //Bits of random number generator for energy generator
	parameter ENG_OUT_BITS = 13, //Bits of the energy generator output
	parameter CLIP_OUT_BITS = ENG_OUT_BITS-1, //Bits of the ADC output
	parameter SHAPER_OUT_BITS = ENG_OUT_BITS+16+1, //Bits of the shapper output
	parameter MEM_ENG_SIZE = 2**10, //Size of the memory of the energy generator
	parameter MEM_ENG0 = "A13_PART1.mif", //Name of memory file of the first memory of the energy generator
	parameter MEM_ENG1 = "A13_PART2.mif", //Name of memory file of the second memory of the energy generator
	parameter MEM_ENG2 = "A13_PART3.mif", //Name of memory file of the third memory of the energy generator
	parameter MEM_ENG0_THRESH = 1001,     //Threshold position of the first memory of the energy generator
	parameter MEM_ENG1_THRESH = 985,      //Threshold position of the second memory of the energy generator 
	parameter RAND_BITS_NOISE = 10,       //Bits of random number generator for the noise generator
	parameter NOISE_OUT_BITS = 17,        //Bits for the noise generator output
	parameter MEM_NOISE_SIZE = 2**10,         //Size of the memory of the noise generator
	parameter MEM_NOISE0 = "NOISE_PART1.mif", //Name of memory file of the first memory of the noise generator
	parameter MEM_NOISE1 = "NOISE_PART2.mif", //Name of memory file of the second memory of the noise generator
	parameter MEM_NOISE2 = "NOISE_PART3.mif", //Name of memory file of the thrid memory of the noise generator
	parameter MEM_NOISE0_THRESH = 1007,       //Threshold position of the first memory of the noise generator
	parameter MEM_NOISE1_THRESH = 1007        //Threshold position of the second memory of the noise generator
)
(
	//Clock and Reset signals
	input clk, rst,
	//Occupancy of the cell (0 - 0%; 127 - 100%)
	input [RAND_BITS_HITS-1:0] occupancy,
	//Pedestal for the ADC input
	input signed [ENG_OUT_BITS-1:0] pedestal_in,	
	//Hits positions output iwthou 
	output hits_out,
	//Bunch train pattern + hits positions output
	output bt_mask_out,
	//Output of energy generator
	output [ENG_OUT_BITS-1:0] energy_out,
	//Energy output + bt_mask_out
	output [ENG_OUT_BITS-1:0] event_bt,
	//Energy output + hits output without bunch train pattern
	output [ENG_OUT_BITS-1:0] event_all,
	//Shaper output
	output signed [SHAPER_OUT_BITS-1:0] shaper_out,
	//Shaper + Noise output
	output signed [SHAPER_OUT_BITS-1:0] shaper_corrupted,
	//ADC output
	output [CLIP_OUT_BITS-1:0] shaper_clip,
	//Noise output
	output signed [NOISE_OUT_BITS-1:0] noise_out
);




////////   HITS POSITION + BUNCH TRAIN PATTERN   ////////
Hits_Bunch_train
#(
	.RAND_BITS(RAND_BITS_HITS),
	.BUNCH_MEM(BUNCH_MEM),
	.BUNCH_POS(3564),
	.BUNCH_TRAIN_ACTIVE(BUNCH_TRAIN_ACTIVE)
) hb_train
(
	.clk(clk), 
	.rst(rst),
	.occupancy(occupancy),
	.hits_out(hits_out), 
	.hits_orig(hits_orig), 
	.bt_mask_out(bt_mask_out)
);


////////   ENERGY OF COLLISIONS   ////////
energy_collisions
#(
	.RAND_BITS(RAND_BITS_ENG),
	.ENG_OUT_BITS(ENG_OUT_BITS),
	.MEM_ENG_SIZE(MEM_ENG_SIZE),
	.MEM_ENG0(MEM_ENG0),
	.MEM_ENG1(MEM_ENG1),
	.MEM_ENG2(MEM_ENG2),
	.MEM_ENG0_THRESH(MEM_ENG0_THRESH),
	.MEM_ENG1_THRESH(MEM_ENG1_THRESH)
)ec
(
	.clk(clk), 
	.rst(rst),
	.energy_out(energy_out)
);


////////   SHAPER (FENICS or LEGACY)   ////////
//shaper_legacy
shaper_fenics
#( 
	.BITS_IN(ENG_OUT_BITS),
	.G_ENTRADA(2**32),
	.G_SAIDA_LOG(10)
)sf
(
	.clock(clk), 
	.in(event_bt),
	.out(shaper_out)
);


// Combining energy of collisions and hits positions
assign event_bt = energy_out * hits_out;   //With bunch train
assign event_all = energy_out * hits_orig; //without bunch train


//Adjusting the bits of the pedestal input
wire signed [SHAPER_OUT_BITS-1:0] pedestal_in_extended = {{(SHAPER_OUT_BITS-ENG_OUT_BITS){pedestal_in[ENG_OUT_BITS-1]}},pedestal_in};



////////   NOISE GENERATOR   ////////
noise_collisions
#(
	.RAND_BITS(RAND_BITS_NOISE),
	.NOISE_OUT_BITS(NOISE_OUT_BITS),
	.MEM_NOISE_SIZE(MEM_NOISE_SIZE),
	.MEM_NOISE0(MEM_NOISE0),
	.MEM_NOISE1(MEM_NOISE1),
	.MEM_NOISE2(MEM_NOISE2),
	.MEM_NOISE0_THRESH(MEM_NOISE0_THRESH),
	.MEM_NOISE1_THRESH(MEM_NOISE1_THRESH)
) noise_sim
(
	.clk(clk),
	.rst(rst),
	.noise_out(noise_out)
	

);


//Adjusting the bits of the noise and summing with the shaper signal
assign shaper_corrupted = (shaper_out + {{(SHAPER_OUT_BITS-NOISE_OUT_BITS){noise_out[NOISE_OUT_BITS-1]}},noise_out});



////////   ADC SIMULATION   ////////
clip_shaper
#( 
	.BITS_IN(SHAPER_OUT_BITS),
	.BITS_OUT(CLIP_OUT_BITS)
)clip
(
	.clk(clk),
	.rst(rst),
	.in(shaper_corrupted),
	.pedestal_in(pedestal_in_extended),
	.out(shaper_clip)
);



endmodule