// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : arbit.v
// Create : 2019-09-16 11:20:30
// Revise : 2019-09-16 12:38:26
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps
module arbit(
		input	wire 	sclk,
		input	wire 	rst,
		input	wire 	rd_req,
		input	wire 	wr_req,
		input	wire 	rd_end,
		input	wire 	wr_end,
		output	wire	rd_cmd_start,
		output	wire 	wr_cmd_start 
    );
parameter IDLE 	= 4'b0001;
parameter ARBIT = 4'b0010;
parameter WR 	= 4'b0100;
parameter RD 	= 4'b1000;

reg [3:0]	state;
reg 		wr_flag,rd_flag;
reg 		wr_start,rd_start;

assign  wr_cmd_start = wr_start;
assign  rd_cmd_start = rd_start;

always @(posedge sclk) begin
	if(rst == 1'b1)  begin
		state <= IDLE;
	end
	else begin
		case (state)
			IDLE : begin
				state <= ARBIT;
			end
			ARBIT: begin
				if(wr_req == 1'b1) begin
					state <= WR;
				end
				else if (rd_req == 1'b1) begin
					state <= RD;
				end
			end
			WR : begin
				if(wr_end == 1'b1) begin
					state <= ARBIT;
				end
			end
			RD : begin
				if(rd_end == 1'b1) begin
					state <= ARBIT;
				end
			end
			default : state <= IDLE;
		endcase
	end
end


always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_flag <= 1'b0;
	end
	else if(state == WR )begin//&& wr_flag == 1'b1 ) begin
		wr_flag <= 1'b0;
	end
	else if (wr_req == 1'b1) begin
		wr_flag <= 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		wr_start <= 1'b0;
	end
	else if (state == WR && wr_flag == 1'b1) begin
		wr_start <= 1'b1;
	end
	else begin
		wr_start <= 1'b0;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_flag <= 1'b0;
	end
	else if (state == RD )begin//&& rd_flag == 1'b1) begin
		rd_flag <= 1'b0;
	end
	else if (rd_req == 1'b1) begin
		rd_flag <= 1'b1;
	end
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		rd_start <= 1'b0;
	end
	else if (state == RD && rd_flag == 1'b1) begin
		rd_start <= 1'b1;
	end
	else begin
		rd_start <= 1'b0;
	end
end



endmodule
