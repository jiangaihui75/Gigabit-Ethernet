// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Youkaiyuan  v3eduyky@126.com
// wechat : 15921999232
// File   : crc32_d8_rec_02.v
// Create : 2019-10-20 21:28:44
// Revise : 2019-10-21 11:26:08
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module crc32_d8_rec_02(
		input	wire		resetb,
		input	wire		sclk,
	
		input	wire		dsin,
		input	wire	[7:0]	din,
		
		output	reg		crc32_cal_end,
		output	reg		crc32_error
		);
		
//***********************************************************************
reg		dsin_t,data_last;
reg	[7:0]	d;
wire	[31:0]	c;
reg	[31:0]	crc32_value;

//***********************************************************************
//redefine
always@(*) begin
	d=din;
end
		
//redefine
assign c = crc32_value;

always@(posedge sclk)
	if (dsin==0)
		crc32_value <= 32'hFFFFFFFF;
	else
	begin
	    crc32_value[0]<=c[24]^c[30]^d[1]^d[7];
	    crc32_value[1]<=c[25]^c[31]^d[0]^d[6]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[2]<=c[26]^d[5]^c[25]^c[31]^d[0]^d[6]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[3]<=c[27]^d[4]^c[26]^d[5]^c[25]^c[31]^d[0]^d[6];
	    crc32_value[4]<=c[28]^d[3]^c[27]^d[4]^c[26]^d[5]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[5]<=c[29]^d[2]^c[28]^d[3]^c[27]^d[4]^c[25]^c[31]^d[0]^d[6]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[6]<=c[30]^d[1]^c[29]^d[2]^c[28]^d[3]^c[26]^d[5]^c[25]^c[31]^d[0]^d[6];
	    crc32_value[7]<=c[31]^d[0]^c[29]^d[2]^c[27]^d[4]^c[26]^d[5]^c[24]^d[7];
	    crc32_value[8]<=c[0]^c[28]^d[3]^c[27]^d[4]^c[25]^d[6]^c[24]^d[7];
	    crc32_value[9]<=c[1]^c[29]^d[2]^c[28]^d[3]^c[26]^d[5]^c[25]^d[6];
	    crc32_value[10]<=c[2]^c[29]^d[2]^c[27]^d[4]^c[26]^d[5]^c[24]^d[7];
	    crc32_value[11]<=c[3]^c[28]^d[3]^c[27]^d[4]^c[25]^d[6]^c[24]^d[7];
	    crc32_value[12]<=c[4]^c[29]^d[2]^c[28]^d[3]^c[26]^d[5]^c[25]^d[6]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[13]<=c[5]^c[30]^d[1]^c[29]^d[2]^c[27]^d[4]^c[26]^d[5]^c[25]^c[31]^d[0]^d[6];
	    crc32_value[14]<=c[6]^c[31]^d[0]^c[30]^d[1]^c[28]^d[3]^c[27]^d[4]^c[26]^d[5];
	    crc32_value[15]<=c[7]^c[31]^d[0]^c[29]^d[2]^c[28]^d[3]^c[27]^d[4];
	    crc32_value[16]<=c[8]^c[29]^d[2]^c[28]^d[3]^c[24]^d[7];
	    crc32_value[17]<=c[9]^c[30]^d[1]^c[29]^d[2]^c[25]^d[6];
	    crc32_value[18]<=c[10]^c[31]^d[0]^c[30]^d[1]^c[26]^d[5];
	    crc32_value[19]<=c[11]^c[31]^d[0]^c[27]^d[4];
	    crc32_value[20]<=c[12]^c[28]^d[3];
	    crc32_value[21]<=c[13]^c[29]^d[2];
	    crc32_value[22]<=c[14]^c[24]^d[7];
	    crc32_value[23]<=c[15]^c[25]^d[6]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[24]<=c[16]^c[26]^d[5]^c[25]^c[31]^d[0]^d[6];
	    crc32_value[25]<=c[17]^c[27]^d[4]^c[26]^d[5];
	    crc32_value[26]<=c[18]^c[28]^d[3]^c[27]^d[4]^c[24]^c[30]^d[1]^d[7];
	    crc32_value[27]<=c[19]^c[29]^d[2]^c[28]^d[3]^c[25]^c[31]^d[0]^d[6];
	    crc32_value[28]<=c[20]^c[30]^d[1]^c[29]^d[2]^c[26]^d[5];
	    crc32_value[29]<=c[21]^c[31]^d[0]^c[30]^d[1]^c[27]^d[4];
	    crc32_value[30]<=c[22]^c[31]^d[0]^c[28]^d[3];
	    crc32_value[31]<=c[23]^c[29]^d[2];
	end

always@(posedge sclk)
	dsin_t<=dsin;

always@(dsin or dsin_t)
	if (dsin==0 && dsin_t==1)
		data_last<=1;
	else
		data_last<=0;

always@(posedge sclk)
	crc32_cal_end<=data_last;

always@(posedge sclk or negedge resetb)
	if (resetb==0)
		crc32_error<=0;
	else if (data_last==1) begin
		if (crc32_value==32'hc704dd7b)
			crc32_error<=0;
		else
			crc32_error<=1;
	end
	else begin
		crc32_error <= 1'b0;
	end

endmodule