module rotorA (clk, srst_n, load, encrypt, crypt_mode, 
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
reg [6-1:0] load_cnt, load_cnt_next;

wire [1:0]shift_amount;
assign shift_amount = crypt_mode? inverse_in[1:0] : forward_out[1:0]; //0: encrypt; 1:decrypt;

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
	forward_out = forward_in;
	inverse_out = inverse_in;

	for(a=0;a<configuration_num;a=a+1)begin
			if (inverse_in == configuration_map[a]) pivot[a] = 1;
			else pivot[a]=0;
	end

	//I/O configuration
	if (load) begin
		load_cnt_next = load_cnt + 1'b1;
	end
	else if (encrypt) begin
		forward_out = configuration_map[forward_in];
		inverse_out = search(pivot);
	end
end

//change configuration
integer i,j,q,k,m;
always @(*) begin
	
	for (m=0; m<configuration_num ;m=m+1 ) begin
				configuration_map_next[m] = configuration_map[m];
	end

	if(load)begin
		configuration_map_next[load_cnt] = forward_in;
	end
	else if(encrypt) begin
	case (shift_amount)
		2'b00:begin
			for (i=0; i<configuration_num ;i=i+1 ) begin
				configuration_map_next[i] = configuration_map[i];
			end
		end
		2'b01:begin
			for (j=0; j<configuration_num-1 ;j=j+1 ) begin
				configuration_map_next[j] = configuration_map[j+1];
			end
			configuration_map_next[63] = configuration_map[0];
		end 
		2'b10:begin
			for (q=0; q<configuration_num-2 ;q=q+1 ) begin
				configuration_map_next[q] = configuration_map[q+2];
			end
			configuration_map_next[62] = configuration_map[0];
			configuration_map_next[63] = configuration_map[1];
		end
		2'b11:begin
			for (k=0; k<configuration_num-3 ;k=k+1 ) begin
				configuration_map_next[k] = configuration_map[k+3];
			end
			configuration_map_next[61] = configuration_map[0];
			configuration_map_next[62] = configuration_map[1];
			configuration_map_next[63] = configuration_map[2];
		end 
	endcase
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