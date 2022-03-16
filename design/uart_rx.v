// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : uart_rx.v
// Create : 2019-03-28 10:32:23
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module uart_rx(
	input	wire 				sclk,
	input	wire 				rst_n,
	input	wire 				rx,
	output	reg 	[7:0]		po_data,
	output	reg 				po_flag
	);

parameter 	CNT_BAUD_MAX = 867;//5207;
parameter	CNT_HALF_BAUD_MAX = 432;//2603;
reg 			rx1,rx2,rx2_reg;
reg 			rx_flag;
reg 	[12:0]	cnt_baud;
reg 			bit_flag;
reg 	[3:0]	bit_cnt;

always @(posedge sclk) begin
	{rx2_reg,rx2,rx1}<={rx2,rx1,rx};
end


always @(posedge sclk or negedge  rst_n) begin
	if (rst_n == 1'b0) begin
		rx_flag <= 1'b0;
	end
	else if (bit_cnt == 4'd8 && bit_flag == 1'b1) begin
		rx_flag <= 1'b0;
	end
	else if (rx2_reg == 1'b1 && rx2 == 1'b0) begin
		rx_flag <= 1'b1;
	end
end

always @(posedge sclk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt_baud <= 'd0;
	end
	else if (rx_flag == 1'b0) begin
		cnt_baud <= 'd0;
	end
	else if (rx_flag == 1'b1 && cnt_baud == CNT_BAUD_MAX) begin
		cnt_baud <= 'd0;
	end
	else if (rx_flag == 1'b1) begin
		cnt_baud <= cnt_baud + 1'b1;
	end
end

always @(posedge sclk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		bit_flag <= 1'b0;
	end
	else if (rx_flag == 1'b1 && cnt_baud == CNT_HALF_BAUD_MAX) begin
		bit_flag <= 1'b1;
	end
	else begin
		bit_flag <= 1'b0;
	end
end

always @(posedge sclk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		bit_cnt <= 'd0;
	end
	else if (bit_flag == 1'b1 && bit_cnt == 'd8) begin
		bit_cnt <= 'd0;
	end
	else if (bit_flag == 1'b1) begin
		bit_cnt <= bit_cnt + 1'b1;
	end
end

always @(posedge sclk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		po_data <='d0;
	end
	else if (bit_cnt >= 4'd1 && bit_flag == 1'b1) begin
		po_data <= {rx2_reg,po_data[7:1]};
	end
end

always @(posedge sclk or negedge rst_n) begin
	if (rst_n == 1'b0) begin	
		po_flag <= 1'b0;
	end
	else if (bit_cnt == 4'd8 && bit_flag == 1'b1) begin
		po_flag <= 1'b1;
	end
	else begin
		po_flag <= 1'b0;
	end
end



endmodule 