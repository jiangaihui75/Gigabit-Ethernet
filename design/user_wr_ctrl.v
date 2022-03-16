// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : user_wr_ctrl.v
// Create : 2019-10-04 19:36:29
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------


module user_wr_ctrl(
	input	wire 			sclk,
	input	wire 			rst,
	input	wire 			wr_en,
	input	wire 	[127:0]	wr_data,
	output	wire 			p2_wr_en,
	output	wire 	[127:0]	p2_wr_data,
	output	wire 	[15:0]	p2_wr_mask,
	output	wire 			p2_cmd_en,
	output	wire 	[6:0]	p2_cmd_bl,
	output	wire 	[2:0]	p2_cmd_instr,
	output	wire 	[27:0]	p2_cmd_addr,
	output	wire 			user_wr_end,
	input	wire 			p2_wr_empty
    );
//1024*768
//16bit /pexil
//1024*768 - 512 =785920 
parameter BURST_LEN =64;
parameter START_ADDR =0;
parameter STOP_ADDR =785920;
parameter ADDR_ADD = 64*128/16;

reg 		wr_en_r;
reg [127:0] wr_data_r;
reg 		wr_cmd_en_r;
reg [27:0]	wr_cmd_addr_r = START_ADDR;
reg 		wr_end_r;
reg 		wr_empty_r,wr_empty_rr,wr_empty_rrr;

assign p2_wr_data = wr_data_r;
assign p2_wr_en = wr_en_r;
assign p2_cmd_en = wr_cmd_en_r;
assign p2_wr_mask = 'd0;
assign p2_cmd_bl = BURST_LEN;
assign p2_cmd_instr = 3'd0;
assign p2_cmd_addr = wr_cmd_addr_r;
assign user_wr_end = wr_end_r;

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_en_r <= 1'b0;
		wr_data_r <= 'd0;
	end
	else begin
		wr_en_r <= wr_en;
		wr_data_r <= wr_data;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_cmd_en_r <= 1'b0;
	end
	else if (wr_en == 1'b0 && wr_en_r == 1'b1) begin
		wr_cmd_en_r <= 1'b1;
	end
	else begin
		wr_cmd_en_r <= 1'b0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_cmd_addr_r <=START_ADDR;
	end
	else if(wr_cmd_addr_r == STOP_ADDR && wr_cmd_en_r == 1'b1) begin
		wr_cmd_addr_r <= START_ADDR;
	end
	else if (wr_cmd_en_r == 1'b1) begin
		wr_cmd_addr_r <= wr_cmd_addr_r + ADDR_ADD;
	end
end

always @(posedge sclk) begin
	wr_empty_r <= p2_wr_empty;
	wr_empty_rr <= wr_empty_r;
	wr_empty_rrr <= wr_empty_rr;
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_end_r <= 1'b0;
	end
	else if (wr_empty_rr == 1'b1 && wr_empty_rrr == 1'b0) begin
		wr_end_r <= 1'b1;
	end
	else begin
		wr_end_r <= 1'b0;
	end
end

endmodule
