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


module mod_adder (
	input [1:0] i_a,
	input [1:0] i_b,
	output [2:0] o_sum);
	
	assign o_sum[0] = i_a[0] ^ i_b[0];
	assign o_sum[1] = (i_a[0] & i_b[0]) ^ (i_a[1] ^ i_b[1]);
	assign o_sum[2] = ((i_a[0] & i_b[0]) & (i_a[1] | i_b[1])) | (i_a[1] & i_b[1]);
endmodule


module mod_mem (
   input i_clk,
	input i_sel,
	input i_rw,	// 0=read, 1=write
	input [4:0] i_addr,
	input [3:0] i_wData,
	output[3:0] o_rData);
	
	reg [3:0] store [0:31];
	
	reg [3:0] rDataLatch;
	assign o_rData = rDataLatch;
	
	always @(posedge i_clk) begin
		if (i_sel) begin
			if (i_rw == 0) begin
				// READ
				rDataLatch <= store[i_addr];
			end
			else begin
				// WRITE
				store[i_addr] <= i_wData;
			end
		end
	end
	
	initial begin
		$readmemh("kabanos.mem", store, 0, 31);
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
	assign o_seg7_nSel[1] =  curr_digit[1] | ~curr_digit[0];
	assign o_seg7_nSel[0] = ~curr_digit[1] |  curr_digit[0];
	
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


module verily (
    input wire i_clk,
    input wire[7:0] i_switch,
    output wire[6:0] o_seg7,
	// output wire seg7_dp,
    output wire[3:0] o_seg7_nSel,
	 output wire[7:0] o_led
    );
	 
	wire[2:0] aplusb;
	
	mod_adder adderAB(i_switch[1:0], i_switch[5:4], aplusb);
		
	reg mem_sel, mem_rw;
	reg [4:0] mem_addr = 0;
	reg [3:0] mem_wData;
	wire [3:0] mem_rData;
	
	mod_mem mem(
		.i_clk(main_clk),
		.i_sel(mem_sel),
		.i_rw(mem_rw),
		.i_addr(mem_addr),
		.i_wData(mem_wData),
		.o_rData(mem_rData));
	
	reg[4:0] pc = 0;
	
	reg[24:0] clkDiv;
	assign main_clk = clkDiv[23];
	
	wire [3:0] aplusb_pad;
	assign aplusb_pad[3] = 0;
	assign aplusb_pad[2:0] = aplusb;
	
	assign o_led[7] = mem_sel;
	assign o_led[6] = mem_rw;
	assign o_led[5] = pc[4];
	assign o_led[4] = 0;
	assign o_led[3:0] = mem_rData;
	
	mod_4digitdisp disp(
		.i_clk(i_clk),
		.i_digit0(i_switch[3:0]),
		.i_digit1(i_switch[7:4]),
		.i_digit2(aplusb_pad),
		.i_digit3(pc[3:0]),
   	.o_seg7(o_seg7),
   	.o_seg7_nSel(o_seg7_nSel));
	
	always @(posedge i_clk) begin
		clkDiv	<= clkDiv + 1;
	end
	
	// core loop
	always @(posedge clkDiv[24]) begin
		mem_addr = pc;
		mem_rw = 0;
		mem_sel = 1;
	
		pc = pc + 1;
	end
endmodule
