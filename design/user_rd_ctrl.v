// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : user_rd_ctrl.v
// Create : 2019-10-04 20:25:49
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------


module user_rd_ctrl(
	input	wire 				sclk,
	input	wire 				rst,
	input	wire 				rd_start,
	output	wire 				p1_cmd_en,
	output	wire 		[6:0]	p1_cmd_bl,
	output	wire 		[2:0]	p1_cmd_instr,
	output	wire 		[27:0]	p1_cmd_addr,
	input	wire 		[6:0]	p1_rd_count,
	output	wire 				p1_rd_en,
	output	wire 				user_rd_end
    );
//1024*768
//16bit /pexil
//1024*768 - 512 =785920 
parameter BURST_LEN =64;
parameter START_ADDR =0;
parameter STOP_ADDR = 785920;
parameter ADDR_ADD = 64*128/16;

reg 	cmd_en_r;
reg [27:0]	rd_cmd_addr_r = START_ADDR;
reg 	rd_en_r;
reg [7:0]	data_cnt;
reg 	rd_end_r;

assign p1_cmd_en = cmd_en_r;
assign p1_cmd_bl = BURST_LEN;
assign p1_cmd_instr = 3'd1;
assign p1_cmd_addr  = rd_cmd_addr_r;
assign p1_rd_en = rd_en_r;
assign user_rd_end = rd_end_r;

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		cmd_en_r <= 1'b0;
	end
	else if (rd_start == 1'b1) begin
		cmd_en_r <= 1'b1;
	end
	else begin
		cmd_en_r <= 1'b0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_cmd_addr_r <= START_ADDR;
	end
	else if(rd_cmd_addr_r == STOP_ADDR && cmd_en_r == 1'b1) begin
		rd_cmd_addr_r <= START_ADDR;
	end
	else if (cmd_en_r == 1'b1) begin
		rd_cmd_addr_r <= rd_cmd_addr_r + ADDR_ADD;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_en_r <= 1'b0;
	end
	else if(data_cnt == BURST_LEN-1) begin
		rd_en_r <= 1'b0;
	end
	else if (p1_rd_count == BURST_LEN) begin
		rd_en_r <= 1'b1;
	end
end

always @(posedge sclk ) begin
	if (rst == 1'b1) begin
		
	end
	else if (rd_en_r == 1'b1 && data_cnt == BURST_LEN-1) begin
		data_cnt <= 'd0;
	end
	else if(rd_en_r == 1'b1) begin
		data_cnt <= data_cnt + 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_end_r <= 1'b0;
	end
	else if (rd_en_r == 1'b1 && data_cnt == BURST_LEN-1) begin
		rd_end_r <= 1'b1;
	end
	else begin
		rd_end_r <= 1'b0;
	end
end

endmodule
