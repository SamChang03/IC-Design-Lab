module sha256_compress (
    input clk,
    input rst_n,
    input ext_valid,
    input ext_last,
    input [31:0] ext_data,
    input r_ready,
    output reg comp_valid,
    output reg comp_last,
    output reg [31:0] comp_data
);

// finite state machine
localparam COMPRESS_STAGE1 = 3'd0, COMPRESS_STAGE2 = 3'd1;
localparam OUTPUT_STAGE = 3'd2;
localparam DONE_STAGE = 3'd3;

reg [3-1:0] state, nxt_state;

// A, B, C, D, E
reg [31:0] H_in [0:7];
reg [31:0] nxt_H_in [0:7];
reg [31:0] A, B, C, D, E, F, G, H;
reg [31:0] s0, s1, ch, maj, t1, t2;
reg [31:0] nxt_A, nxt_B, nxt_C, nxt_D, nxt_E, nxt_F, nxt_G, nxt_H;

// constants fifo
reg [31:0] constants_fifo [0:63];
wire [31:0] top_constants;
assign top_constants = constants_fifo[0];

// word counter
reg [7-1:0] word_cnt;
reg [7-1:0] nxt_word_cnt;

// output counter
reg [3-1:0] output_cnt;
reg [3-1:0] nxt_output_cnt;

// output 
reg nxt_comp_valid;
reg nxt_comp_last;
reg [31:0] nxt_comp_data;


