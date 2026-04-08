module Pulse_Simulator_FPGA_v2
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
    parameter MEM_NOISE1_THRESH = 1007,       //Threshold position of the second memory of the noise generator
    parameter PZC_M_FACTOR = 454,       //M factor of the PZC
//    parameter PZC_OUT_BITS = CLIP_OUT_BITS+1+16, //Bits of the PZC output
    parameter PZC_OUT_BITS = CLIP_OUT_BITS+1, //New Bits of the PZC output (13)
    parameter WIENER_NORMAL_OUT_BITS = CLIP_OUT_BITS + 21, //Bits of the Wiener filter outuput
    parameter WIENER_PZC_OUT_BITS = PZC_OUT_BITS + 15 + 17,     //Bits of the PZC+Wiener filter output
    //parameter WIENER_PZC_OUT_BITS = CLIP_OUT_BITS + 21,     //Bits of the PZC+Wiener filter output
    parameter WEIGHTS_WIENER_ONLY_FILE = "weight_ls_normal_a13.mif",   // Name of the file containing weights of wiener filter without pzc
    parameter WEIGHTS_WIENER_PZC_FILE = "weight_ls_pzc_a13.mif",     // Name of the file containing weights of wiener filter with pzc
    parameter SHIFT_PZC = 9 //Bit number to obtain 13b for PZC
)
(
	//////////// CLOCK //////////
	input 		          		FPGA_CLK_125_P,
	input 		          		FPGA_CLK_125_N,

	//////////// KEY //////////
	input 		     [4:0]		GPIO_MOMENTARY,

	//////////// LED //////////
	output		     [7:0]		LED,
	
	///// PMOD Connectors ////
	output           [12:0]      PMOD
	
	////////// I/O //////////
	/*output bt_mask_out,
	output [RAND_BITS_HITS-1:0] occupancy,
    output [ENG_OUT_BITS-1:0] event_bt,
    output signed [CLIP_OUT_BITS-1:0] adc_out,
    output signed [PZC_OUT_BITS-1:0] pzc_out,
    output signed [WIENER_NORMAL_OUT_BITS-1:0] wiener_normal_out,
    output signed [WIENER_PZC_OUT_BITS-1:0] wiener_pzc_out,
    output signed [CLIP_OUT_BITS+1-1:0] pedestal_out*/
	
);


//=======================================================
//  Parameters declaration
//=======================================================





//=======================================================
//  REG/WIRE declarations
//=======================================================

wire rst = GPIO_MOMENTARY[4];

//// PLL to reduce clk frequency
wire clk_40;
wire clk_200;

//// Treating buttons to change occupancy and pedestal
(* KEEP = "true" *) wire [RAND_BITS_HITS-1:0] occupancy;
(* KEEP = "true" *) reg [RAND_BITS_HITS-1:0] occupancy_reg;
(* KEEP = "true" *) reg signed [WIENER_PZC_OUT_BITS-1:0] wiener_pzc_out_reg;
//(* KEEP = "true" *) reg signed [WIENER_NORMAL_OUT_BITS-1:0] wiener_pzc_out_reg;
(* KEEP = "true" *) wire signed [ENG_OUT_BITS-1:0] pedestal_in;
(* KEEP = "true" *) reg signed [ENG_OUT_BITS-1:0] pedestal_in_reg;
wire [3:0] buttons;
          

always@(posedge clk_40) begin
    occupancy_reg <= occupancy;
    wiener_pzc_out_reg <= wiener_pzc_out;
    pedestal_in_reg <= pedestal_in;
    bt_mask_out_reg <= bt_mask_out;
    adc_out_reg <= adc_out;
    pzc_out_reg <= pzc_out;
    wiener_normal_out_reg <= wiener_normal_out;
    pedestal_out_reg <= pedestal_out;
    event_bt_reg <= event_bt;
//    pzc_out_13b_reg <= pzc_out_13b;
//    pzc_out_12b_div_reg <= pzc_out_12b_div;  
end


(* KEEP = "true" *) wire bt_mask_out;
(* KEEP = "true" *) reg bt_mask_out_reg;
(* KEEP = "true" *) wire [ENG_OUT_BITS-1:0] event_bt;
(* KEEP = "true" *) reg [ENG_OUT_BITS-1:0] event_bt_reg;
(* KEEP = "true" *) wire signed [CLIP_OUT_BITS-1:0] adc_out;
(* KEEP = "true" *) reg signed [CLIP_OUT_BITS-1:0] adc_out_reg;
(* KEEP = "true" *) wire signed [PZC_OUT_BITS-1:0] pzc_out;
(* KEEP = "true" *) reg signed [PZC_OUT_BITS-1:0] pzc_out_reg;
(* KEEP = "true" *) wire signed [WIENER_NORMAL_OUT_BITS-1:0] wiener_normal_out;
(* KEEP = "true" *) reg signed [WIENER_NORMAL_OUT_BITS-1:0] wiener_normal_out_reg;
(* KEEP = "true" *) wire signed [WIENER_PZC_OUT_BITS-1:0] wiener_pzc_out;
//(* KEEP = "true" *) wire signed [WIENER_NORMAL_OUT_BITS-1:0] wiener_pzc_out;
(* KEEP = "true" *) wire signed [CLIP_OUT_BITS+1-1:0] pedestal_out;
(* KEEP = "true" *) reg signed [CLIP_OUT_BITS+1-1:0] pedestal_out_reg;

