`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/15 15:04:06
// Design Name: 
// Module Name: tb_gige_tx
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


module tb_gige_tx(

    );

	reg srst;
	reg clk;
	wire	tx_c_90,tx_dv;
	wire	[3:0]	tx_d;
	// clock
	initial begin
		clk = 0;
		forever #(4) clk = ~clk;
	end

	// reset
	initial begin
		srst <= 1;
		repeat (15) @(posedge clk);
		srst <= 0;
	end


	top_gige #(.SIM_FLAG(1)) inst_top_gige (.tx_clk(clk), .rst(srst),.tx_c_90(tx_c_90),.tx_d(tx_d),.tx_dv(tx_dv));
endmodule
