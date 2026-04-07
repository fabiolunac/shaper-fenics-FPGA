`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 14:08:11
// Design Name: 
// Module Name: Energy_Reconstruction
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


module Energy_Reconstruction
#(
    parameter ENG_OUT_BITS = 13, //Bits of the energy generator output
    parameter CLIP_OUT_BITS = ENG_OUT_BITS-1, //Bits of the ADC output
    parameter PZC_M_FACTOR = 454,       //M factor of the PZC
	parameter PZC_OUT_BITS = CLIP_OUT_BITS+1+16, //Bits of the PZC output
	parameter WIENER_PZC_OUT_BITS = PZC_OUT_BITS + 15,     //Bits of the PZC+Wiener filter output
    parameter WEIGHTS_WIENER_PZC_FILE = "weight_ls_pzc_d2.mif"     // Name of the file containing weights of wiener filter with pzc
)
(
    ////// INPUTS
    // Clock 40MHz
    input clk,
    // Clock 200MHz
    input clk_fast,
    // Reset
    input rst,
    // Bunch train mask
    input bt_mask,
    // Calorimeter Readout
    input [CLIP_OUT_BITS-1:0]  cal_readout,
    
    ////// OUTPUTS
    // Pedestal that PZC has tracked
    output signed [CLIP_OUT_BITS+1-1:0] pedestal_out,
    //PZC output
	output signed [PZC_OUT_BITS-1:0] pzc_out,
	//PZC+Wiener output
	output signed [WIENER_PZC_OUT_BITS-1:0] wiener_pzc_out    

);
    
    
////////   PZC (PEDESTAL TRACKING + ACC CORRECTION)   ////////
pzc_ped_track
#(
	.NBITS_IN(CLIP_OUT_BITS+1),          // Numero de bits de dados
	.NBITS_OUT(PZC_OUT_BITS),          // Numero de bits de dados de saida
	.M_FACTOR(PZC_M_FACTOR)//,         // Fator M do PZC
	//.K_CORR(2**4)				  // Quando vai corrigir a saida
)pzc_zero
(
	.clk(clk), 
	.rst(rst),
	.bt_mask_out(bt_mask),
	.in({1'd0,cal_readout}),
	.pedestal(pedestal_out),
	.io_out_13b(pzc_out)
);



wire signed [12:0] pzc_out_div = pzc_out/(455);


//////////   PZC + WIENER   ////////
//fir_generic_fast
//#(
//	.NBDATA(PZC_OUT_BITS),
//	.NBITS_OUT(WIENER_PZC_OUT_BITS),
//	.NB_WEIGHT(10),
//	.ORDER(5),
//	.BIAS(0),
//	.WEIGHTS_FILE(WEIGHTS_WIENER_PZC_FILE)
//)
//fir_generic_pzc
//(
//	.clk(clk),
//	.clk_fast(clk_fast),
//	.clr(rst),
//	.data_in(pzc_out),
//	.data_out(wiener_pzc_out)
//);    


////////   PZC + WIENER   ////////
fir_generic_fast_stb
#(
	.NBDATA(PZC_OUT_BITS),
	.NBITS_OUT(WIENER_PZC_OUT_BITS),
	.NB_WEIGHT(10),
	.ORDER(5),
	.BIAS(0),
	.WEIGHTS_FILE(WEIGHTS_WIENER_PZC_FILE)
)
fir_generic_pzc
(
	.clk(clk),
	.clk_fast(clk_fast),
	.clr(rst),
	.data_in(pzc_out),
	.data_out(wiener_pzc_out)
);    
    

endmodule
