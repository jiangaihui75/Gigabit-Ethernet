// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : iddr_ctrl.v
// Create : 2019-10-16 23:38:56
// Revise : 2019-10-16 23:52:48
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps
module iddr_ctrl(
	input	wire			rx_clk_90,
	input	wire 			rst,
	input	wire 	[3:0]	rx_dat,
	input	wire 			rx_ctrl,
	output	wire 			rx_en,
	output	wire 	[7:0]	rx_data
    );

wire	[7:0]	rxd;
wire 			rxdv,rxerr;
reg 			rxdv_r,rxerr_r;
reg 	[7:0]	rxd_r;

assign rx_en = rxdv_r;
assign  rx_data	=rxd_r ;

always @(posedge rx_clk_90) begin
	if (rst == 1'b1) begin
		rxdv_r <= 1'b0;
		rxerr_r <= 1'b0;
		rxd_r <= 'd0;
	end
	else begin
		rxdv_r <= rxdv;
		rxerr_r <= rxerr;
		rxd_r <= rxd;
	end
end

generate
	genvar i;
	for(i=0;i<4;i=i+1) begin
		IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                     //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_rxd_inst (
      .Q1(rxd[i]), // 1-bit output for positive edge of clock
      .Q2(rxd[i+4]), // 1-bit output for negative edge of clock
      .C(rx_clk_90),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rx_dat[i]),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
	end
endgenerate


	IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                     //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_rxctrl_inst (
      .Q1(rxdv), // 1-bit output for positive edge of clock
      .Q2(rxerr), // 1-bit output for negative edge of clock
      .C(rx_clk_90),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rx_ctrl),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
   
endmodule
