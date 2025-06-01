`timescale 1ns / 1ps


// hex -> 7 segment display driver
module mod_digit(
    input [3:0] i_value,
    output [6:0] o_segs
    );
	 
	reg[6:0] segments;
	assign o_segs = segments;
	
	always @(i_value) begin
		case (i_value)
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


// assuming digits read 0-3 with the vga socket on the left
module mod_4digitdisp (
   input wire i_clk,
	input wire[3:0] i_digit0,
	input wire[3:0] i_digit1,
	input wire[3:0] i_digit2,
	input wire[3:0] i_digit3,
   output wire[6:0] o_seg7,
   output wire[3:0] o_seg7_nSel
	);
	
	wire[6:0] segs0;
	wire[6:0] segs1;
	wire[6:0] segs2;
	wire[6:0] segs3;
	
	reg[1:0] curr_digit;
	
	reg[6:0] segs;
	assign o_seg7 = segs;
	
	assign o_seg7_nSel[3] =  curr_digit[1] |  curr_digit[0];
	assign o_seg7_nSel[2] = ~curr_digit[1] | ~curr_digit[0];
	assign o_seg7_nSel[1] = ~curr_digit[1] |  curr_digit[0];
	assign o_seg7_nSel[0] =  curr_digit[1] | ~curr_digit[0];
	
	reg[14:0] muxDelay;
	
	mod_digit digit0(i_digit0, segs0);
	mod_digit digit1(i_digit1, segs1);
	mod_digit digit2(i_digit2, segs2);
	mod_digit digit3(i_digit3, segs3);
	
	always @(posedge i_clk) begin
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


