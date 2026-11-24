module swbox 
(
	input clk,
	//input srst_n, 
	//input load,
 	input encrypt, 
 	input crypt_mode, 
 	input [6-1:0] forward_in, 
 	output reg [6-1:0] forward_out, 
 	input [6-1:0] inverse_in, 
 	output reg [6-1:0]inverse_out,
	input [1:0] lookahead_in
);

reg [1:0] Mode, Mode_next, Mode_delay,Mode_ahead,Mode_ahead_FF;
reg [6-1:0] forward_in_FF;
reg encrypt_FF;
reg [1:0] lookahead_out;

localparam Mode0 = 2'b00;
localparam Mode1 = 2'b01;
localparam Mode2 = 2'b10;
localparam Mode3 = 2'b11;

//*** conbinational ***//
//Mode_next condition
always @(*) begin
	Mode_next = 2'd00;
	Mode_ahead = lookahead_in;
	if(encrypt_FF & ~crypt_mode)
		Mode_next = forward_out[1:0];
	else if(encrypt & crypt_mode)
		Mode_next = inverse_in[1:0];
end
//wire [1:0]state;
//assign state = {(encrypt_FF & encrypt),crypt_mode};

//output determination

always @(*) begin
	forward_out = forward_in_FF;
	inverse_out = inverse_in;
	
	//if else case
	if (encrypt_FF & ~crypt_mode) begin
		
		case (Mode) // synopsys parallel_case
		Mode0: begin
			forward_out = {~forward_in_FF[5],~forward_in_FF[4],~forward_in_FF[3],
							~forward_in_FF[2],~forward_in_FF[1],~forward_in_FF[0]};
		end
		Mode1: begin
			forward_out = {forward_in_FF[0],forward_in_FF[1],forward_in_FF[2],
							forward_in_FF[3],forward_in_FF[4],forward_in_FF[5]};
		end
		Mode2: begin
			forward_out = {forward_in_FF[4],forward_in_FF[5],forward_in_FF[2],
							forward_in_FF[3],forward_in_FF[0],forward_in_FF[1]};
		end
		Mode3: begin
			forward_out = {forward_in_FF[2],forward_in_FF[1],forward_in_FF[0],
							forward_in_FF[5],forward_in_FF[4],forward_in_FF[3]};
		end  
		endcase

		case (Mode_delay) // synopsys parallel_case
		Mode0: begin
			inverse_out = {~inverse_in[5],~inverse_in[4],~inverse_in[3],
							~inverse_in[2],~inverse_in[1],~inverse_in[0]};
		end
		Mode1: begin
			inverse_out = {inverse_in[0],inverse_in[1],inverse_in[2],
							inverse_in[3],inverse_in[4],inverse_in[5]};
		end
		Mode2: begin
			inverse_out = {inverse_in[4],inverse_in[5],inverse_in[2],
							inverse_in[3],inverse_in[0],inverse_in[1]};
		end
		Mode3: begin
			inverse_out = {inverse_in[2],inverse_in[1],inverse_in[0],
							inverse_in[5],inverse_in[4],inverse_in[3]};
		end 
		endcase
	end

	else if (encrypt_FF & crypt_mode) begin
		
		case (Mode_ahead) // synopsys parallel_case
		Mode0: begin
			forward_out = {~forward_in_FF[5],~forward_in_FF[4],~forward_in_FF[3],
							~forward_in_FF[2],~forward_in_FF[1],~forward_in_FF[0]};
		end
		Mode1: begin
			forward_out = {forward_in_FF[0],forward_in_FF[1],forward_in_FF[2],
							forward_in_FF[3],forward_in_FF[4],forward_in_FF[5]};
		end
		Mode2: begin
			forward_out = {forward_in_FF[4],forward_in_FF[5],forward_in_FF[2],
							forward_in_FF[3],forward_in_FF[0],forward_in_FF[1]};
		end
		Mode3: begin
			forward_out = {forward_in_FF[2],forward_in_FF[1],forward_in_FF[0],
							forward_in_FF[5],forward_in_FF[4],forward_in_FF[3]};
		end  
		endcase

		case (Mode) // synopsys parallel_case
		Mode0: begin
			inverse_out = {~inverse_in[5],~inverse_in[4],~inverse_in[3],
							~inverse_in[2],~inverse_in[1],~inverse_in[0]};
		end
		Mode1: begin
			inverse_out = {inverse_in[0],inverse_in[1],inverse_in[2],
							inverse_in[3],inverse_in[4],inverse_in[5]};
		end
		Mode2: begin
			inverse_out = {inverse_in[4],inverse_in[5],inverse_in[2],
							inverse_in[3],inverse_in[0],inverse_in[1]};
		end
		Mode3: begin
			inverse_out = {inverse_in[2],inverse_in[1],inverse_in[0],
							inverse_in[5],inverse_in[4],inverse_in[3]};
		end 
		endcase
	end


end

//*** sequencial ***//
always @(posedge clk) begin
	encrypt_FF <= encrypt;

	forward_in_FF <= forward_in;
	
	Mode <= Mode_next;
	Mode_delay <= Mode;

	//Mode_ahead_FF <= Mode_ahead;
end
	
endmodule