`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/15 14:51:09
// Design Name: 
// Module Name: gen_frame_ctrl
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


module gen_frame_ctrl(
	input	wire			tx_clk,
	input	wire			rst,
	input	wire			timer_pulse,
	output	reg 			tx_en,
	output	reg 	[7:0]	tx_data
    );
	parameter 	PKG_END = 113;

parameter	MAC_D5 =8'hff;
parameter	MAC_D4 =8'hff;
parameter	MAC_D3 =8'hff;
parameter	MAC_D2 =8'hff;
parameter	MAC_D1 =8'hff;
parameter	MAC_D0 =8'hff;

parameter	MAC_S5 =8'hA8;
parameter	MAC_S4 =8'hBB;
parameter	MAC_S3 =8'hC8;
parameter	MAC_S2 =8'h07;
parameter	MAC_S1 =8'hD9;
parameter	MAC_S0 =8'h9F;

parameter	IP_S3 = 8'd192;
parameter	IP_S2 = 8'd168;
parameter	IP_S1 = 8'd0;
parameter	IP_S0 = 8'd1;

parameter	IP_D3 = 8'd255;
parameter	IP_D2 = 8'd255;
parameter	IP_D1 = 8'd255;
parameter	IP_D0 = 8'd255;

parameter	PORT_S1 = 8'h04;
parameter	PORT_S0 = 8'hd2;

parameter	PORT_D1 = 8'h00;
parameter	PORT_D0 = 8'h7B;

reg 		gen_frame_flag;
reg [7:0]	gen_frame_cnt;

always @(posedge tx_clk) begin
	if (rst == 1'b1) begin
		gen_frame_flag <= 1'b0;
	end
	else if (gen_frame_cnt == PKG_END) begin
		gen_frame_flag <= 1'b0;
	end
	else if (timer_pulse == 1'b1) begin
		gen_frame_flag <= 1'b1;
	end
end

always @(posedge tx_clk) begin
	if(rst == 1'b1) begin
		gen_frame_cnt <='d0;
	end
	else if(gen_frame_flag == 1'b1) begin
		gen_frame_cnt <= gen_frame_cnt + 1'b1;
	end
	else begin
		gen_frame_cnt <='d0;
	end
end

always @(posedge tx_clk) begin
	if (rst == 1'b1) begin
		tx_data <='d0;
	end
	else if (gen_frame_flag == 1'b1) begin
		case(gen_frame_cnt) 
		0,1,2,3,4,5,6 			:tx_data <= 8'h55;
		7						:tx_data <= 8'hd5;
		8						:tx_data <= MAC_D5;
		9						:tx_data <= MAC_D4;
		10						:tx_data <= MAC_D3;
		11						:tx_data <= MAC_D2;
		12						:tx_data <= MAC_D1;
		13						:tx_data <= MAC_D0;
		14						:tx_data <= MAC_S5;
		15						:tx_data <= MAC_S4;
		16						:tx_data <= MAC_S3;
		17						:tx_data <= MAC_S2;
		18						:tx_data <= MAC_S1;
		19						:tx_data <= MAC_S0;
		20						:tx_data <= 8'h08;
		21						:tx_data <= 8'h00;
		22						:tx_data <= 8'h45;
		23						:tx_data <= 8'h00;
		24						:tx_data <= 8'h00;
		25						:tx_data <= 8'h5c;
		26						:tx_data <= 8'h00;
		27						:tx_data <= 8'h00;		
		28						:tx_data <= 8'h00;
		29						:tx_data <= 8'h00;
		30						:tx_data <= 8'h80;
		31						:tx_data <= 8'h11;		
		32						:tx_data <= 8'h00;
		33						:tx_data <= 8'h00;
		34						:tx_data <= IP_S3;
		35						:tx_data <= IP_S2;
		36						:tx_data <= IP_S1;
		37						:tx_data <= IP_S0;
		38						:tx_data <= IP_D3;
		39						:tx_data <= IP_D2;
		40						:tx_data <= IP_D1;
		41						:tx_data <= IP_D0;
		42						:tx_data <= PORT_S1;
		43						:tx_data <= PORT_S0;
		44						:tx_data <= PORT_D1;
		45						:tx_data <= PORT_D0;
		46						:tx_data <= 8'h00;
		47						:tx_data <= 8'h48;
		default : tx_data <= 8'd0;
		endcase
	end
end


always @(posedge tx_clk) begin
	if (rst == 1'b1) begin
		tx_en <= 1'b0;
	end
	else begin
		tx_en <= gen_frame_flag;
	end
end
endmodule
