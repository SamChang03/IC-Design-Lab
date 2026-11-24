module plugboard 
(
	input clk,         // clock 
	input srst_n,      // synchronous reset (active low)
	input load,        // load control signal (level sensitive). 0/1: inactive/active
	input encrypt,     // encrypt control signal (level sensitive). 0/1: inactive/active
	//input crypt_mode,  // 0: encrypt; 1:decrypt;
	input [6-1:0] forward_in,
	input [6-1:0] inverse_in,

	output reg [6-1:0] forward_out,
	output reg [6-1:0] inverse_out
);

localparam  configuration_num  =7'd16;

/////******** Combinational ********/////
reg [6-1:0] configuration_A [0:15];
reg [6-1:0] configuration_next_A [0:15];
reg [6-1:0] configuration_B [0:15];
reg [6-1:0] configuration_next_B [0:15];

reg [3:0] load_cnt_A,load_cnt_next_A;
reg [3:0] load_cnt_B,load_cnt_next_B;
reg loadAB_change,loadAB_change_next;


always @(*) begin
	//Initial
	load_cnt_next_A = 6'd0;
	load_cnt_next_B = 6'd0;
	loadAB_change_next =1'b0;
	forward_out = forward_in;
	inverse_out = inverse_in;

	//I/O configuration
	if(load)begin
		loadAB_change_next = ~ loadAB_change;
		if (loadAB_change) begin
			load_cnt_next_A = load_cnt_A + 1'b1;
			load_cnt_next_B = load_cnt_B;
		end
		else if (~loadAB_change) begin
			load_cnt_next_A = load_cnt_A;
			load_cnt_next_B = load_cnt_B + 1'b1;
		end
	end
	else if (encrypt) begin
		case (forward_in)
			
			configuration_A[0]: forward_out = configuration_B[0];
			configuration_B[0]: forward_out = configuration_A[0];

			configuration_A[1]: forward_out = configuration_B[1];
			configuration_B[1]: forward_out = configuration_A[1];

			configuration_A[2]: forward_out = configuration_B[2];
			configuration_B[2]: forward_out = configuration_A[2];

			configuration_A[3]: forward_out = configuration_B[3];
			configuration_B[3]: forward_out = configuration_A[3];

			configuration_A[4]: forward_out = configuration_B[4];
			configuration_B[4]: forward_out = configuration_A[4];

			configuration_A[5]: forward_out = configuration_B[5];
			configuration_B[5]: forward_out = configuration_A[5];

			configuration_A[6]: forward_out = configuration_B[6];
			configuration_B[6]: forward_out = configuration_A[6];

			configuration_A[7]: forward_out = configuration_B[7];
			configuration_B[7]: forward_out = configuration_A[7];

			configuration_A[8]: forward_out = configuration_B[8];
			configuration_B[8]: forward_out = configuration_A[8];

			configuration_A[9]: forward_out = configuration_B[9];
			configuration_B[9]: forward_out = configuration_A[9];

			configuration_A[10]: forward_out = configuration_B[10];
			configuration_B[10]: forward_out = configuration_A[10];

			configuration_A[11]: forward_out = configuration_B[11];
			configuration_B[11]: forward_out = configuration_A[11];

			configuration_A[12]: forward_out = configuration_B[12];
			configuration_B[12]: forward_out = configuration_A[12];

			configuration_A[13]: forward_out = configuration_B[13];
			configuration_B[13]: forward_out = configuration_A[13];

			configuration_A[14]: forward_out = configuration_B[14];
			configuration_B[14]: forward_out = configuration_A[14];

			configuration_A[15]: forward_out = configuration_B[15];
			configuration_B[15]: forward_out = configuration_A[15];
			
			
		endcase
		case (inverse_in)
			configuration_A[0]: inverse_out = configuration_B[0];
			configuration_B[0]: inverse_out = configuration_A[0];

			configuration_A[1]: inverse_out = configuration_B[1];
			configuration_B[1]: inverse_out = configuration_A[1];

			configuration_A[2]: inverse_out = configuration_B[2];
			configuration_B[2]: inverse_out = configuration_A[2];

			configuration_A[3]: inverse_out = configuration_B[3];
			configuration_B[3]: inverse_out = configuration_A[3];

			configuration_A[4]: inverse_out = configuration_B[4];
			configuration_B[4]: inverse_out = configuration_A[4];

			configuration_A[5]: inverse_out = configuration_B[5];
			configuration_B[5]: inverse_out = configuration_A[5];

			configuration_A[6]: inverse_out = configuration_B[6];
			configuration_B[6]: inverse_out = configuration_A[6];

			configuration_A[7]: inverse_out = configuration_B[7];
			configuration_B[7]: inverse_out = configuration_A[7];

			configuration_A[8]: inverse_out = configuration_B[8];
			configuration_B[8]: inverse_out = configuration_A[8];

			configuration_A[9]: inverse_out = configuration_B[9];
			configuration_B[9]: inverse_out = configuration_A[9];

			configuration_A[10]: inverse_out = configuration_B[10];
			configuration_B[10]: inverse_out = configuration_A[10];

			configuration_A[11]: inverse_out = configuration_B[11];
			configuration_B[11]: inverse_out = configuration_A[11];

			configuration_A[12]: inverse_out = configuration_B[12];
			configuration_B[12]: inverse_out = configuration_A[12];

			configuration_A[13]: inverse_out = configuration_B[13];
			configuration_B[13]: inverse_out = configuration_A[13];

			configuration_A[14]: inverse_out = configuration_B[14];
			configuration_B[14]: inverse_out = configuration_A[14];

			configuration_A[15]: inverse_out = configuration_B[15];
			configuration_B[15]: inverse_out = configuration_A[15];
		endcase
	end
	
end

integer m;
//configuration determination
always @(*) begin
	for (m=0; m<configuration_num ;m=m+1 ) begin
				configuration_next_A[m] = configuration_A[m];
				configuration_next_B[m] = configuration_B[m];
	end

	if(load & loadAB_change)begin
		configuration_next_A[load_cnt_A] = forward_in;
	end
	else if (load & ~loadAB_change) begin
		configuration_next_B[load_cnt_B] = forward_in;
	end
end

integer l,n;
/////******** Sequential ********/////
always @(posedge clk) begin
	if (~srst_n) begin
		load_cnt_A <= 0;
		load_cnt_B <= 0;
		loadAB_change <= 0;
		for (l=0; l<configuration_num ;l=l+1 ) begin
				configuration_A[l] <= 0;
				configuration_B[l] <= 0;
			end
	end
	else begin
		load_cnt_A <= load_cnt_next_A;
		load_cnt_B <= load_cnt_next_B;
		loadAB_change <= loadAB_change_next;
		for (n=0; n<configuration_num ;n=n+1 ) begin
				configuration_A[n] <= configuration_next_A[n];
				configuration_B[n] <= configuration_next_B[n];
			end
	end
	
end
	
endmodule