//13 bits PZC
//(* KEEP = "true" *) reg signed  [12:0] pzc_out_13b_reg;
//(* KEEP = "true" *) wire signed [12:0] pzc_out_13b;

//assign pzc_out_12b_div = pzc_out/(PZC_M_FACTOR+1);

//assign pzc_out_13b = pzc_out >>> 9;

//wire [WIENER_PZC_OUT_BITS-1:0] sum = bt_mask_out + event_bt + adc_out + pzc_out + wiener_normal_out + wiener_pzc_out + pedestal_out;

//assign PMOD[0] = |sum;

assign LED[RAND_BITS_HITS-1:0] = occupancy;
//assign PMOD = wiener_pzc_out;
assign buttons = GPIO_MOMENTARY[3:0];
assign rst = GPIO_MOMENTARY[4];

//=======================================================
//  Structural coding
//=======================================================


//// PLL to reduce clk frequency

 wire locked;
clk_wiz_0 clk_wiz_0 (
  .clk_40mhz(clk_40),
  .clk_200mhz(clk_200),
 .reset(rst),
 .locked(locked),
 .clk_in1_p(FPGA_CLK_125_P),
 .clk_in1_n(FPGA_CLK_125_N)
);

	

//// Treating buttons to change occupancy and pedestal
sw_converter
#(
    .IN_SIZE(4),
	.OUT_SIZE_OCC(RAND_BITS_HITS),
	.OUT_SIZE_PED(ENG_OUT_BITS)
) swc
(
	.clk(clk_40 & locked), 
	.rst(rst),
	.in(buttons),
	.occ_out(occupancy),
	.ped_out(pedestal_in)
);




///// Real-time pulse simulator
FPGA_Simulator_v1
#(
    .RAND_BITS_HITS(RAND_BITS_HITS),
	.BUNCH_MEM(BUNCH_MEM),
	.BUNCH_POS(BUNCH_POS),
	.BUNCH_TRAIN_ACTIVE(BUNCH_TRAIN_ACTIVE),
	.RAND_BITS_ENG(RAND_BITS_ENG),
	.ENG_OUT_BITS(ENG_OUT_BITS),
	.CLIP_OUT_BITS(CLIP_OUT_BITS),
	.SHAPER_OUT_BITS(SHAPER_OUT_BITS),
	.MEM_ENG_SIZE(MEM_ENG_SIZE),
	.MEM_ENG0(MEM_ENG0),
	.MEM_ENG1(MEM_ENG1),
	.MEM_ENG2(MEM_ENG2),
	.MEM_ENG0_THRESH(MEM_ENG0_THRESH),
	.MEM_ENG1_THRESH(MEM_ENG1_THRESH), 
	.RAND_BITS_NOISE(RAND_BITS_NOISE),
	.NOISE_OUT_BITS(NOISE_OUT_BITS),
	.MEM_NOISE_SIZE(MEM_NOISE_SIZE),
	.MEM_NOISE0(MEM_NOISE0),
	.MEM_NOISE1(MEM_NOISE1),
	.MEM_NOISE2(MEM_NOISE2),
	.MEM_NOISE0_THRESH(MEM_NOISE0_THRESH),
	.MEM_NOISE1_THRESH(MEM_NOISE1_THRESH)
)
sim
(
	.clk(clk_40 & locked), 
	.rst(rst),
	.occupancy(occupancy),
	.pedestal_in(pedestal_in),
	.hits_out(),
	.bt_mask_out(bt_mask_out),
	.energy_out(), 
	.event_bt(event_bt),
	.event_all(),
	.shaper_out(),
	.shaper_corrupted(),
	.shaper_clip(adc_out),
	.noise_out()
);


//// Energy Resonctruction
Energy_Reconstruction
#(
    .ENG_OUT_BITS(ENG_OUT_BITS), //Bits of the energy generator output
    .CLIP_OUT_BITS(CLIP_OUT_BITS), //Bits of the ADC output
    .PZC_M_FACTOR(PZC_M_FACTOR),       //M factor of the PZC
	//.WIENER_NORMAL_OUT_BITS(WIENER_NORMAL_OUT_BITS), //Bits of the Wiener filter outuput
	.WIENER_PZC_OUT_BITS(WIENER_PZC_OUT_BITS),      //Bits of the PZC+Wiener filter output
	//.WIENER_PZC_OUT_BITS(CLIP_OUT_BITS + 21),      //Bits of the PZC+Wiener filter output
    .PZC_OUT_BITS(PZC_OUT_BITS), //Bits of the PZC output
    //.WEIGHTS_WIENER_ONLY_FILE(WEIGHTS_WIENER_ONLY_FILE),   // Name of the file containing weights of wiener filter without pzc
    .WEIGHTS_WIENER_PZC_FILE(WEIGHTS_WIENER_PZC_FILE),     // Name of the file containing weights of wiener filter with pzc
    .SHIFT_PZC(SHIFT_PZC)
) eng_rec
(
    .clk(clk_40 & locked),
    .clk_fast(clk_200 & locked),
    .rst(rst),
    .bt_mask(bt_mask_out),
    .cal_readout(adc_out),
    .pedestal_out(pedestal_out),
	.pzc_out(pzc_out),
	//.wiener_normal_out(wiener_normal_out),
	.wiener_pzc_out(wiener_pzc_out)
);

//teste git

endmodule