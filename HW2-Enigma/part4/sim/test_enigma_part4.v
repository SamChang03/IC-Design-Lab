`timescale 1ns/1ps
`define CYCLE 10
`define END_CYCLE 100000

`define PAT_LEN 29
`define PLUG_LEN 32
`define ROTOR_A_LEN 64

//`define TEST_DATA_NUM 6000
//`define TEST_RESULT_NUM 1024


module test_enigma_part4();

reg srst_n;
reg load;
reg encrypt;
reg crypt_mode;
reg [1:0] table_idx;
reg [6-1:0] code_in;
wire [6-1:0] code_out;
wire code_valid;


// ********************************** Waveform ***********************************
/*initial begin
    $fsdbDumpfile("test_enigma_part4.fsdb");
    $fsdbDumpMDA();
    $fsdbDumpvars; 
end*/

// *******************************************************************************/

// ******** Read rotor and pattern from pat/ and rotor/ with $readmemh() *********

reg [6-1:0] plaintexts [0:`PAT_LEN-1];
reg [6-1:0] ciphertexts [0:`PAT_LEN-1];
reg [6-1:0] data_in [0:`PAT_LEN-1];
reg [6-1:0] golden [0:`PAT_LEN-1];
reg [6-1:0] rotor_A_configuratoin [0:`ROTOR_A_LEN-1];
reg [6-1:0] rotor_B_configuratoin [0:`ROTOR_A_LEN-1];
reg [6-1:0] plugboard_configuratoin [0:`PLUG_LEN-1];
reg [1:0] pattern;

integer i,j;

initial begin
    `ifdef PAT1
        $readmemh("pat/plaintexts1_part4.dat",plaintexts);
        $readmemh("pat/ciphertexts1_part4.dat",ciphertexts); 
        pattern = 2'd1;
    `endif

    `ifdef PAT2
        $readmemh("pat/plaintexts2_part4.dat",plaintexts);
        $readmemh("pat/ciphertexts2_part4.dat",ciphertexts);
        pattern = 2'd2;
    `endif

    `ifdef PAT3
        $readmemh("pat/plaintexts3_part4.dat",plaintexts);
        $readmemh("pat/ciphertexts3_part4.dat",ciphertexts);
        pattern = 2'd3;
    `endif


    `ifdef ENCRYPT
        crypt_mode = 1'b0;
        for(i=0;i<`PAT_LEN;i=i+1)begin
            data_in[i]=plaintexts[i];
            golden[i] = ciphertexts[i];
        end
    `endif

    `ifdef DECRYPT
        crypt_mode = 1'b1;
        for(j=0;j<`PAT_LEN;j=j+1)begin
            data_in[j]= ciphertexts[j];
            golden[j] = plaintexts[j];
        end
    `endif

    $readmemh("rotor/rotorA.dat",rotor_A_configuratoin);
    $readmemh("rotor/plugboard.dat",plugboard_configuratoin);
    $readmemh("rotor/rotorB.dat",rotor_B_configuratoin);
end

// *******************************************************************************/


// ****************************** clock generation *******************************
reg clk;
initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

// *******************************************************************************/



// ********************************* feed input **********************************
// reset -> load rotor -> encrypt/decrypt

integer input_i = 0;
integer input_j = 0;
integer input_k = 0;
integer input_l = 0;

initial begin
    // input feeding init
    srst_n =1'b1;
    load = 1'bz;
    encrypt = 1'bz;
    table_idx = 2'bzz;
    code_in = {6{1'bz}};

    #(`CYCLE) srst_n =1'b0;
    #(`CYCLE) srst_n =1'b1;

    // load plugboard
    while(input_k < `PLUG_LEN) begin
        @(posedge clk); #1;
        load = 1'b1;
        encrypt = 1'b0;
        table_idx = 2'b00;
        code_in = plugboard_configuratoin[input_k];
            
        input_k = input_k + 1;
    end
    
    // load rotor_A
    while(input_i < `ROTOR_A_LEN) begin
        @(posedge clk); #1;
        load = 1'b1;
        encrypt = 1'b0;
        table_idx = 2'b01;
        code_in = rotor_A_configuratoin[input_i];
            
        input_i = input_i + 1;
    end

    // load rotor_B
    while(input_l < `ROTOR_A_LEN) begin
        @(posedge clk); #1;
        load = 1'b1;
        encrypt = 1'b0;
        table_idx = 2'b10;
        code_in = rotor_B_configuratoin[input_l];
            
        input_l = input_l + 1;
    end

    #(`CYCLE);
        load = 1'b0;
        encrypt = 1'b0;
        table_idx = 2'b11;
    // encrypt/decrypt
    while(input_j < `PAT_LEN) begin
        @(posedge clk); #1;
        load = 1'b0;
        encrypt = 1'b1;
        table_idx = 2'b11;
        code_in = data_in[input_j];   

        input_j = input_j + 1;
    end

    // input feeding stop
    #(`CYCLE);
    load = 1'bz;
    encrypt = 1'bz;
    table_idx = 2'bzz;
    code_in = {6{1'bz}};
end

// *******************************************************************************/

// ************************** enigma_part4 instantiation *************************
enigma_part4 u_enigma_part4
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
// *******************************************************************************/

// ******************************** check output ********************************
/* If code_out is incorrect, print it is wrong and finish the simulation */
/* If code_out is correct for each pattern, print
============= Congratulations =============
             All patterns pass !
============= Congratulations =============
and finish the simulation
*/


integer ASCII[0:65];
initial begin
    ASCII[00] = "a";
	ASCII[01] = "b";
	ASCII[02] = "c";
	ASCII[03] = "d";
	ASCII[04] = "e";
	ASCII[05] = "f";
	ASCII[06] = "g";
	ASCII[07] = "h";
	ASCII[08] = "i";
	ASCII[09] = "j";
	ASCII[10] = "k";
	ASCII[11] = "l";
	ASCII[12] = "m";
	ASCII[13] = "n";
	ASCII[14] = "o";
	ASCII[15] = "p";
	ASCII[16] = "q";
	ASCII[17] = "r";
	ASCII[18] = "s";
	ASCII[19] = "t";
	ASCII[20] = "u";
	ASCII[21] = "v";
	ASCII[22] = "w";
	ASCII[23] = "x";
	ASCII[24] = "y";
	ASCII[25] = "z";
	ASCII[26] = " ";
	ASCII[27] = "!";
	ASCII[28] = ",";
	ASCII[29] = "-";
	ASCII[30] = ".";
	ASCII[31] = "\n";
	ASCII[32] = "A";
	ASCII[33] = "B";
	ASCII[34] = "C";
	ASCII[35] = "D";
	ASCII[36] = "E";
	ASCII[37] = "F";
	ASCII[38] = "G";
	ASCII[39] = "H";
	ASCII[40] = "I";
	ASCII[41] = "J";
	ASCII[42] = "K";
	ASCII[43] = "L";
	ASCII[44] = "M";
	ASCII[45] = "N";
    ASCII[46] = "";
	ASCII[47] = "P";
	ASCII[48] = "Q";
	ASCII[49] = "R";
	ASCII[50] = "S";
	ASCII[51] = "T";
	ASCII[52] = "U";
	ASCII[53] = "V";
	ASCII[54] = "W";
	ASCII[55] = "X";
	ASCII[56] = "Y";
	ASCII[57] = "Z";
	ASCII[58] = ":";
	ASCII[59] = "#";
	ASCII[60] = ";";
	ASCII[61] = "_";
	ASCII[62] = "+";
	ASCII[63] = "&";
end

integer pat_error;
integer output_i=0;
integer f_register;
integer print_cnt=0;

initial begin
    pat_error = 0;
    /*
    Your testbench
    */
    wait(code_valid)
    while (output_i<`PAT_LEN) begin
        @(negedge clk);
        if(code_valid) begin
            if(code_out != golden[output_i])begin
                $display ("!!!!! Comparison Fail @ pattern %0d !!!!!", output_i);
                $display(" MyAnswer=%2h, Golden=%2h", code_out, golden[output_i]);
                pat_error = pat_error + 1;
            end
            else begin
                $display(">>>>> Comparison Pass @ pattern %0d <<<<<", output_i);
                $display(" coded=%2h  ", code_out);
            end
                
        end
        output_i =output_i +1;
    end
    if (pat_error === 0) begin
        $display("\n============= Congratulations =============");
        $display("             All patterns pass !");
        $display("============= Congratulations =============\n");
    end
    else begin
        $display("\nxxxxxxxxxxx Comparison Fail xxxxxxxxxxx");
        $display("            Total %0d errors\n  Please check your error messages...", pat_error);
        $display("xxxxxxxxxxx Comparison Fail xxxxxxxxxxx\n");
    end
//Print Out ASCII
    `ifdef ASCII
        case (pattern)
            2'd1: f_register = $fopen("plaintext1 ascii.dat");
            2'd2: f_register = $fopen("plaintext2 ascii.dat");
            2'd3: f_register = $fopen("plaintext3 ascii.dat");
        default: f_register = 0;
        endcase
  
        $display("%d : Start to write",$time);
            while (print_cnt < `PAT_LEN) begin
                $fwrite(f_register,"%c",ASCII[golden[print_cnt]]);
                print_cnt = print_cnt+1;
            end 
        $fclose(f_register);
        $display("****** All values of used registers and memory are dumped to register.txt ***********");
        $finish;
`endif

    $finish;
end
// ******************************************************************************


// early termination of simulation 
initial begin
  #(`END_CYCLE*`CYCLE);
  $display("\n============= Error =============");
  $display(  "   Simulation takes too long...  ");
  $display("============= Error =============\n");
  $finish;

end


endmodule


