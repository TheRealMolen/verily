`timescale 1ns / 1ps

// hex -> 7 segment display driver
module mod_digit(
    input [3:0] value,
    output [6:0] segs_out
    );
	 
	reg[6:0] segments;
	assign segs_out = segments;
	
	always @(value) begin
		case (value)
			0:		segments <= 7'b1000000;
			1:		segments <= 7'b1111001;
			2:		segments <= 7'b0100100;
			3:		segments <= 7'b0110000;
			4:		segments <= 7'b0011001;
			5:		segments <= 7'b0010010;
			6:		segments <= 7'b0000010;
			7:		segments <= 7'b1011000;
			8:		segments <= 7'b0000000;
			9:		segments <= 7'b0010000;
			10:	segments <= 7'b0001000;
			11:	segments <= 7'b0000011;
			12:	segments <= 7'b0100111;
			13:	segments <= 7'b0100001;
			14:	segments <= 7'b0000110;
			15:	segments <= 7'b0001110;
			default:	segments <= 0;
		endcase
	end
endmodule


module verily (
    input wire clk,
    input wire[7:0] switch,
    output wire[6:0] seg7,
	// output wire seg7_dp,
    output wire[3:0] seg7_nSel
	// output wire[2:0] led
    );
	
	reg[1:0] curr_digit;	
	wire[6:0] segs0;
	wire[6:0] segs1;
	wire[6:0] segs2;
	wire[6:0] segs3;
	// assuming digits read 0-3 with the vga socket on the left
	mod_digit digit0(switch[3:0], segs0);
	mod_digit digit1(switch[7:4], segs1);
	mod_digit digit2(0, segs2);
	mod_digit digit3(12, segs3);
	
	reg[6:0] segs;
	assign seg7 = segs;
	
	assign seg7_nSel[3] =  curr_digit[1] |  curr_digit[0];
	assign seg7_nSel[2] = ~curr_digit[1] | ~curr_digit[0];
	assign seg7_nSel[1] =  curr_digit[1] | ~curr_digit[0];
	assign seg7_nSel[0] = ~curr_digit[1] |  curr_digit[0];
	
	reg[14:0] muxDelay;
	
	always @(posedge clk) begin
		muxDelay	<= muxDelay + 1;
	end
	
	always @(posedge muxDelay[14]) begin
		curr_digit <= curr_digit + 1;
		
		case (curr_digit)
			0: segs <= segs0;
			1: segs <= segs1;
			2: segs <= segs2;
			3: segs <= segs3;
			default: segs <= 7'b1111111;
		endcase
	end
endmodule
