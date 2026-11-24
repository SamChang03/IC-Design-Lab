module sha1_extending (
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
reg [31:0] temp_data;

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
    temp_data = 0;
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
            if(word_cnt == 7'd79) begin
                nxt_state = EXT_STAGE1;
                nxt_word_cnt = 0;
                nxt_ext_last = ext_last_buf;
            end else begin
                nxt_word_cnt = word_cnt + 1;
            end
            nxt_ext_valid = 1;
            temp_data = word_fifo[13] ^ word_fifo[8] ^ word_fifo[2] ^ word_fifo[0];
            nxt_ext_data = {temp_data[30:0], temp_data[31]};
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
    end else begin
        state <= nxt_state;
        // output
        ext_valid <= nxt_ext_valid;
        ext_last_buf <= nxt_ext_last_buf;
        ext_last <= nxt_ext_last;
        ext_data <= nxt_ext_data;
        // counter
        word_cnt <= nxt_word_cnt;
        // fifo
        if(nxt_ext_valid) begin
            for(i = 0; i < 15; i = i + 1) begin
                word_fifo[i] <= word_fifo[i + 1];
            end
            word_fifo[15] <= nxt_ext_data;
        end
    end
end

endmodule
