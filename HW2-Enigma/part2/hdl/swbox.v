module swbox 
(
	input clk,
	input srst_n, 
	//input load,
 	input encrypt, 
 	input crypt_mode, 
 	input [6-1:0] forward_in, 
 	output reg [6-1:0] forward_out, 
 	input [6-1:0] inverse_in, 
 	output reg [6-1:0]inverse_out
);

reg [1:0] Mode, Mode_next;
localparam Mode0 = 2'b00;
localparam Mode1 = 2'b01;
localparam Mode2 = 2'b10;
localparam Mode3 = 2'b11;

//*** conbinational ***//
//Mode_next condition
always @(*) begin
	Mode_next = 2'd00;
	if(encrypt & ~crypt_mode)
		Mode_next = forward_out[1:0];
	else if(encrypt & crypt_mode)
		Mode_next = inverse_in[1:0];
end

//output determination

always @(*) begin
	forward_out = forward_in;
	inverse_out = inverse_in;
	if (encrypt) begin
		case (Mode)
		Mode0: begin
			forward_out = {~forward_in[5],~forward_in[4],~forward_in[3],
							~forward_in[2],~forward_in[1],~forward_in[0]};
			inverse_out = {~inverse_in[5],~inverse_in[4],~inverse_in[3],
							~inverse_in[2],~inverse_in[1],~inverse_in[0]};
		end
		Mode1: begin
			forward_out = {forward_in[0],forward_in[1],forward_in[2],
							forward_in[3],forward_in[4],forward_in[5]};
			inverse_out = {inverse_in[0],inverse_in[1],inverse_in[2],
							inverse_in[3],inverse_in[4],inverse_in[5]};
		end
		Mode2: begin
			forward_out = {forward_in[4],forward_in[5],forward_in[2],
							forward_in[3],forward_in[0],forward_in[1]};
			inverse_out = {inverse_in[4],inverse_in[5],inverse_in[2],
							inverse_in[3],inverse_in[0],inverse_in[1]};
		end
		Mode3: begin
			forward_out = {forward_in[2],forward_in[1],forward_in[0],
							forward_in[5],forward_in[4],forward_in[3]};
			inverse_out = {inverse_in[2],inverse_in[1],inverse_in[0],
							inverse_in[5],inverse_in[4],inverse_in[3]};
		end  
	endcase
	end
	
end

//*** sequencial ***//
always @(posedge clk) begin
	if(~srst_n)begin
		Mode <= 2'b00;
	end
	else begin
		Mode <= Mode_next;
	end

end
	
endmodule