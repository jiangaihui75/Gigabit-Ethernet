// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : a7_ddr3_wr_ctrl.v
// Create : 2019-09-10 16:28:29
// Revise : 2019-09-16 11:50:41
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module a7_ddr3_wr_ctrl(
	input	wire 			sclk,
	input	wire 			rst,
	//user write ports
	input	wire 			wr_cmd_start,
	input	wire 	[2:0]	wr_cmd_instr,
	input	wire 	[6:0]	wr_cmd_bl,
	input	wire 	[27:0]	wr_cmd_addr,
	input	wire 	[127:0]	data_128bit,
	input	wire 	[15:0]	wr_cmd_mask,
	output	wire 			data_req,
	output	wire 			wr_end,
	//ddr3 ipcore ports
	output	wire 			app_wdf_wren,
	output	wire 	[127:0]	app_wdf_data,
	input	wire 			app_wdf_rdy,
	output	wire 			app_en,
	input	wire 			app_rdy,
	output	wire 	[27:0]	app_addr,
	output	wire 	[2:0]	app_cmd

    );
	reg [2:0]	cmd_instr;
	reg [6:0]	cmd_bl;
	reg [27:0]	cmd_addr;
	reg [15:0]	cmd_mask;
	reg 		wdf_wren;
	reg [7:0]	data_cnt;
	reg 		app_en_r;
	reg [7:0]	cmd_cnt;
	reg 		wr_end_r;

	assign wr_end = wr_end_r;
	assign app_wdf_wren = wdf_wren;
	assign app_en = app_en_r;
	assign app_addr = cmd_addr;
	assign app_cmd = cmd_instr;


	always @(posedge sclk) begin
		if(rst == 1'b1) begin
			cmd_instr <= 'd0;
			cmd_bl <= 'd0;
			cmd_mask <= 'd0;
		end
		else if(wr_cmd_start == 1'b1) begin
			cmd_instr <= wr_cmd_instr;
			cmd_bl <= wr_cmd_bl;
			cmd_mask <= wr_cmd_mask;
		end
	end

	always @(posedge sclk) begin
		if (rst == 1'b1) begin
			wdf_wren <= 1'b0;
		end
		else if (wdf_wren == 1'b1 && data_cnt == (cmd_bl-1) && app_wdf_rdy == 1'b1) begin
			wdf_wren <= 1'b0;
		end
		else if (wr_cmd_start == 1'b1) begin
			wdf_wren <= 1'b1;
		end
	end

	always @(posedge sclk) begin
		if (rst == 1'b1) begin
			data_cnt <= 'd0;
		end
		else if (data_cnt ==  (cmd_bl-1) && data_req == 1'b1) begin
			data_cnt <= 'd0;
		end
		else if (data_req == 1'b1) begin
			data_cnt <= data_cnt + 1'b1;
		end
	end

	assign data_req = wdf_wren & app_wdf_rdy;
	assign app_wdf_data = data_128bit;

	always @(posedge sclk) begin
		if (rst == 1'b1) begin
			app_en_r <= 1'b0;
		end
		else if (app_en_r == 1'b1 && app_rdy == 1'b1 && cmd_cnt == (cmd_bl-1)) begin
			app_en_r <= 1'b0;
		end
		else if (data_req == 1'b1) begin
			app_en_r <= 1'b1;
		end
	end

	always @(posedge sclk) begin
		if (rst == 1'b1) begin
			cmd_cnt <='d0;
		end
		else if (cmd_cnt ==  (cmd_bl-1) && app_rdy == 1'b1 && app_en_r == 1'b1)begin
			 cmd_cnt <= 'd0;
		end
		else if (app_en_r == 1'b1 && app_rdy == 1'b1) begin
			cmd_cnt <= cmd_cnt + 1'b1;
		end
	end

	always @(posedge sclk) begin
		if (rst == 1'b1) begin
			cmd_addr <= 'd0;
		end
		else if(wr_end_r) begin
			cmd_addr <= 'd0;
		end
		else if (app_rdy == 1'b1 && app_en_r == 1'b1) begin
			cmd_addr <= cmd_addr + 'd8;
		end
		else if (wr_cmd_start == 1'b1) begin
			cmd_addr <= wr_cmd_addr;
		end
	end
always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_end_r <='d0;
	end
	else if (cmd_cnt ==  (cmd_bl-1) && app_rdy == 1'b1 && app_en_r == 1'b1) begin
		wr_end_r <=1'b1;
	end
	else begin
		wr_end_r <= 1'b0;
	end
end

endmodule
