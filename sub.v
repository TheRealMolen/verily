`timescale 1ns / 1ps

module mod_hsubber (
	input i_l,
	input i_r,
	output o_res,
	output o_borrow);

	//  l  r  o  u
	//  0  0  0  0
	//  1  0  1  0
	//  1  1  0  0
	//  0  1  1  1
	
	assign o_borrow = ~i_l & i_r;
	assign o_res = (i_l & ~i_r) | (~i_l & i_r);	
endmodule



module mod_sub1 (
	input i_l,
	input i_r,
	input i_borrow,
	output o_res,
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
	assign o_res = (~i_l & sub1) | (i_l & sub0) | all1;	
endmodule


module mod_sub4 (
	input [3:0] i_a,
	input [3:0] i_b,
	output [3:0] o_res,
	output o_borrow);

	wire [2:0] brw;
	
	mod_hsubber sub0(i_a[0], i_b[0], o_res[0], brw[0]);
	mod_sub1 sub1(i_a[1], i_b[1], brw[0], o_res[1], brw[1]);
	mod_sub1 sub2(i_a[2], i_b[2], brw[1], o_res[2], brw[2]);
	mod_sub1 sub3(i_a[3], i_b[3], brw[2], o_res[3], o_borrow);
endmodule



