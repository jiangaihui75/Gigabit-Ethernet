`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/15 18:14:14
// Design Name: 
// Module Name: checksum_ctrl
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


module checksum_ctrl(
	input 	wire		tx_clk,
	input	wire		rst,
	input	wire[7:0]	tx_gen_data,
	input	wire		tx_data_en,
	output	wire[7:0]	tx_data,
	output	wire		tx_en,
	output	wire		pre_flag
    );
parameter IP_S_HEAD = 'hc0a8+'h0001+'hffff+'h0011+'h0048;
//Ip_checksum
reg			tx_data_en_dly;		//tx_data_en 打一拍
reg	[7:0]	tx_gen_data_dly;	//tx_gen_data 打一拍
reg	[11:0]	data_cnt;			//对tx_data_en_dly进行计数
reg			shift_ip_en;		//需要进行	Ip_checksum 的部分
reg	[15:0]	shift_ip_data;		//合并16位
reg			shift_ip_en_dly;
reg			shift_ip_flag;
reg	[31:0]	ip_sum;
reg	[15:0]	ip_checksum;
reg			ip_checksum_flag;	
//UDP_checksum
reg			shift_udp_en;
reg	[15:0]	shift_udp_data;	
reg			shift_udp_en_dly;
reg			shift_udp_flag;
reg	[31:0]	udp_sum;
reg			tx_end_flag;
reg	[15:0]		udp_checksum;
	
//ram
reg				rd_en;
reg		[11:0]	rd_addr;
wire	[7:0]	rd_data;
reg		[7:0]	po_checksum_data;
reg				rd_en_r;
reg				po_checksum_en;	
reg				pre_flag_r;
assign  pre_flag = pre_flag_r;
assign	tx_en = po_checksum_en;
assign	tx_data = po_checksum_data;
//	Ip_checksum

	always@(posedge tx_clk)begin
		tx_data_en_dly <= tx_data_en;
	end
	
	always@(posedge tx_clk)begin
		tx_gen_data_dly <= tx_gen_data;
	end
	//data_cnt
	always@(posedge tx_clk)begin
		if(rst)
			data_cnt <= 'd0;
		else if(tx_data_en_dly == 1'b1)
			data_cnt <= data_cnt +1'b1;
		else
			data_cnt <= 'd0;
	end
	//shift_ip_en
	always@(posedge tx_clk)begin
		if(rst)
			shift_ip_en <= 1'b0;
		else if(data_cnt == 'd41)
			shift_ip_en <= 1'b0;
		else if(data_cnt == 'd21)
			shift_ip_en <= 1'b1;
		else
			shift_ip_en <= shift_ip_en;
	end
	//shift_ip_data
	always@(posedge tx_clk)begin
		if(rst)
			shift_ip_data <= 'd0;
		else if(shift_ip_en == 1'b1)
			shift_ip_data <= {shift_ip_data[7:0],tx_gen_data_dly};
		else if(shift_ip_en == 1'b0)
			shift_ip_data <= 'd0;
	end
	//shift_ip_en_dly
	always@(posedge tx_clk)begin
		if(rst)
			shift_ip_en_dly <= 1'b0;
		else 
			shift_ip_en_dly <= shift_ip_en;
	end
	//shift_ip_flag
	always@(posedge tx_clk)begin
		if(rst)
			shift_ip_flag <= 1'b0;
		else if(shift_ip_en_dly == 1'b1)begin
			if(data_cnt[0] == 1'b1)
				shift_ip_flag <= 1'b1;
			else 
				shift_ip_flag <= 1'b0;
		end
		else 
			shift_ip_flag <= 1'b0;
	end
	//ip_sum
	always@(posedge tx_clk)begin
		if(rst)
			ip_sum <= 'd0;
		else if(shift_ip_flag == 1'b1)
			ip_sum <= ip_sum +shift_ip_data;
		else if(ip_checksum_flag == 1'b1)
			ip_sum <= 'd0;
		else
			ip_sum <= ip_sum;
	end
	//ip_checksum_flag
	always@(posedge tx_clk)begin
		if(rst)
			ip_checksum_flag <= 'd0;
		else if(shift_ip_en_dly == 1'b1 & shift_ip_en == 1'b0)
			ip_checksum_flag <= 1'b1;
		else
			ip_checksum_flag <= 1'b0;
	end
	//ip_checksum
	always@(posedge tx_clk)begin
		if(rst)
			ip_checksum <= 1'b0;
		else if(ip_checksum_flag == 1'b1)
			ip_checksum <= ip_sum[31:16]+ip_sum[15:0];
	end

//udp_checksum
	//shift_udp_en
	always@(posedge tx_clk)begin
		if(rst)
			shift_udp_en <= 1'b0;
		else if(data_cnt == 'd113)
			shift_udp_en <= 1'b0;
		else if(data_cnt == 'd41)
			shift_udp_en <= 1'b1;
		else
			shift_udp_en <= shift_udp_en;
	end
	//shift_udp_data
	always@(posedge tx_clk)begin
		if(rst)
			shift_udp_data <= 'd0;
		else if(shift_udp_en == 1'b1)
			shift_udp_data <= {shift_udp_data[7:0],tx_gen_data_dly};
		else if(shift_udp_en == 1'b0)
			shift_udp_data <= 'd0;
	end
	//shift_udp_en_dly
	always@(posedge tx_clk)begin
		if(rst)
			shift_udp_en_dly <= 1'b0;
		else 
			shift_udp_en_dly <= shift_udp_en;
	end	
	//shift_udp_flag
	always@(posedge tx_clk)begin
		if(rst)
			shift_udp_flag <= 1'b0;
		else if(shift_udp_en_dly == 1'b1)begin
			if(data_cnt[0] == 1'b1)
				shift_udp_flag <= 1'b1;
			else 
				shift_udp_flag <= 1'b0;
		end
		else 
			shift_udp_flag <= 1'b0;
	end
	//udp_sum
	always@(posedge tx_clk)begin
		if(rst)
			udp_sum <= 'd0;
		else if(shift_udp_en == 1'b1 && shift_udp_en_dly == 1'b0)
			udp_sum <= IP_S_HEAD;
		else if(shift_udp_flag == 1'b1)
			udp_sum <= udp_sum +shift_udp_data;
	end	
	//tx_end_flag
	always@(posedge tx_clk)begin
		if(rst)
			tx_end_flag <= 'd0;
		else if(shift_udp_en_dly == 1'b1 & shift_udp_en == 1'b0)
			tx_end_flag <= 1'b1;
		else
			tx_end_flag <= 1'b0;
	end
	//udp_checksum
	always@(posedge tx_clk)begin
		if(rst)
			udp_checksum <= 1'b0;
		else if(tx_end_flag == 1'b1)
			udp_checksum <= udp_sum[31:16]+udp_sum[15:0];
	end
//ram
	//rd_en
	always@(posedge tx_clk)begin
		if(rst)
			rd_en <= 1'b0;
		else if(tx_end_flag == 1'b1)
			rd_en <= 1'b1;
		else if(rd_en==1'b1 & rd_addr == 'd113)
			rd_en <= 1'b0;
	end
	//rd_en_r,po_checksum_en
	always@(posedge tx_clk)begin
		rd_en_r <= rd_en;
		po_checksum_en <= rd_en_r;
	end
	//rd_addr
	always@(posedge tx_clk)begin
		if(rst)
			rd_addr <= 'd0;
		else if(rd_en == 1'b1)
			rd_addr <= rd_addr +1'b1;
		else 
			rd_addr <= 'd0;
	end	
	
	always@(posedge tx_clk)begin
		if(rst)
			po_checksum_data <= 'd0;
		else if(rd_en == 1'b1 & rd_addr == 'd33)
			po_checksum_data <= ~ip_checksum[15:8];
		else if(rd_en == 1'b1 & rd_addr == 'd34)
			po_checksum_data <= ~ip_checksum[7:0];
		else if(rd_en == 1'b1 & rd_addr == 'd49)
			po_checksum_data <= ~udp_checksum[15:8];
		else if(rd_en == 1'b1 & rd_addr == 'd50)
			po_checksum_data <= ~udp_checksum[7:0];
		else	
			po_checksum_data <= rd_data;
	end	
	
	//pre_flag_r
	always@(posedge tx_clk)begin
		if(rst)
			pre_flag_r <= 1'b0;
		else if(rd_en == 1'b1 & rd_addr == 'd9)
			pre_flag_r <= 1'b0;
		else if(rd_en == 1'b1 & rd_addr == 'd1)
			pre_flag_r <= 1'b1;
	end	
blkwr8x4096 frame_buffer (
  .clka(tx_clk),    // input wire clka
  .wea(tx_data_en_dly),      // input wire [0 : 0] wea
  .addra(data_cnt),  // input wire [11 : 0] addra
  .dina(tx_gen_data_dly),    // input wire [7 : 0] dina
  .clkb(tx_clk),    // input wire clkb
  .addrb(rd_addr),  // input wire [11 : 0] addrb
  .doutb(rd_data)  // output wire [7 : 0] doutb
);	
endmodule
