//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2024 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================


module enigma_part2(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
input clk;         // clock 
input srst_n;      // synchronous reset (active low)
input load;        // load control signal (level sensitive). 0/1: inactive/active
input encrypt;     // encrypt control signal (level sensitive). 0/1: inactive/active
input crypt_mode;  // 0: encrypt; 1:decrypt;
input [2-1:0] table_idx; // table_idx indicates which rotor to be loaded 
						             // 2'b00: plugboard
						             // 2'b01: rotorA
						             // 2'b10: rotorB
input [6-1:0] code_in;	// When load is active, then code_in is input of rotors. 
						// When encrypy is active, then code_in is input of code words.
output reg [6-1:0] code_out;   // encrypted code word (register output)
output reg code_valid;         // 0: non-valid code_out; 1: valid code_out (register output)

//top connection
wire load_rotorA = load & table_idx[0];
wire [6-1:0] swbox_rotorA;
wire [6-1:0] rotorA_swbox;
wire [6-1:0] rotorA_Reflector;
wire [6-1:0] Reflector_rotorA;
wire [6-1:0] code_out_ff;
wire [6-1:0] code_out_sw;
wire code_valid_ff;

//swbox connection
swbox swbox
(
 	.clk(clk),
	.srst_n(srst_n), 
 	.encrypt(encrypt), 
 	.crypt_mode(crypt_mode), 
 	.forward_in(code_in), 
 	.forward_out(swbox_rotorA), 
 	.inverse_in(rotorA_swbox), 
 	.inverse_out(code_out_sw)
);

//rotorA connection
rotorA rotorA
(
 	.clk(clk),
	.srst_n(srst_n),
	.load(load_rotorA), 
 	.encrypt(encrypt), 
 	.crypt_mode(crypt_mode), 
 	.forward_in(swbox_rotorA), 
 	.forward_out(rotorA_Reflector), 
 	.inverse_in(Reflector_rotorA), 
 	.inverse_out(rotorA_swbox)
);

 //Reflector conncection
Reflector Reflector
(
 	.data_in(rotorA_Reflector), 
 	.data_out(Reflector_rotorA)
);

//output combinational
assign code_valid_ff= (table_idx == 2'b11 & encrypt );
assign code_out_ff = (code_valid_ff)? code_out_sw : 6'd0 ;

//output FF
always @(posedge clk) begin
	if(~srst_n)begin
		code_out <= 5'd0;
		code_valid <= 1'b0;
	end
	else begin
		code_out <= code_out_ff;
		code_valid <= code_valid_ff;
	end
end


endmodule