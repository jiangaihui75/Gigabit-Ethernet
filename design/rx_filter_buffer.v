// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : rx_filter_buffer.v
// Create : 2019-10-28 21:29:13
// Revise : 2019-10-29 17:26:38
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module rx_filter_buffer(
	input	wire 			sclk,
	input	wire 			rst,
	input	wire 			rx_en,
	input	wire 	[7:0]	rx_data,
	output	reg 			frx_en,
	output	reg 	[7:0]	frx_data,
	output	reg 	[15:0]	statuso
	);

wire 		rx_buffer_wr_en;
wire [7:0] rx_buffer_wr_data;
reg 		rx_buffer_rd_en;
wire  [7:0] rx_buffer_rd_data;
reg [13:0]	rx_buffer_rd_cnt;
wire 		rx_buf_full,rx_buf_empty;
reg [13:0]	rx_cnt;
reg [13:0]	rx_cnt_buf;
reg 		rx_en_t;
reg [3:0]	filter_cnt;
reg 		vld_pkg;
reg 		rx_en_new;
wire 		pkg_end;
wire 		crc32_error;
wire [15:0] pkg_status;
wire 		rx_sta_full,rx_sta_empty;
reg 		read_proc_flag;
reg 		read_sta_en;
wire  [15:0]	status;
reg  [15:0]		status_reg;


assign rx_buffer_wr_en = rx_en;
assign rx_buffer_wr_data = rx_data;

afifo_wr8x8192 rx_buffer (
  .wr_clk(sclk),  // input wire wr_clk
  .rd_clk(sclk),  // input wire rd_clk
  .din(rx_buffer_wr_data),        // input wire [7 : 0] din
  .wr_en(rx_buffer_wr_en),    // input wire wr_en
  .rd_en(rx_buffer_rd_en),    // input wire rd_en
  .dout(rx_buffer_rd_data),      // output wire [7 : 0] dout
  .full(rx_buf_full),      // output wire full
  .empty(rx_buf_empty)    // output wire empty
);
//rx_filter start

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rx_cnt <='d0;
	end
	else if (rx_en == 1'b1) begin
		rx_cnt <= rx_cnt + 1'b1;
	end
	else begin
		rx_cnt <='d0;
	end
end

always @(posedge sclk) begin
	rx_en_t <= rx_en;
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rx_cnt_buf <='d0;
	end
	else if (rx_en == 1'b0 && rx_en_t == 1'b1) begin
		rx_cnt_buf <=rx_cnt;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		filter_cnt <= 'd0;
	end
	else if (rx_en == 1'b1 && rx_cnt == 'd31 && rx_data == 8'h11) begin //udp
		filter_cnt <= filter_cnt + 1'b1;
	end
	else if (rx_en == 1'b1 && rx_cnt == 'd42 && rx_data == 8'h04) begin //source port
		filter_cnt <= filter_cnt + 1'b1;
	end
	else if (rx_en == 1'b1 && rx_cnt == 'd43 && rx_data == 8'hD2) begin
		filter_cnt <= filter_cnt + 1'b1;
	end
	else if (rx_en == 1'b1 && rx_cnt == 'd44 && rx_data == 8'h00) begin//dest port
		filter_cnt <= filter_cnt + 1'b1;
	end
	else if (rx_en == 1'b1 && rx_cnt == 'd45 && rx_data == 8'h7B) begin
		filter_cnt <= filter_cnt + 1'b1;
	end
	else if(rx_en == 1'b0) begin
		filter_cnt <= 'd0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		vld_pkg <= 1'b0;
	end
	else if (rx_en == 1'b0 && rx_en_t == 1'b1 && filter_cnt == 'd5) begin // 5 condition filters
		vld_pkg <= 1'b1;
	end
	else if(rx_en == 1'b0 && rx_en_t == 1'b1 && filter_cnt != 'd5) begin
		vld_pkg <= 1'b0;
	end
end

//******
always @(posedge sclk or negedge rx_en) begin
	if (rx_en == 1'b0) begin
		rx_en_new <= 1'b0;
	end
	else if (rx_cnt == 'd7) begin
		rx_en_new <= 1'b1;
	end
end

	crc32_d8_rec_02 inst_crc32_d8_rec_02
	(
		.resetb        (1'b1),
		.sclk          (sclk),
		.dsin          (rx_en_new),
		.din           (rx_data),
		.crc32_cal_end (pkg_end),
		.crc32_error   (crc32_error)
	);

assign pkg_status = {~crc32_error,vld_pkg,rx_cnt_buf};

afifo_wr16x64 rx_sta_buffer (
  .wr_clk(sclk),            // input wire wr_clk
  .rd_clk(sclk),            // input wire rd_clk
  .din(pkg_status),                  // input wire [15 : 0] din
  .wr_en(pkg_end),              // input wire wr_en
  .rd_en(read_sta_en),              // input wire rd_en
  .dout(status),                // output wire [15 : 0] dout
  .full(rx_sta_full),                // output wire full
  .empty(rx_sta_empty)              // output wire empty
);

always @(posedge sclk ) begin
	if (rst == 1'b1) begin
		read_proc_flag <= 1'b0;
	end
	else if((status_reg[13:0] - 1'b1) == rx_buffer_rd_cnt && rx_buffer_rd_en == 1'b1) begin
		read_proc_flag <= 1'b0;
	end
	else if (read_proc_flag == 1'b0 && rx_sta_empty == 1'b0) begin
		read_proc_flag <= 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		read_sta_en <= 1'b0;
	end
	else if(read_sta_en == 1'b1 && read_proc_flag == 1'b1) begin
		read_sta_en <= 1'b0;
	end
	else if (read_proc_flag == 1'b0 && rx_sta_empty == 1'b0 && read_sta_en == 1'b0) begin
		read_sta_en <= 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		status_reg <= 'd0;
	end
	else if (read_sta_en == 1'b1) begin
		status_reg <= status;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rx_buffer_rd_cnt <= 'd0;
	end
	else if (rx_buffer_rd_en == 1'b1) begin
		rx_buffer_rd_cnt <= rx_buffer_rd_cnt + 1'b1;
	end
	else begin
		rx_buffer_rd_cnt <='d0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rx_buffer_rd_en <= 1'b0;
	end
	else if((status_reg[13:0] - 1'b1) == rx_buffer_rd_cnt && rx_buffer_rd_en == 1'b1) begin
		rx_buffer_rd_en <= 1'b0;
	end
	else if (read_sta_en == 1'b1) begin
		rx_buffer_rd_en <= 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		frx_data <= 'd0;
		frx_en <= 'd0;
	end
	else if (rx_buffer_rd_en == 1'b1 && status_reg[15] == 1'b1 && status_reg[14] == 1'b1) begin
		frx_en <= 1'b1;
		frx_data <= rx_buffer_rd_data;
	end
	else begin
		frx_en <= 1'b0;
		frx_data <= 'd0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		statuso <='d0;
	end
	else begin
		statuso <= status_reg;
	end
end
/*
wire [63:0] probe0;
assign probe0 = {
	rx_en,
	rx_en_t,
	rx_data,
	read_proc_flag,
	rx_buf_empty,
	pkg_end,
	pkg_status,
	frx_en,
	frx_data,
	read_sta_en,
	rx_buffer_rd_en,
	status_reg
};
ila_0 ila_0_inst (
	.clk(sclk), // input wire clk
	.probe0(probe0) // input wire [31:0] probe0
);*/
//end rx filter

endmodule