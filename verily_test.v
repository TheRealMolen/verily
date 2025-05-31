`timescale 1ns / 1ps

module verily_test;

	// Inputs
	reg clk;
	reg [7:0] switch;
	reg [6:0] seg7;
	reg [3:0] seg7_nSel;
	//reg joy_select;

	// Outputs
	//wire [7:0] led;
	
	always #1 clk = ~clk;

	// Instantiate the Unit Under Test (UUT)
	verily uut (
		.i_clk(clk), 
		.i_switch(switch),
		.o_seg7(seg7),
		.o_seg7_nSel(seg7_nSel)
	//	.led(led),
	//	.joy_select(joy_select)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		switch = 8'b0001_0010;
	//	joy_select = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
	//	joy_select = 1;
		#10;
	//	joy_select = 0;
        
		// Add stimulus here
		switch = 1;
		
		#800000;
	end
      
endmodule

