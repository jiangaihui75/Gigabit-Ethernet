// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : top_hdmi.v
// Create : 2019-10-05 14:12:06
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module top_hdmi(
	input	wire 				wrclk,
	input	wire 				rst,
	input	wire 				locked,
	input	wire 				clk1x,
	input	wire 				clk5x,
	output	wire 				rd_start,
	input	wire 				user_rd_end,
	input	wire 				rd_data_valid,
	input	wire 	[127:0]		rd_data,
	output	wire 				hdmi_clk_p,
	output	wire 				hdmi_clk_n,
	output	wire 				hdmi_d0_p,
	output	wire 				hdmi_d0_n,
	output	wire 				hdmi_d1_p,
	output	wire 				hdmi_d1_n,
	output	wire 				hdmi_d2_p,
	output	wire 				hdmi_d2_n

	);

wire hdmi_rst_n;
wire rd_fifo_en;
wire [23:0] rd_fifo_data;
wire	[7:0]	po_vga_r;
wire	[7:0]	po_vga_g;
wire	[7:0]	po_vga_b;
wire		po_de;
wire		po_v_sync;
wire		po_h_sync;

	hdmi_buffer  inst_hdmi_buffer (
			.wrclk         (wrclk),
			.hdmiclk       (clk1x),
			.rst           (rst),
			.rd_start      (rd_start),
			.user_rd_end   (user_rd_end),
			.rd_data_valid (rd_data_valid),
			.rd_data       (rd_data),
			.hdmi_rst_n    (hdmi_rst_n),
			.rd_fifo_en    (rd_fifo_en),
			.rd_fifo_data  (rd_fifo_data)
		);



	VGA_TIMING  inst_VGA_TIMING (
			.sclk       (clk1x),
			.rst_n      (hdmi_rst_n),
			.po_vga_r   (po_vga_r),
			.po_vga_g   (po_vga_g),
			.po_vga_b   (po_vga_b),
			.po_de      (po_de),
			.po_v_sync  (po_v_sync),
			.po_h_sync  (po_h_sync),
			.rgb_pixel  (rd_fifo_data),
			.rd_fifo_en (rd_fifo_en)
		);



	hdmi_trans inst_hdmi_trans
		(
			.clk1x       (clk1x),
			.clk5x       (clk5x),
			.rst         (~hdmi_rst_n),
			.locked      (locked),
			.vga_r       (po_vga_r),
			.vga_g       (po_vga_g),
			.vga_b       (po_vga_b),
			.de          (po_de),
			.v_sync      (po_v_sync),
			.h_sync      (po_h_sync),
			.hdmi_clk_p  (hdmi_clk_p),
			.hdmi_clk_n  (hdmi_clk_n),
			.hdmi_chn0_p (hdmi_d0_p),
			.hdmi_chn0_n (hdmi_d0_n),
			.hdmi_chn1_p (hdmi_d1_p),
			.hdmi_chn1_n (hdmi_d1_n),
			.hdmi_chn2_p (hdmi_d2_p),
			.hdmi_chn2_n (hdmi_d2_n)
		);

endmodule