`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/15 14:41:23
// Design Name: 
// Module Name: timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module timer#(
	parameter SIM_FLAG = 0 
)
	(
		input	wire		tx_clk,//125M
		input	wire		rst,
		output	wire		timer_pulse		
    );
	parameter ONE_S = 124_999_999;//一秒计数器
	parameter SIM_V = 1023;
	
	reg [26:0]		time_cnt;
	reg				timer_pulse_r;
	assign 	timer_pulse = timer_pulse_r;
//time_cnt	
	always@(posedge tx_clk)begin
		if(rst)
			time_cnt <= 'd0;
		else if(SIM_FLAG == 1'b0)begin
			if(time_cnt == ONE_S)
				time_cnt <= 'd0;
			else 
				time_cnt <= time_cnt + 1'b1;
		end
		else begin
			if(time_cnt == SIM_V)
				time_cnt <= 'd0;
			else 
				time_cnt <= time_cnt + 1'b1;
		end
	end
//timer_pulse_r
		always@(posedge tx_clk)begin
		if(rst)
			timer_pulse_r <= 1'b0;
		else if(SIM_FLAG == 1'b0)begin
			if(time_cnt == ONE_S)
				timer_pulse_r <= 1'b1;
			else 
				timer_pulse_r <= 1'b0;
		end
		else begin
			if(time_cnt == SIM_V)
				timer_pulse_r <= 1'b1;
			else 
				timer_pulse_r <= 1'b0;
		end
	end
endmodule
