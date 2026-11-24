module sha256_extending (
    input clk,
    input rst_n,
    input padded_valid,
    input padded_last,
    input [31:0] padded_data,
    output reg ext_valid,
    output reg ext_last,
    output reg [31:0] ext_data
);

// finite state machine
localparam EXT_STAGE1 = 1'b0, EXT_STAGE2 = 1'b1;
reg [1-1:0] state, nxt_state;

// counter
reg [7-1:0] word_cnt, nxt_word_cnt;

// calculate temp
reg [31:0] s0, s1;

// output
reg nxt_ext_valid, nxt_ext_last;
reg ext_last_buf, nxt_ext_last_buf;
reg [31:0] nxt_ext_data;

// word fifo
reg [31:0] word_fifo [0:15];

// state transition
always@(*) begin
    nxt_state = state;
    nxt_word_cnt = word_cnt;
    nxt_ext_valid = 0;
    nxt_ext_last = 0;
    nxt_ext_last_buf = ext_last_buf;
    nxt_ext_data = 0;
    s0 = 0;
    s1 = 0;
    case (state)
        EXT_STAGE1: begin
            if(padded_valid) begin
                if(word_cnt == 7'd15) begin
                    nxt_state = EXT_STAGE2;
                end
                nxt_word_cnt = word_cnt + 1;
                nxt_ext_valid = 1;
                nxt_ext_last_buf = padded_last;
                nxt_ext_data = padded_data;
            end
        end
        EXT_STAGE2: begin
            if(word_cnt == 7'd63) begin
                nxt_state = EXT_STAGE1;
                nxt_word_cnt = 0;
                nxt_ext_last = ext_last_buf;
            end else begin
                nxt_word_cnt = word_cnt + 1;
            end
            nxt_ext_valid = 1;
            s0 = {word_fifo[1][6:0], word_fifo[1][31:7]} ^ {word_fifo[1][17:0], word_fifo[1][31:18]} ^ (word_fifo[1] >> 3);
            s1 = {word_fifo[14][16:0], word_fifo[14][31:17]} ^ {word_fifo[14][18:0], word_fifo[14][31:19]} ^ (word_fifo[14] >> 10);
            nxt_ext_data = word_fifo[0] + s0 + word_fifo[9] + s1;
        end
    endcase
end

integer i;
always@(posedge clk) begin
    if(!rst_n) begin
        state <= EXT_STAGE1;
        word_cnt <= 0;
        ext_valid <= 0;
        ext_last <= 0;
        ext_last_buf <= 0;
    end else begin
        state <= nxt_state;
        // output
        ext_valid <= nxt_ext_valid;
        ext_last <= nxt_ext_last;
        ext_last_buf <= nxt_ext_last_buf;
        // counter
        word_cnt <= nxt_word_cnt;
    end
    // fifo
    if(nxt_ext_valid) begin
        for(i = 0; i < 15; i = i + 1) begin
            word_fifo[i] <= word_fifo[i + 1];
        end
        word_fifo[15] <= nxt_ext_data;
    end
    ext_data <= nxt_ext_data;
end

endmodule