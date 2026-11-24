module sha1_padding (
    input clk,
    input rst_n,
    input enable,
    input tvalid,
    input tlast,
    input [31:0] tdata,
    input [2-1:0] tdata_len,
    input ext_valid,
    output reg tready,
    output reg padded_valid,
    output reg padded_last,
    output reg [31:0] padded_data
);

// finite state machine
localparam IDLE = 3'd0, DATA = 3'd1, PADDING = 3'd2, PADDING_WAIT = 3'd3, LENGTH = 3'd4, DONE = 3'd5;
reg [2:0] state, nxt_state;

// padding
reg [6-1:0] padding_cnt, nxt_padding_cnt;
reg [61-1:0] msg_len, nxt_msg_len;
reg nxt_tready;
reg nxt_padded_valid, nxt_padded_last;
wire [5-1:0] padding_shift = {tdata_len, 3'd0} - 1;
reg [31:0] nxt_padded_data;

always @(*) begin
    nxt_padding_cnt = padding_cnt;
    nxt_msg_len = msg_len;
    nxt_state = state;
    nxt_tready = 0;
    nxt_padded_data = 0;
    nxt_padded_valid = 0;
    nxt_padded_last = 0;
    case (state)
        IDLE: begin
            nxt_state = enable ? DATA : IDLE;
            nxt_padding_cnt = 0;
        end
        DATA: begin
            if(tvalid) begin
                if(tlast) begin
                    if(padding_cnt == 6'd52)begin
                        nxt_state = LENGTH;
                    end else begin
                        nxt_state = PADDING;
                    end
                end else if (padding_cnt == 6'd60) begin
                    nxt_state = IDLE;
                end
                if(tlast) begin
                    nxt_padded_data = {tdata, 1'b1} << (padding_shift);
                end else begin
                    nxt_padded_data = tdata;
                end
                nxt_padded_valid = 1;
                nxt_padding_cnt = padding_cnt + 4;
                nxt_msg_len = msg_len + 4 - tdata_len;
            end
            if(padding_cnt < 6'd56) begin
                nxt_tready = 1;
            end
        end
        PADDING: begin
            if(padding_cnt == 6'd52) begin
                nxt_state = LENGTH;
            end else if(padding_cnt == 6'd60) begin
                nxt_state = PADDING_WAIT;
            end
            nxt_padded_valid = 1;
            nxt_padding_cnt = padding_cnt + 4;
            nxt_padded_data = 32'd0;
        end
        PADDING_WAIT: begin
            if(ext_valid == 1'b0) begin
                nxt_state = PADDING;
            end
        end
        LENGTH: begin
            if(padding_cnt == 6'd60) begin
                nxt_state = DONE;
                nxt_padded_valid = 1;
                nxt_padded_last = 1;
                nxt_padding_cnt = padding_cnt + 4;
                nxt_padded_data = {msg_len[28:0], 3'd0};
            end else begin
                nxt_padded_valid = 1;
                nxt_padding_cnt = padding_cnt + 4;
                nxt_padded_data = msg_len[61-1:29];
            end
        end
        DONE: begin
            nxt_state = DONE;
        end
    endcase
end

always @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
        msg_len <= 0;
        tready <= 0;
    end else begin
        state <= nxt_state;
        padding_cnt <= nxt_padding_cnt;
        msg_len <= nxt_msg_len;
        tready <= nxt_tready;
        padded_data <= nxt_padded_data;
        padded_valid <= nxt_padded_valid;
        padded_last <= nxt_padded_last;
    end
end

endmodule