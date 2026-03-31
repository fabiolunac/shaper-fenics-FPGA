// APPLY THE BUNCH TRAIN MASK
module bunch_train_mask
#(
	parameter BUNCH_MEM = "bunch_train_mask.mif", //Name of the memory of Bunch train pattern
	parameter BUNCH_POS = 3564                    //Size of memory of Bunch train pattern
)
(
	//Clock and reset signals
	input clk,rst,
	//Output of the bunch train pattern
	output reg out = 0
);


// Initiate the memory
reg [0:0] mask [0:BUNCH_POS-1];

initial begin
	//$readmemb(BUNCH_MEM, mask);
	$readmemb(BUNCH_MEM, mask);
end


//Pass through all bunch train pattern memory
reg [$clog2(BUNCH_POS)-1:0] position = 0;

always@(posedge clk or posedge rst) begin

	if (rst) begin
		position <= 0;
		out <= 0;
	end
	else begin
	
		out <= mask[position];
	
		position <= position + 1'd1;
		
		if (position == BUNCH_POS-1) begin
			position <= 0;
		end
		
	end
	

end

endmodule

