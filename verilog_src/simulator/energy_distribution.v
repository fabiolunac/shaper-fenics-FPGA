// Generates the energy
module energy_distribution
#(
	parameter RAND_IN_BITS = 10,          //Bits of the Random Number Generator
	parameter ENG_OUT_BITS = 12,          //Bit for the energy output
	parameter MEM_ENG_SIZE = 2**10,       //Size of the memories for the energy generator
	parameter MEM_ENG0 = "A13_PART1.mif", //Name of the 1st memory
	parameter MEM_ENG1 = "A13_PART2.mif", //Name of the 2nd memory
	parameter MEM_ENG2 = "A13_PART3.mif", //Name of the 3rd memory
	parameter MEM_ENG0_THRESH = 1001,     //1st memory position threshold
	parameter MEM_ENG1_THRESH = 985       //2nd memory position threshold
)
(
	//Clock and reset signals
	input clk, rst,
	//Random numbers 
	input [RAND_IN_BITS-1:0] rand0, rand1,rand2,
	//Energy output
	output reg [ENG_OUT_BITS-1:0] energy_out = 0
);


//Initiating the memories
reg [ENG_OUT_BITS-1:0] mem_eng0 [0:MEM_ENG_SIZE-1];
reg [ENG_OUT_BITS-1:0] mem_eng1 [0:MEM_ENG_SIZE-1];
reg [ENG_OUT_BITS-1:0] mem_eng2 [0:MEM_ENG_SIZE-1];


initial begin
	$readmemb(MEM_ENG0, mem_eng0);
	$readmemb(MEM_ENG1, mem_eng1);
	$readmemb(MEM_ENG2, mem_eng2);
end


// Definig the memory that will be used
always @ (posedge clk or posedge rst) begin
	if (rst) begin
		energy_out <= 0;
	end
	else begin
		// Verifies if uses the 1st or 2nd memory 
		if (rand0 > MEM_ENG0_THRESH) begin
		
			// Verifies if uses the 2nd or 3rd memory 
			if (rand1 > MEM_ENG1_THRESH) begin
				energy_out <= mem_eng2[rand2];
			end
			else begin
				energy_out <= mem_eng1[rand1];			
			end
			
		end
		else begin
			energy_out <= mem_eng0[rand0];
		end		
		
	end
	
end



endmodule