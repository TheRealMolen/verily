`timescale 1ns / 1ps

module verily_test;

	// Inputs
	reg clk;
	reg [7:0] switch;
	reg joy_select;

	// Outputs
	wire [7:0] led;
	
	always #1 clk = ~clk;

	// Instantiate the Unit Under Test (UUT)
	verily uut (
		.clk(clk), 
		.switch(switch), 
		.led(led),
		.joy_select(joy_select)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		switch = 128;
		joy_select = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		joy_select = 1;
		#10;
		joy_select = 0;
        
		// Add stimulus here
		switch = 1;
		
		#800000;
	end
      
endmodule

