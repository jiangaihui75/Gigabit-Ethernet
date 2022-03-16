// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : bit8to128.v
// Create : 2019-10-06 16:35:47
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module bit8to128(
	input	wire 				sclk,
	input	wire 				rst,
	input	wire 				rx_flag,
	input	wire 		[7:0]	rx_data,
	output	wire 				wr_en,
	output	wire 		[127:0]	wr_data
	);
parameter BURST_LEN =64;
reg [15:0]	shift_reg;
reg 		rx_cnt=0;
reg 		wr_fifo_en;
wire [15:0]	wr_fifo_data;
wire [7:0]	rd_data_count;
reg 		rd_en;
reg  [7:0]	rd_cnt;

assign wr_fifo_data = shift_reg;

always @(posedge sclk) begin
	if (rx_flag == 1'b1) begin
		shift_reg <= {shift_reg[7:0],rx_data};
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rx_cnt <= 1'b0;
	end
	else if (rx_flag == 1'b1) begin
		rx_cnt <= rx_cnt + 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_fifo_en <= 1'b0;
	end
	else if (rx_cnt == 1'b1 && rx_flag == 1'b1) begin
		wr_fifo_en <= 1'b1;
	end
	else begin
		wr_fifo_en <= 1'b0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_en <= 1'b0;
	end
	else if (rd_cnt == BURST_LEN-1) begin
		rd_en <= 1'b0;
	end
	else if (rd_data_count>=BURST_LEN) begin
		rd_en <= 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_cnt <= 'd0;
	end
	else if (rd_cnt == BURST_LEN-1 && rd_en == 1'b1) begin
		rd_cnt <= 'd0;
	end
	else if (rd_en == 1'b1) begin
		rd_cnt <= rd_cnt + 1'b1;
	end
end

assign wr_en = rd_en;

fifo_wr16x1024_rd128x128 uart_buffer_inst (
  .clk(sclk),                      // input wire clk
  .din(wr_fifo_data),                      // input wire [15 : 0] din
  .wr_en(wr_fifo_en),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(wr_data),                    // output wire [127 : 0] dout
  .full(),                    // output wire full
  .empty(),                  // output wire empty
  .rd_data_count(rd_data_count)  // output wire [7 : 0] rd_data_count
);

endmodule