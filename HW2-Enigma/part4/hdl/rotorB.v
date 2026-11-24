module rotorB (clk, srst_n, load, encrypt, crypt_mode, 
				forward_in, forward_out, inverse_in, inverse_out);
input clk;         // clock 
input srst_n;      // synchronous reset (active low)
input load;        // load control signal (level sensitive). 0/1: inactive/active
input encrypt;     // encrypt control signal (level sensitive). 0/1: inactive/active
input crypt_mode;  // 0: encrypt; 1:decrypt;
input [6-1:0] forward_in;
input [6-1:0] inverse_in;

output reg [6-1:0] forward_out;
output reg [6-1:0] inverse_out;

/////******** Combinational ********/////

localparam  configuration_num  =7'd64;

reg [6-1:0] configuration_map [0:configuration_num-1];
reg [6-1:0] configuration_map_next [0:configuration_num-1];
reg [6-1:0] configuration_map_mode [0:configuration_num-1];
reg [6-1:0] load_cnt, load_cnt_next;

wire [1:0] Mode_next;
localparam Mode0 = 2'b00;
localparam Mode1 = 2'b01;
localparam Mode2 = 2'b10;
localparam Mode3 = 2'b11;
assign Mode_next = crypt_mode? inverse_in[1:0] : forward_out[1:0]; //crypt_mode 0: encrypt; 1:decrypt;

