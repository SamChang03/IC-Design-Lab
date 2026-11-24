//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2024 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================


module enigma_pipeline(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
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
reg [6-1:0] code_in_FF;
reg [2-1:0] table_idx_FF,table_idx_FF_2nd;
reg valid_in,load_FF,load_FF_2nd;

wire load_rotorA = load_FF_2nd & table_idx_FF_2nd[0];
wire load_rotorB = load_FF_2nd & table_idx_FF_2nd[1];
wire load_plugboard = load_FF & ~(|table_idx_FF);
wire [6-1:0] swbox_plugboard;
wire [6-1:0] plugboard_swbox;
wire [6-1:0] swbox_rotorA;
wire [6-1:0] rotorA_swbox;
wire [6-1:0] rotorA_rotorB;
wire [6-1:0] rotorB_rotorA;
wire [6-1:0] rotorB_Reflector;
wire [6-1:0] Reflector_rotorB;
wire [6-1:0] code_out_ff;
wire [6-1:0] code_out_enigma;
wire [1:0] lookahead_inv;
wire code_valid_ff;
reg valid_in_FF,enigma_valid,crypt_mode_FF,crypt_mode_FF_2nd;

//swbox connection
plugboard plugboard
(
 	.clk(clk),
	//.srst_n(srst_n),
	.load(load_plugboard), 
 	.encrypt(valid_in), 
 	//.crypt_mode(), 

 	.forward_in(code_in_FF), 
 	.forward_out(plugboard_swbox), 
 	.inverse_in(swbox_plugboard), 
 	.inverse_out(code_out_enigma)
);

//swbox connection
swbox swbox
(
 	.clk(clk),
	//.srst_n(srst_n),
	//.load(), 
 	.encrypt(valid_in), 
 	.crypt_mode(crypt_mode_FF),

 	.forward_in(plugboard_swbox), 
 	.forward_out(swbox_rotorA), 
 	.inverse_in(rotorA_swbox), 
 	.inverse_out(swbox_plugboard),
	.lookahead_in(lookahead_inv)
);

//rotorA connection
rotorA rotorA
(
 	.clk(clk),
	//.srst_n(srst_n),
	.load(load_rotorA), 
 	.encrypt(valid_in_FF), 
 	.crypt_mode(crypt_mode_FF), 

 	.forward_in(swbox_rotorA), 
 	.forward_out(rotorA_rotorB), 
 	.inverse_in(rotorB_rotorA), 
 	.inverse_out(rotorA_swbox),
	.lookahead_out(lookahead_inv)
);

//rotorB connection
rotorB rotorB
(
 	.clk(clk),
	//.srst_n(srst_n),
	.load(load_rotorB), 
 	.encrypt(valid_in_FF), 
 	.crypt_mode(crypt_mode_FF),

 	.forward_in(rotorA_rotorB), 
 	.forward_out(rotorB_Reflector), 
 	.inverse_in(Reflector_rotorB), 
 	.inverse_out(rotorB_rotorA)
);

 //Reflector conncection
Reflector Reflector
(
 	//.clk(clk),
	.data_in(rotorB_Reflector), 
 	.data_out(Reflector_rotorB)
);

//output combinational
assign code_valid_ff= (table_idx_FF_2nd[0] & table_idx_FF_2nd[1] & encrypt & enigma_valid);
assign code_out_ff =  code_out_enigma;

//output FF
always @(posedge clk) begin
	if(~srst_n)begin
		code_valid <= 1'b0;
	end
	else begin
		code_valid <= code_valid_ff;
	end

	code_out <= code_out_ff;
	code_in_FF <= code_in;
	
	valid_in <= encrypt;
	valid_in_FF <= valid_in;
	enigma_valid <= valid_in_FF;

	load_FF <= load;
	load_FF_2nd <= load_FF;

	table_idx_FF <= table_idx;
	table_idx_FF_2nd <= table_idx_FF;

	crypt_mode_FF <= crypt_mode;
end


endmodule