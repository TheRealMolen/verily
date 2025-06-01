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




module mod_adder (
	input [1:0] i_a,
	input [1:0] i_b,
	output [3:0] o_sum);
	
	assign o_sum[0] = i_a[0] ^ i_b[0];
	assign o_sum[1] = (i_a[0] & i_b[0]) ^ (i_a[1] ^ i_b[1]);
	assign o_sum[2] = ((i_a[0] & i_b[0]) & (i_a[1] | i_b[1])) | (i_a[1] & i_b[1]);
	assign o_sum[3] = 0;
endmodule


module mod_hsubber (
	input i_l,
	input i_r,
	output o_sub,
	output o_borrow);

	//  l  r  o  u
	//  0  0  0  0
	//  1  0  1  0
	//  1  1  0  0
	//  0  1  1  1
	
	assign o_borrow = ~i_l & i_r;
	assign o_sub = (i_l & ~i_r) | (~i_l & i_r);	
endmodule

module mod_sub1 (
	input i_l,
	input i_r,
	input i_borrow,
	output o_sub,
	output o_borrow);

	//  l  r  b   o  u
	//  0  0  0   0  0
	//  1  1  0   0  0
	//  1  0  0   1  0
	//  0  1  0   1  1
	//  0  0  1   1  1
	//  1  1  1   1  1
	//  1  0  1   0  0
	//  0  1  1   0  1
	
	assign all1 = (i_l & i_r & i_borrow);
	assign sub1 = i_r ^ i_borrow;
	assign sub0 = ~i_r & ~i_borrow;
	
	assign o_borrow = (~i_l & (i_r | i_borrow)) | all1;	
	assign o_sub = (~i_l & sub1) | (i_l & sub0) | all1;	
endmodule


module mod_sub2 (
	input [1:0] i_a,
	input [1:0] i_b,
	output [1:0] o_sub,
	output o_borrow);

	wire  brw;
	
	mod_hsubber sub0(i_a[0], i_b[0], o_sub[0], brw);
	mod_sub1 sub1(i_a[1], i_b[1], brw, o_sub[1], o_borrow);
	
endmodule


// sum <= a - b
module mod_subber (
	input [1:0] i_a,
	input [1:0] i_b,
	output [3:0] o_sum);
	
	wire borrow;
	mod_sub2 sub(i_a, i_b, o_sum[1:0], borrow);
	
	assign o_sum[2] = borrow;
	assign o_sum[3] = borrow;
endmodule


module verily (
    input wire i_clk,
    input wire[7:0] i_switch,
    output wire[6:0] o_seg7,
	// output wire seg7_dp,
    output wire[3:0] o_seg7_nSel,
	 output wire[7:0] o_led
    );
	 
	wire[3:0] aplusb;
	wire[3:0] asubb;
	
	wire[3:0] regA = i_switch[7:4];
	wire[3:0] regB = i_switch[3:0];
	wire[1:0] regAh = regA[1:0];
	wire[1:0] regBh = regB[1:0];
	
	mod_adder adderAB(regAh, regBh, aplusb);
	mod_subber subberAB(regAh, regBh, asubb);
		
	reg mem_sel, mem_rw;
	reg [4:0] mem_addr = 0;
	reg [3:0] mem_wData = 0;
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
	assign main_clk = clkDiv[21];
	
	assign o_led[7] = mem_sel;
	assign o_led[6] = mem_rw;
	assign o_led[5] = pc[4];
	assign o_led[4] = 0;
	assign o_led[3:0] = mem_rData;
	
	wire[3:0] acc = mem_rData[0] ? aplusb : asubb;
	
	mod_4digitdisp disp(
		.i_clk(i_clk),
		.i_digit0(regA),
		.i_digit1(regB),
		//.i_digit2(acc),
		//.i_digit3(pc[3:0]),
		.i_digit2(aplusb),
		.i_digit3(asubb),
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
