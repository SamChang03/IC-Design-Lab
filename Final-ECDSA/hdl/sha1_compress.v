module sha1_compress (
    input clk,
    input rst_n,
    input ext_valid,
    input ext_last,
    input [31:0] ext_data,
    output reg comp_valid,
    output reg comp_last,
    output reg [31:0] comp_data
);

// finite state machine
localparam COMPRESS_STAGE1 = 3'd0, COMPRESS_STAGE2 = 3'd1;
localparam OUTPUT_STAGE1 = 3'd2, OUTPUT_STAGE2 = 3'd3, OUTPUT_STAGE3 = 3'd4, OUTPUT_STAGE4 = 3'd5, OUTPUT_STAGE5 = 3'd6;
localparam DONE_STAGE = 3'd7;

reg [3-1:0] state, nxt_state;

// A, B, C, D, E
reg [31:0] H_in [0:4];
reg [31:0] nxt_H_in [0:4];
reg [31:0] A, B, C, D, E;
reg [31:0] f, K;
reg [31:0] temp;
reg [31:0] nxt_A, nxt_B, nxt_C, nxt_D, nxt_E;

// word counter
reg [7-1:0] word_cnt;
reg [7-1:0] nxt_word_cnt;

// output 
reg nxt_comp_valid;
reg nxt_comp_last;
reg [31:0] nxt_comp_data;


always@(*) begin
    nxt_H_in[0] = H_in[0]; nxt_H_in[1] = H_in[1]; 
    nxt_H_in[2] = H_in[2]; nxt_H_in[3] = H_in[3]; nxt_H_in[4] = H_in[4];
    nxt_A = A; nxt_B = B; nxt_C = C; nxt_D = D; nxt_E = E;
    nxt_word_cnt = word_cnt;
    f = 0; K = 0;
    temp = 0;
    nxt_state = state;

    nxt_comp_valid = 0;
    nxt_comp_last = 0;
    nxt_comp_data = 0;
    case (state)
        COMPRESS_STAGE1: begin
            nxt_state = COMPRESS_STAGE2;
            nxt_A = H_in[0]; nxt_B = H_in[1]; nxt_C = H_in[2];
            nxt_D = H_in[3]; nxt_E = H_in[4];
        end
        COMPRESS_STAGE2: begin
            if(ext_valid) begin
                if(word_cnt < 7'd20) begin
                    f = (B & C) | ((~B) & D);
                    K = 32'h5A827999;
                end else if(word_cnt < 7'd40) begin
                    f = B ^ C ^ D;
                    K = 32'h6ED9EBA1;
                end else if(word_cnt < 7'd60) begin
                    f = (B & C) | (B & D) | (C & D);
                    K = 32'h8F1BBCDC;
                end else begin
                    f = B ^ C ^ D;
                    K = 32'hCA62C1D6;
                end
                temp = {A[26:0], A[31:27]} + f + E + K + ext_data;
                nxt_E = D;
                nxt_D = C;
                nxt_C = {B[1:0], B[31:2]};
                nxt_B = A;
                nxt_A = temp;

                if(word_cnt == 7'd79) begin
                    if(ext_last) begin
                        nxt_state = OUTPUT_STAGE1;
                    end else begin
                        nxt_state = COMPRESS_STAGE1;
                    end
                    nxt_word_cnt = 0;
                    nxt_H_in[0] = nxt_A + H_in[0];
                    nxt_H_in[1] = nxt_B + H_in[1];
                    nxt_H_in[2] = nxt_C + H_in[2];
                    nxt_H_in[3] = nxt_D + H_in[3];
                    nxt_H_in[4] = nxt_E + H_in[4];
                end else begin
                    nxt_word_cnt = word_cnt + 1;
                end
            end
        end
        OUTPUT_STAGE1: begin
            nxt_state = OUTPUT_STAGE2;
            nxt_comp_valid = 1;
            nxt_comp_data = H_in[4];
        end
        OUTPUT_STAGE2: begin
            nxt_state = OUTPUT_STAGE3;
            nxt_comp_valid = 1;
            nxt_comp_data = H_in[3];
        end
        OUTPUT_STAGE3: begin
            nxt_state = OUTPUT_STAGE4;
            nxt_comp_valid = 1;
            nxt_comp_data = H_in[2];
        end
        OUTPUT_STAGE4: begin
            nxt_state = OUTPUT_STAGE5;
            nxt_comp_valid = 1;
            nxt_comp_data = H_in[1];
        end
        OUTPUT_STAGE5: begin
            nxt_state = DONE_STAGE;
            nxt_comp_valid = 1;
            nxt_comp_last = 1;
            nxt_comp_data = H_in[0];
        end
        DONE_STAGE: begin
            nxt_state = DONE_STAGE;
        end
    endcase
end

always@(posedge clk) begin
    if(!rst_n) begin
        state <= COMPRESS_STAGE1;
        H_in[0] <= 32'h67452301;
        H_in[1] <= 32'hEFCDAB89;
        H_in[2] <= 32'h98BADCFE;
        H_in[3] <= 32'h10325476;
        H_in[4] <= 32'hC3D2E1F0;
        word_cnt <= 0;
    end else begin
        state <= nxt_state;
        H_in[0] <= nxt_H_in[0]; H_in[1] <= nxt_H_in[1]; 
        H_in[2] <= nxt_H_in[2]; H_in[3] <= nxt_H_in[3]; H_in[4] <= nxt_H_in[4];
        A <= nxt_A; B <= nxt_B; C <= nxt_C; D <= nxt_D; E <= nxt_E;

        word_cnt <= nxt_word_cnt;

        comp_valid <= nxt_comp_valid;
        comp_last <= nxt_comp_last;
        comp_data <= nxt_comp_data;
    end
end


endmodule