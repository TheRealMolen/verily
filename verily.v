`timescale 1ns / 1ps

module verily(
    input wire clk,
	 input wire joy_select,		// used to reset
    input wire[7:0] switch,
    output wire[7:0] led
    );

	reg[7:0] counter;
	reg[20:0] accum;
	
	assign led = counter;
		
	always @(posedge clk) begin
		if (~joy_select) begin	// reset
			counter <= 0;
			accum <= 0;
		end
		else begin
			accum <= accum + 1;
			if (accum[20:13] == switch) begin
				counter <= counter + 1;
				accum <= 0;
			end
		end
	end
endmodule