always@(*) begin
    nxt_H_in[0] = H_in[0]; nxt_H_in[1] = H_in[1]; nxt_H_in[2] = H_in[2]; nxt_H_in[3] = H_in[3];
    nxt_H_in[4] = H_in[4]; nxt_H_in[5] = H_in[5]; nxt_H_in[6] = H_in[6]; nxt_H_in[7] = H_in[7];
    nxt_A = A; nxt_B = B; nxt_C = C; nxt_D = D; nxt_E = E; nxt_F = F; nxt_G = G; nxt_H = H;
    nxt_word_cnt = word_cnt;
    nxt_state = state;
    // temp variables
    s0 = 0; s1 = 0; ch = 0; maj = 0; t1 = 0; t2 = 0;

    nxt_comp_valid = 0;
    nxt_comp_last = 0;
    nxt_comp_data = 0;
    nxt_output_cnt = output_cnt;
    case (state)
        COMPRESS_STAGE1: begin
            nxt_state = COMPRESS_STAGE2;
            nxt_A = H_in[0]; nxt_B = H_in[1]; nxt_C = H_in[2]; nxt_D = H_in[3]; 
            nxt_E = H_in[4]; nxt_F = H_in[5]; nxt_G = H_in[6]; nxt_H = H_in[7];
        end
        COMPRESS_STAGE2: begin
            if(ext_valid) begin
                s0 = {A[1:0], A[31:2]} ^ {A[12:0], A[31:13]} ^ {A[21:0], A[31:22]};
                maj = (A & B) ^ (A & C) ^ (B & C);
                t2 = s0 + maj;
                s1 = {E[5:0], E[31:6]} ^ {E[10:0], E[31:11]} ^ {E[24:0], E[31:25]};
                ch = (E & F) ^ ((~E) & G);
                t1 = H + s1 + ch + top_constants + ext_data;
                nxt_H = G;
                nxt_G = F;
                nxt_F = E;
                nxt_E = D + t1;
                nxt_D = C;
                nxt_C = B;
                nxt_B = A;
                nxt_A = t1 + t2;

                if(word_cnt == 7'd63) begin
                    if(ext_last) begin
                        nxt_output_cnt = 7;
                        nxt_state = OUTPUT_STAGE;
                    end else begin
                        nxt_state = COMPRESS_STAGE1;
                    end
                    nxt_word_cnt = 0;
                    nxt_H_in[0] = nxt_A + H_in[0];
                    nxt_H_in[1] = nxt_B + H_in[1];
                    nxt_H_in[2] = nxt_C + H_in[2];
                    nxt_H_in[3] = nxt_D + H_in[3];
                    nxt_H_in[4] = nxt_E + H_in[4];
                    nxt_H_in[5] = nxt_F + H_in[5];
                    nxt_H_in[6] = nxt_G + H_in[6];
                    nxt_H_in[7] = nxt_H + H_in[7];
                end else begin
                    nxt_word_cnt = word_cnt + 1;
                end
            end
        end
        OUTPUT_STAGE: begin        
            if(r_ready) begin
                if(output_cnt == 3'd0) begin
                    nxt_state = DONE_STAGE;
                    nxt_comp_last = 1;
                end
                nxt_output_cnt = output_cnt - 1;
                nxt_comp_valid = 1;
                nxt_comp_data = H_in[output_cnt];
            end
        end
        DONE_STAGE: begin
            nxt_state = DONE_STAGE;
        end
    endcase
end

integer i;
always@(posedge clk) begin
    if(!rst_n) begin
        state <= COMPRESS_STAGE1;
        H_in[0] <= 32'h6A09E667; H_in[1] <= 32'hBB67AE85; H_in[2] <= 32'h3C6EF372; H_in[3] <= 32'hA54FF53A;
        H_in[4] <= 32'h510E527F; H_in[5] <= 32'h9B05688C; H_in[6] <= 32'h1F83D9AB; H_in[7] <= 32'h5BE0CD19;
        word_cnt <= 0;
        output_cnt <= 0;
        comp_valid <= 0;
        comp_last <= 0;
        // initialize constants fifo
        constants_fifo[0]  <= 32'h428A2F98;
        constants_fifo[1]  <= 32'h71374491;
        constants_fifo[2]  <= 32'hB5C0FBCF;
        constants_fifo[3]  <= 32'hE9B5DBA5;
        constants_fifo[4]  <= 32'h3956C25B;
        constants_fifo[5]  <= 32'h59F111F1;
        constants_fifo[6]  <= 32'h923F82A4;
        constants_fifo[7]  <= 32'hAB1C5ED5;
        constants_fifo[8]  <= 32'hD807AA98;
        constants_fifo[9]  <= 32'h12835B01;
        constants_fifo[10] <= 32'h243185BE;
        constants_fifo[11] <= 32'h550C7DC3;
        constants_fifo[12] <= 32'h72BE5D74;
        constants_fifo[13] <= 32'h80DEB1FE;
        constants_fifo[14] <= 32'h9BDC06A7;
        constants_fifo[15] <= 32'hC19BF174;
        constants_fifo[16] <= 32'hE49B69C1;
        constants_fifo[17] <= 32'hEFBE4786;
        constants_fifo[18] <= 32'h0FC19DC6;
        constants_fifo[19] <= 32'h240CA1CC;
        constants_fifo[20] <= 32'h2DE92C6F;
        constants_fifo[21] <= 32'h4A7484AA;
        constants_fifo[22] <= 32'h5CB0A9DC;
        constants_fifo[23] <= 32'h76F988DA;
        constants_fifo[24] <= 32'h983E5152;
        constants_fifo[25] <= 32'hA831C66D;
        constants_fifo[26] <= 32'hB00327C8;
        constants_fifo[27] <= 32'hBF597FC7;
        constants_fifo[28] <= 32'hC6E00BF3;
        constants_fifo[29] <= 32'hD5A79147;
        constants_fifo[30] <= 32'h06CA6351;
        constants_fifo[31] <= 32'h14292967;
        constants_fifo[32] <= 32'h27B70A85;
        constants_fifo[33] <= 32'h2E1B2138;
        constants_fifo[34] <= 32'h4D2C6DFC;
        constants_fifo[35] <= 32'h53380D13;
        constants_fifo[36] <= 32'h650A7354;
        constants_fifo[37] <= 32'h766A0ABB;
        constants_fifo[38] <= 32'h81C2C92E;
        constants_fifo[39] <= 32'h92722C85;
        constants_fifo[40] <= 32'hA2BFE8A1;
        constants_fifo[41] <= 32'hA81A664B;
        constants_fifo[42] <= 32'hC24B8B70;
        constants_fifo[43] <= 32'hC76C51A3;
        constants_fifo[44] <= 32'hD192E819;
        constants_fifo[45] <= 32'hD6990624;
        constants_fifo[46] <= 32'hF40E3585;
        constants_fifo[47] <= 32'h106AA070;
        constants_fifo[48] <= 32'h19A4C116;
        constants_fifo[49] <= 32'h1E376C08;
        constants_fifo[50] <= 32'h2748774C;
        constants_fifo[51] <= 32'h34B0BCB5;
        constants_fifo[52] <= 32'h391C0CB3;
        constants_fifo[53] <= 32'h4ED8AA4A;
        constants_fifo[54] <= 32'h5B9CCA4F;
        constants_fifo[55] <= 32'h682E6FF3;
        constants_fifo[56] <= 32'h748F82EE;
        constants_fifo[57] <= 32'h78A5636F;
        constants_fifo[58] <= 32'h84C87814;
        constants_fifo[59] <= 32'h8CC70208;
        constants_fifo[60] <= 32'h90BEFFFA;
        constants_fifo[61] <= 32'hA4506CEB;
        constants_fifo[62] <= 32'hBEF9A3F7;
        constants_fifo[63] <= 32'hC67178F2;
    end else begin
        state <= nxt_state;
        H_in[0] <= nxt_H_in[0]; H_in[1] <= nxt_H_in[1]; H_in[2] <= nxt_H_in[2]; H_in[3] <= nxt_H_in[3];
        H_in[4] <= nxt_H_in[4]; H_in[5] <= nxt_H_in[5]; H_in[6] <= nxt_H_in[6]; H_in[7] <= nxt_H_in[7];
        // update constants fifo
        if(ext_valid) begin
            for(i = 0; i < 63; i = i + 1) begin
                constants_fifo[i] <= constants_fifo[i+1];
            end
            constants_fifo[63] <= top_constants;
        end
        word_cnt <= nxt_word_cnt;
        output_cnt <= nxt_output_cnt;
        comp_valid <= nxt_comp_valid;
        comp_last <= nxt_comp_last;
    end
    A <= nxt_A; B <= nxt_B; C <= nxt_C; D <= nxt_D; E <= nxt_E; F <= nxt_F; G <= nxt_G; H <= nxt_H;
    comp_data <= nxt_comp_data;
end


endmodule