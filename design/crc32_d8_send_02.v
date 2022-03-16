module crc32_d8_send_02(
		input	wire		rst,
		input	wire		sclk,
	
		input	wire		dsin,
		input	wire	[7:0]	din,
		input	wire		pre_flag,
		input	wire		crc_err_en,

		output	reg		dsout,
		output	reg	[7:0]	dout
		);
		
//***********************************************************************
reg		crc_ds,crc_en;//dsout_t;
reg		dsin_t;
reg	[7:0]	din_t;
reg	[7:0]	d;
wire	[31:0]	c;
reg	[31:0]	crc32_value;
//reg	[7:0]	data_1_t,data_2_t,data_3_t,data_4_t,data_5_t;
//**********************************************************************/
//			CRC校验
//**********************************************************************/
always @(dsin or pre_flag)
	if (dsin==1 && pre_flag==0)
		crc_ds<=1;
	else
		crc_ds<=0;
always@(posedge sclk)
	if (crc_ds==1 )
		crc_en<=1;
	else
		crc_en<=0;

always@(posedge sclk)
	if (crc_ds=='d0)
		d<='d0;	
	else
		d<=din;

assign c = crc32_value;

always @(posedge sclk)
	if (rst==1'b1)
		crc32_value<=32'hFFFFFFFF;
	else if(crc_en==1)
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
	else
		crc32_value<={crc32_value[23:0],8'hff};
//

reg	crc_en_t;
always @(posedge sclk)
	crc_en_t<=crc_en;
reg	[2:0]	d_cnt;	
always @ (posedge sclk)
	if(rst == 1'b1)
		d_cnt<=0;
	else if(!crc_en&&crc_en_t)
		d_cnt<=d_cnt+1'd1;
	else if(d_cnt>3'd0&&d_cnt<3'd4)
		d_cnt<=d_cnt+1'd1;
	else
		d_cnt<=3'd0;
//dsin_t
always @(posedge sclk)
	dsin_t<=dsin;
always @ (posedge sclk)
	din_t<=din;

always@(posedge sclk)
	if (dsin_t=='d0 && d_cnt=='d0 && crc_en_t=='d0)
		dout<='d0;
	else if (dsin_t==1'b1)
		dout<=din_t;
	else if (d_cnt=='d4)
		dout<='d0;
	else if (crc_err_en==0)
		dout<=~{crc32_value[24], crc32_value[25], crc32_value[26], crc32_value[27], crc32_value[28], crc32_value[29], crc32_value[30], crc32_value[31]};
	else
		dout<={crc32_value[24], crc32_value[25], crc32_value[26], crc32_value[27], crc32_value[28], crc32_value[29], crc32_value[30], crc32_value[31]};
//dsout
always @(posedge sclk)
	if(rst == 1'b1)
		dsout<='d0;
	else if(dsin_t)
		dsout<='d1;
	else if(d_cnt=='d4)
		dsout<='d0;
endmodule