// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : hdmi_trans.v
// Create : 2019-07-26 21:29:17
// Revise : 2019-07-26 22:06:25
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module hdmi_trans(
	input	wire 		clk1x,
	input	wire 		clk5x,
	input	wire 		rst,
	input	wire 		locked,
	input	wire[7:0]	vga_r,
	input	wire[7:0]	vga_g,
	input	wire[7:0]	vga_b,
	input	wire		de,
	input	wire		v_sync,
	input	wire		h_sync,
	output	wire 		hdmi_clk_p,
	output	wire 		hdmi_clk_n,
	output	wire 		hdmi_chn0_p,
	output	wire 		hdmi_chn0_n,
	output	wire 		hdmi_chn1_p,
	output	wire 		hdmi_chn1_n,
	output	wire 		hdmi_chn2_p,
	output	wire 		hdmi_chn2_n
	);

wire sysrst;
wire [9:0]	dored,dogreen,doblue;
assign sysrst = rst | (~locked);
	encode inst_encode_red (
			.clkin (clk1x),
			.rstin (sysrst),
			.din   (vga_r),
			.c0    (1'b0),
			.c1    (1'b0),
			.de    (de),
			.dout  (dored)
		);
	encode inst_encode_green (
			.clkin (clk1x),
			.rstin (sysrst),
			.din   (vga_g),
			.c0    (1'b0),
			.c1    (1'b0),
			.de    (de),
			.dout  (dogreen)
		);
	encode inst_encode_blue (
			.clkin (clk1x),
			.rstin (sysrst),
			.din   (vga_b),
			.c0    (h_sync),
			.c1    (v_sync),
			.de    (de),
			.dout  (doblue)
		);


	Serializer10_1 inst_Serializer10_1_clk
		(
			.divclk (clk1x),
			.serclk (clk5x),
			.rst    (sysrst),
			.din    (10'b1111_0000),
			.do_p   (hdmi_clk_p),
			.do_n   (hdmi_clk_n)
		);

	Serializer10_1 inst_Serializer10_1_red
		(
			.divclk (clk1x),
			.serclk (clk5x),
			.rst    (sysrst),
			.din    (dored),
			.do_p   (hdmi_chn2_p),
			.do_n   (hdmi_chn2_n)
		);

	Serializer10_1 inst_Serializer10_1_green
		(
			.divclk (clk1x),
			.serclk (clk5x),
			.rst    (sysrst),
			.din    (dogreen),
			.do_p   (hdmi_chn1_p),
			.do_n   (hdmi_chn1_n)
		);

	Serializer10_1 inst_Serializer10_1_blue
		(
			.divclk (clk1x),
			.serclk (clk5x),
			.rst    (sysrst),
			.din    (doblue),
			.do_p   (hdmi_chn0_p),
			.do_n   (hdmi_chn0_n)
		);

endmodule 