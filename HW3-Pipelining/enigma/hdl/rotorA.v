module rotorA (clk, load, encrypt, crypt_mode, forward_in, forward_out,
				 inverse_in, inverse_out,lookahead_out);
input clk;         // clock 
//input srst_n;      // synchronous reset (active low)
input load;        // load control signal (level sensitive). 0/1: inactive/active
input encrypt;     // encrypt control signal (level sensitive). 0/1: inactive/active
input crypt_mode;  // 0: encrypt; 1:decrypt;
input [6-1:0] forward_in;
input [6-1:0] inverse_in;

output reg [6-1:0] forward_out;
output reg [6-1:0] inverse_out;
output reg [1:0] lookahead_out;

//top FF
reg [6-1:0] forward_out_fast;
reg [6-1:0] inverse_in_FF;
reg [1:0] lookahead_out_FF;
//reg encrypt_FF;

/////******** Combinational ********/////

localparam  configuration_num  =7'd64;

reg [6-1:0] configuration_map [0:configuration_num-1];
reg [6-1:0] configuration_map_next [0:configuration_num-1];

reg [6-1:0] load_cnt, load_cnt_next;

wire [1:0] shift_amount;
assign shift_amount = crypt_mode? inverse_in[1:0] : forward_out[1:0]; //1:decrypt; 0: encrypt;


reg [6-1:0] map_pointer,map_pointer_n,map_pointer_delay;//point to the configuration map
//reg [1:0] map_pointer_ahead,map_pointer_ahead_n;//point to the configuration map

//Determin forward_out & inverse_out
reg [6-1:0] locate;
reg [1:0] locate_ahead;

wire [6-1:0] position_for,position_inv;
wire [1:0] position_ahead;
assign position_for = (forward_in) + (map_pointer) ;

assign position_inv = (locate) - (map_pointer_delay);
assign position_ahead = (locate_ahead) - (map_pointer[1:0]);


