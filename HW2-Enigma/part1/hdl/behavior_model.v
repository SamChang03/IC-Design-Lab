//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2024 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

// Behavior model of Enigma in part1 (rotorA + reflector)
// Not synthesizable !!!
module behavior_model(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);
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
							          // Note: We only use rotorA in part1.
output reg [6-1:0] code_out;   // encrypted code word (register output)
output reg code_valid;         // 0: non-valid code_out; 1: valid code_out (register output)


integer i, j;

reg [6-1:0] rotorA    [0:64-1];
reg [6-1:0] reflector [0:64-1];
reg [6-1:0] rotorA_forward_out;
reg [2-1:0] rotorA_shift_amount;
reg [6-1:0] reflector_out;
reg [6-1:0] rotorA_load_cnt;
reg [6-1:0] first_symbol;

/// Enigma ///
initial begin
  // Initialize reflector
  rotorA_load_cnt = 0;
  code_valid = 0;
  for (i = 0; i < 64; i = i + 1)
    reflector[i] = 63 - i;

  wait(srst_n == 1'b0);
  wait(srst_n == 1'b1);

  while (1) begin
    @(posedge clk);
    code_valid = 1'b0;
    if (load && table_idx == 2'b01) begin
      rotorA[rotorA_load_cnt] = code_in;
      rotorA_load_cnt = rotorA_load_cnt + 1;
    end

    if (encrypt) begin
      rotorA_forward_out = rotorA[code_in];
      if (crypt_mode == 1'b0)
        rotorA_shift_amount = rotorA_forward_out[1:0];

      reflector_out = reflector[rotorA_forward_out];
      if (crypt_mode == 1'b1) 
        rotorA_shift_amount = reflector_out[1:0];

      for (i = 0; i < 64; i = i + 1) begin
        if (rotorA[i] == reflector_out)
          code_out = i;
      end
      code_valid = 1'b1;

      // rotate rotorA
      for (i = 0; i < rotorA_shift_amount; i = i + 1) begin
        first_symbol = rotorA[0];
        for (j = 0; j < 63; j = j + 1)
          rotorA[j] = rotorA[j+1];
        rotorA[63] = first_symbol;    
      end
    end
  end
end
endmodule
