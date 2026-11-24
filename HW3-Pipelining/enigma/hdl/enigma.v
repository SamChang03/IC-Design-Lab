//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2024 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================


module enigma(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
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
output  [6-1:0] code_out;   // encrypted code word (register output)
output  code_valid;         // 0: non-valid code_out; 1: valid code_out (register output)

enigma_pipeline u_enigma_pipeline
(
    .clk(clk),
    .srst_n(srst_n),
    .load(load),
    .encrypt(encrypt),
    .crypt_mode(crypt_mode),
    .table_idx(table_idx),
    .code_in(code_in),
    .code_out(code_out),
    .code_valid(code_valid)
);

endmodule