// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : hdmi_buffer.v
// Create : 2019-10-05 14:28:19
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module hdmi_buffer(
		input	wire 				wrclk,
		input	wire 				hdmiclk,
		input	wire 				rst,
		output	wire 				rd_start,
		input	wire 				user_rd_end,
		input	wire 				rd_data_valid,
		input	wire 	[127:0]		rd_data,
		output	wire 				hdmi_rst_n,
		input	wire 				rd_fifo_en,
		output	wire 	[23:0]		rd_fifo_data
	);

parameter IDLE = 3'b001;
parameter JUDGE = 3'b010;
parameter RD  = 3'b100;

reg [2:0]	state;
reg 		rd_start_r;
wire 	[9:0]		wr_data_count;
wire 	[12:0]		rd_data_count;
reg 		hdmi_rst_n_r =1'b0;
wire 	[4:0] red,blue;
wire 	[5:0] green;
reg 	[7:0]	test_cnt;

assign rd_start = rd_start_r;
assign hdmi_rst_n = hdmi_rst_n_r;

always @(posedge wrclk) begin
	if (rst == 1'b1) begin
		state <= IDLE;
	end
	else 
	case (state)
		IDLE : begin
			state <= JUDGE;
		end
		JUDGE : begin
			if(wr_data_count<192) begin
				state <= RD;
			end
		end
		RD : begin
			if (user_rd_end == 1'b1) begin
				state <= JUDGE;
			end
		end
		default : state <= IDLE;
	endcase
end

always @(posedge wrclk) begin
	if (rst == 1'b1) begin
		rd_start_r <= 1'b0;
	end
	else if (state == JUDGE && wr_data_count < 192) begin
		rd_start_r <= 1'b1;
	end
	else begin
		rd_start_r <= 1'b0;
	end
end


asfifo_wr128x512_rd16x4096 hdmi_buffer_inst (
  .wr_clk(wrclk),                // input wire wr_clk
  .rd_clk(hdmiclk),                // input wire rd_clk
  .din(rd_data),                      // input wire [127 : 0] din
  .wr_en(rd_data_valid),                  // input wire wr_en
  .rd_en(rd_fifo_en),                  // input wire rd_en
  .dout({red,green,blue}),                    // output wire [15 : 0] dout
  .full(),                    // output wire full
  .empty(),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [12 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [9 : 0] wr_data_count
);

always @(posedge hdmiclk) begin
	if (rst == 1'b1) begin
		test_cnt <='d0;
	end
	else if (rd_fifo_en) begin
		test_cnt <= test_cnt + 1'b1;
	end
end

assign rd_fifo_data = {red,3'd0,green,2'd0,blue,3'd0};

always @(posedge hdmiclk) begin
	if (rst == 1'b1) begin
		hdmi_rst_n_r <= 1'b0;
	end
	else if (rd_data_count >= 1500) begin
		hdmi_rst_n_r <= 1'b1;
	end
end
/*
wire [31:0] probe0;

assign probe0 = {
	state,
	rst,
	hdmi_rst_n,
	wr_data_count,
	rd_start,
	rd_data_valid,
	rd_fifo_en
};

ila_0 ila_inst (
	.clk(wrclk), // input wire clk


	.probe0(probe0) // input wire [31:0] probe0
);*/
endmodule 