always @(*) begin
	//Initial
	load_cnt_next = 6'd0;
	forward_out = forward_in;
	inverse_out = inverse_in_FF;
	lookahead_out_FF = inverse_in[1:0];
	locate = 6'd0 ;

	//look up table
	case (inverse_in_FF) // synopsys parallel_case
		configuration_map[0]: locate = 6'd0 ;
		configuration_map[1]: locate = 6'd1 ;
		configuration_map[2]: locate = 6'd2 ;
		configuration_map[3]: locate = 6'd3 ;
		configuration_map[4]: locate = 6'd4 ;
		configuration_map[5]: locate = 6'd5 ;
		configuration_map[6]: locate = 6'd6 ;
		configuration_map[7]: locate = 6'd7 ;
		configuration_map[8]: locate = 6'd8 ;
		configuration_map[9]: locate = 6'd9 ;
		configuration_map[10]: locate = 6'd10 ;
		configuration_map[11]: locate = 6'd11 ;
		configuration_map[12]: locate = 6'd12 ;
		configuration_map[13]: locate = 6'd13 ;
		configuration_map[14]: locate = 6'd14 ;
		configuration_map[15]: locate = 6'd15 ;
		configuration_map[16]: locate = 6'd16 ;
		configuration_map[17]: locate = 6'd17 ;
		configuration_map[18]: locate = 6'd18 ;
		configuration_map[19]: locate = 6'd19 ;
		configuration_map[20]: locate = 6'd20 ;
		configuration_map[21]: locate = 6'd21 ;
		configuration_map[22]: locate = 6'd22 ;
		configuration_map[23]: locate = 6'd23 ;
		configuration_map[24]: locate = 6'd24 ;
		configuration_map[25]: locate = 6'd25 ;
		configuration_map[26]: locate = 6'd26 ;
		configuration_map[27]: locate = 6'd27 ;
		configuration_map[28]: locate = 6'd28 ;
		configuration_map[29]: locate = 6'd29 ;
		configuration_map[30]: locate = 6'd30 ;
		configuration_map[31]: locate = 6'd31 ;
		configuration_map[32]: locate = 6'd32 ;
		configuration_map[33]: locate = 6'd33 ;
		configuration_map[34]: locate = 6'd34 ;
		configuration_map[35]: locate = 6'd35 ;
		configuration_map[36]: locate = 6'd36 ;
		configuration_map[37]: locate = 6'd37 ;
		configuration_map[38]: locate = 6'd38 ;
		configuration_map[39]: locate = 6'd39 ;
		configuration_map[40]: locate = 6'd40 ;
		configuration_map[41]: locate = 6'd41 ;
		configuration_map[42]: locate = 6'd42 ;
		configuration_map[43]: locate = 6'd43 ;
		configuration_map[44]: locate = 6'd44 ;
		configuration_map[45]: locate = 6'd45 ;
		configuration_map[46]: locate = 6'd46 ;
		configuration_map[47]: locate = 6'd47 ;
		configuration_map[48]: locate = 6'd48 ;
		configuration_map[49]: locate = 6'd49 ;
		configuration_map[50]: locate = 6'd50 ;
		configuration_map[51]: locate = 6'd51 ;
		configuration_map[52]: locate = 6'd52 ;
		configuration_map[53]: locate = 6'd53 ;
		configuration_map[54]: locate = 6'd54 ;
		configuration_map[55]: locate = 6'd55 ;
		configuration_map[56]: locate = 6'd56 ;
		configuration_map[57]: locate = 6'd57 ;
		configuration_map[58]: locate = 6'd58 ;
		configuration_map[59]: locate = 6'd59 ;
		configuration_map[60]: locate = 6'd60 ;
		configuration_map[61]: locate = 6'd61 ;
		configuration_map[62]: locate = 6'd62 ;
		configuration_map[63]: locate = 6'd63 ;
	endcase

	//look up table for lookahead
	case (inverse_in) // synopsys parallel_case
		configuration_map[0]: locate_ahead = 2'b00 ;
		configuration_map[1]: locate_ahead = 2'b01 ;
		configuration_map[2]: locate_ahead = 2'b10 ;
		configuration_map[3]: locate_ahead = 2'b11 ;

		configuration_map[4]: locate_ahead = 2'b00 ;
		configuration_map[5]: locate_ahead = 2'b01 ;
		configuration_map[6]: locate_ahead = 2'b10 ;
		configuration_map[7]: locate_ahead = 2'b11 ;

		configuration_map[8]: locate_ahead = 2'b00 ;
		configuration_map[9]: locate_ahead = 2'b01 ;
		configuration_map[10]: locate_ahead = 2'b10 ;
		configuration_map[11]: locate_ahead = 2'b11 ;

		configuration_map[12]: locate_ahead = 2'b00 ;
		configuration_map[13]: locate_ahead = 2'b01 ;
		configuration_map[14]: locate_ahead = 2'b10 ;
		configuration_map[15]: locate_ahead = 2'b11 ;

		configuration_map[16]: locate_ahead = 2'b00 ;
		configuration_map[17]: locate_ahead = 2'b01 ;
		configuration_map[18]: locate_ahead = 2'b10 ;
		configuration_map[19]: locate_ahead = 2'b11 ;

		configuration_map[20]: locate_ahead = 2'b00 ;
		configuration_map[21]: locate_ahead = 2'b01 ;
		configuration_map[22]: locate_ahead = 2'b10 ;
		configuration_map[23]: locate_ahead = 2'b11 ;

		configuration_map[24]: locate_ahead = 2'b00 ;
		configuration_map[25]: locate_ahead = 2'b01 ;
		configuration_map[26]: locate_ahead = 2'b10 ;
		configuration_map[27]: locate_ahead = 2'b11 ;

		configuration_map[28]: locate_ahead = 2'b00 ;
		configuration_map[29]: locate_ahead = 2'b01 ;
		configuration_map[30]: locate_ahead = 2'b10 ;
		configuration_map[31]: locate_ahead = 2'b11 ;

		configuration_map[32]: locate_ahead = 2'b00 ;
		configuration_map[33]: locate_ahead = 2'b01 ;
		configuration_map[34]: locate_ahead = 2'b10 ;
		configuration_map[35]: locate_ahead = 2'b11 ;

		configuration_map[36]: locate_ahead = 2'b00 ;
		configuration_map[37]: locate_ahead = 2'b01 ;
		configuration_map[38]: locate_ahead = 2'b10 ;
		configuration_map[39]: locate_ahead = 2'b11 ;

		configuration_map[40]: locate_ahead = 2'b00 ;
		configuration_map[41]: locate_ahead = 2'b01 ;
		configuration_map[42]: locate_ahead = 2'b10 ;
		configuration_map[43]: locate_ahead = 2'b11 ;

		configuration_map[44]: locate_ahead = 2'b00 ;
		configuration_map[45]: locate_ahead = 2'b01 ;
		configuration_map[46]: locate_ahead = 2'b10 ;
		configuration_map[47]: locate_ahead = 2'b11 ;

		configuration_map[48]: locate_ahead = 2'b00 ;
		configuration_map[49]: locate_ahead = 2'b01 ;
		configuration_map[50]: locate_ahead = 2'b10 ;
		configuration_map[51]: locate_ahead = 2'b11 ;

		configuration_map[52]: locate_ahead = 2'b00 ;
		configuration_map[53]: locate_ahead = 2'b01 ;
		configuration_map[54]: locate_ahead = 2'b10 ;
		configuration_map[55]: locate_ahead = 2'b11 ;

		configuration_map[56]: locate_ahead = 2'b00 ;
		configuration_map[57]: locate_ahead = 2'b01 ;
		configuration_map[58]: locate_ahead = 2'b10 ;
		configuration_map[59]: locate_ahead = 2'b11 ;

		configuration_map[60]: locate_ahead = 2'b00 ;
		configuration_map[61]: locate_ahead = 2'b01 ;
		configuration_map[62]: locate_ahead = 2'b10 ;
		configuration_map[63]: locate_ahead = 2'b11 ;
	endcase

	//I/O configuration
	if (load) begin
		load_cnt_next = load_cnt + 1'b1;
	end
	if (encrypt) begin
		inverse_out = position_inv;
		forward_out = configuration_map[position_for];
		lookahead_out_FF = position_ahead;
	end
end

//change configuration
integer i;
always @(*) begin
	//Default Condition
	map_pointer_n = 0;
	//map_pointer_ahead_n = 0;
	for ( i=0 ;i<configuration_num;i=i+1 ) begin
		configuration_map_next[i] = configuration_map[i];
	end

	//real case
	if(load)begin
		configuration_map_next[load_cnt] = forward_in;
	end
	if(encrypt) begin
		map_pointer_n = map_pointer + shift_amount;
		//map_pointer_ahead_n = map_pointer_ahead + shift_amount;
	end
		
end

integer j;
/////******** Sequential ********/////
always @(posedge clk) begin
	load_cnt <= load_cnt_next;
	//encrypt_FF <= encrypt;
	
	inverse_in_FF <= inverse_in;

	map_pointer <= map_pointer_n;
	//map_pointer_ahead <= map_pointer_ahead_n;
	lookahead_out <= lookahead_out_FF;

	map_pointer_delay <= map_pointer;
	for ( j=0 ;j<configuration_num;j=j+1 ) begin
		configuration_map[j] <= configuration_map_next[j];
	end
end
	
endmodule