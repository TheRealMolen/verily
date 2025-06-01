`timescale 1ns / 1ps


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
	
	wire carry, borrow;
	
	wire[3:0] regA = i_switch[7:4];
	wire[3:0] regB = i_switch[3:0];
	
	mod_add4 adderAB(regA, regB, aplusb, carry);
	mod_sub4 subberAB(regA, regB, asubb, borrow);
		
	reg mem_sel, mem_rw;
	reg [4:0] mem_addr = 0;
	//reg [3:0] mem_wData = 0;
	wire [3:0] mem_rData;
	
	assign statC = mem_rData[0] ? carry : borrow;
	
	mod_mem mem(
		.i_clk(main_clk),
		.i_sel(mem_sel),
		.i_rw(mem_rw),
		.i_addr(mem_addr),
		.i_wData(0),
		.o_rData(mem_rData));
	
	reg[4:0] pc = 0;
	
	reg[24:0] clkDiv;
	assign main_clk = clkDiv[21];
	
	assign o_led[7] = mem_sel;
	assign o_led[6] = mem_rw;
	assign o_led[5] = pc[4];
	assign o_led[4] = statC;
	assign o_led[3:0] = mem_rData;
	
	wire[3:0] acc = mem_rData[0] ? aplusb : asubb;
	
	mod_4digitdisp disp(
		.i_clk(i_clk),
		.i_digit0(regA),
		.i_digit1(regB),
		.i_digit2(acc),
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
