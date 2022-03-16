// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : get_images_pixels.v
// Create : 2019-10-29 17:28:32
// Revise : 2019-10-29 18:02:16
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
module get_images_pixels(
		input	wire 			sclk,
		input	wire 			rst,
		input	wire 			rx_en,
		input	wire 	[7:0]	rx_data,
		input	wire 	[15:0]	statusi,
		output	reg 	[7:0]	pixels,
		output	reg 			pixels_vld
    );
reg [13:0] rx_cnt;
reg 		pixel_flag;

always @(posedge sclk or posedge rst) begin
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

always @(posedge sclk or posedge rst) begin
	if (rst == 1'b1) begin
		pixel_flag <= 1'b0;
	end
	else if(rx_en == 1'b1 && rx_cnt == (statusi[13:0]-5)) begin
		pixel_flag <= 1'b0;
	end
	else if (rx_en == 1'b1 && rx_cnt == 'd49) begin
		pixel_flag <= 1'b1;
	end
end

always @(posedge sclk) begin
	pixels_vld <= pixel_flag;
end

always @(posedge sclk) begin
	if (rst == 1'b1) begin
		pixels <='d0;
	end
	else if (pixel_flag == 1'b1) begin
		pixels <= rx_data ;
	end
	else begin
		pixels <='d0;
	end
end

endmodule