function [6-1:0] search (input [configuration_num-1:0] a);
    integer i;
    begin:block
    search = configuration_num;
      for (i = configuration_num-1 ; i>=0 ; i=i-1)
      begin:block
        if(a[i] == 1'b1)
          begin
          search=i;
            disable block; 
          end
      end
    end 
endfunction

integer a;
reg[configuration_num-1:0] pivot;

always @(*) begin
	//Initial
	load_cnt_next = 6'd0;
	forward_out = 6'd0;
	inverse_out = 6'd0;

	for(a=0;a<configuration_num;a=a+1)begin
			if (inverse_in == configuration_map[a]) pivot[a] = 1;
			else pivot[a]=0;
	end

	//I/O configuration
	if (load) begin
		load_cnt_next = load_cnt + 1'b1;
	end
	else if (encrypt) begin //encrypt
		forward_out = configuration_map[forward_in];
		inverse_out = search(pivot);
	end
end

//change configuration
integer j,q,k,m,p;
always @(*) begin
	
	//Default condition
	for (m=0; m<configuration_num ;m=m+1 ) begin
				configuration_map_next[m] = configuration_map[m];
	end

	for (p=0; p<configuration_num ;p=p+1 ) begin
				configuration_map_mode[p] = configuration_map[p];
	end

	//load configuration
	if(load)begin
		configuration_map_next[load_cnt] = forward_in;
	end
	//configuration changes by mode
	else if(encrypt) begin
	case (Mode_next)
		//Mode0 = default
		/*Mode0:begin
			for (i=0; i<configuration_num-1 ;i=i+1 ) begin
				configuration_map_mode[i] = configuration_map[i];
			end
		end*/ 
		Mode1:begin
			for (j=0; j<16 ;j=j+1 ) begin
				configuration_map_mode[0+4*j] = configuration_map[1+4*j];
				configuration_map_mode[1+4*j] = configuration_map[0+4*j];
				configuration_map_mode[2+4*j] = configuration_map[3+4*j];
				configuration_map_mode[3+4*j] = configuration_map[2+4*j];
			end
		end 
		Mode2:begin
			for (q=0; q<16 ;q=q+1 ) begin
				configuration_map_mode[0+4*q] = configuration_map[2+4*q];
				configuration_map_mode[1+4*q] = configuration_map[3+4*q];
				configuration_map_mode[2+4*q] = configuration_map[0+4*q];
				configuration_map_mode[3+4*q] = configuration_map[1+4*q];
			end
		end
		Mode3:begin
			for (k=0; k<16 ;k=k+1 ) begin
				configuration_map_mode[0+4*k] = configuration_map[3+4*k];
				configuration_map_mode[1+4*k] = configuration_map[2+4*k];
				configuration_map_mode[2+4*k] = configuration_map[1+4*k];
				configuration_map_mode[3+4*k] = configuration_map[0+4*k];
			end
		end 
	endcase
	//configuration changes by fixed permutation
	configuration_map_next[00] = configuration_map_mode[56];
	configuration_map_next[01] = configuration_map_mode[61];
	configuration_map_next[02] = configuration_map_mode[25];
	configuration_map_next[03] = configuration_map_mode[17];
	configuration_map_next[04] = configuration_map_mode[42];
	configuration_map_next[05] = configuration_map_mode[48];
	configuration_map_next[06] = configuration_map_mode[23];
	configuration_map_next[07] = configuration_map_mode[43];
	configuration_map_next[08] = configuration_map_mode[10];
	configuration_map_next[09] = configuration_map_mode[28];
	configuration_map_next[10] = configuration_map_mode[58];
	configuration_map_next[11] = configuration_map_mode[24];
	configuration_map_next[12] = configuration_map_mode[21];
	configuration_map_next[13] = configuration_map_mode[29];
	configuration_map_next[14] = configuration_map_mode[18];
	configuration_map_next[15] = configuration_map_mode[38];
	configuration_map_next[16] = configuration_map_mode[26];
	configuration_map_next[17] = configuration_map_mode[13];
	configuration_map_next[18] = configuration_map_mode[57];
	configuration_map_next[19] = configuration_map_mode[06];
	configuration_map_next[20] = configuration_map_mode[22];
	configuration_map_next[21] = configuration_map_mode[47];
	configuration_map_next[22] = configuration_map_mode[08];
	configuration_map_next[23] = configuration_map_mode[40];
	configuration_map_next[24] = configuration_map_mode[54];
	configuration_map_next[25] = configuration_map_mode[02];
	configuration_map_next[26] = configuration_map_mode[32];
	configuration_map_next[27] = configuration_map_mode[63];
	configuration_map_next[28] = configuration_map_mode[14];
	configuration_map_next[29] = configuration_map_mode[34];
	configuration_map_next[30] = configuration_map_mode[60];
	configuration_map_next[31] = configuration_map_mode[55];
	configuration_map_next[32] = configuration_map_mode[49];
	configuration_map_next[33] = configuration_map_mode[16];
	configuration_map_next[34] = configuration_map_mode[09];
	configuration_map_next[35] = configuration_map_mode[44];
	configuration_map_next[36] = configuration_map_mode[05];
	configuration_map_next[37] = configuration_map_mode[03];
	configuration_map_next[38] = configuration_map_mode[53];
	configuration_map_next[39] = configuration_map_mode[46];
	configuration_map_next[40] = configuration_map_mode[51];
	configuration_map_next[41] = configuration_map_mode[39];
	configuration_map_next[42] = configuration_map_mode[30];
	configuration_map_next[43] = configuration_map_mode[11];
	configuration_map_next[44] = configuration_map_mode[15];
	configuration_map_next[45] = configuration_map_mode[04];
	configuration_map_next[46] = configuration_map_mode[36];
	configuration_map_next[47] = configuration_map_mode[59];
	configuration_map_next[48] = configuration_map_mode[50];
	configuration_map_next[49] = configuration_map_mode[19];
	configuration_map_next[50] = configuration_map_mode[35];
	configuration_map_next[51] = configuration_map_mode[52];
	configuration_map_next[52] = configuration_map_mode[62];
	configuration_map_next[53] = configuration_map_mode[01];
	configuration_map_next[54] = configuration_map_mode[37];
	configuration_map_next[55] = configuration_map_mode[07];
	configuration_map_next[56] = configuration_map_mode[12];
	configuration_map_next[57] = configuration_map_mode[45];
	configuration_map_next[58] = configuration_map_mode[31];
	configuration_map_next[59] = configuration_map_mode[27];
	configuration_map_next[60] = configuration_map_mode[41];
	configuration_map_next[61] = configuration_map_mode[20];
	configuration_map_next[62] = configuration_map_mode[00];
	configuration_map_next[63] = configuration_map_mode[33];
	end
end

integer l,n;
/////******** Sequential ********/////
always @(posedge clk) begin
	if (~srst_n) begin
		load_cnt <= 0;
		for (l=0; l<configuration_num ;l=l+1 ) begin
				configuration_map[l] <= 0;
			end
	end
	else begin
		load_cnt <= load_cnt_next;
		for (n=0; n<configuration_num ;n=n+1 ) begin
				configuration_map[n] <= configuration_map_next[n];
			end
	end
	
end
	
endmodule