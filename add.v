`timescale 1ns / 1ps

/*
module mod_adder (
	input [1:0] i_a,
	input [1:0] i_b,
	output [3:0] o_sum);
	
	assign o_sum[0] = i_a[0] ^ i_b[0];
	assign o_sum[1] = (i_a[0] & i_b[0]) ^ (i_a[1] ^ i_b[1]);
	assign o_sum[2] = ((i_a[0] & i_b[0]) & (i_a[1] | i_b[1])) | (i_a[1] & i_b[1]);
	assign o_sum[3] = 0;
endmodule
*/

module mod_hadder (
	input i_a,
	input i_b,
	output o_res,
	output o_carry);
	
	assign o_res = i_a ^ i_b;
	assign o_carry = i_a & i_b;
endmodule


module mod_add1 (
	input i_a,
	input i_b,
	input i_carry,
	output o_res,
	output o_carry);
	
	wire sum = i_a ^ i_b;
	assign o_res = sum ^ i_carry;
	assign o_carry = (i_a & i_b) | (i_a & i_carry) | (i_b & i_carry);
endmodule


module mod_add4 (
	input [3:0] i_a,
	input [3:0] i_b,
	output [3:0] o_res,
	output o_carry);
	
	wire [2:0] car;
	
	mod_hadder add0(i_a[0], i_b[0], o_res[0], car[0]);
	mod_add1 add1(i_a[1], i_b[1], car[0], o_res[1], car[1]);
	mod_add1 add2(i_a[2], i_b[2], car[1], o_res[2], car[2]);
	mod_add1 add3(i_a[3], i_b[3], car[2], o_res[3], o_carry);
endmodule
