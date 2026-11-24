module sha1_top (
    input clk,
    input rst_n,
    input tvalid,
    input tlast,
    input [31:0] tdata,
    input [2-1:0] tdata_len,
    output tready,
    output sha1_valid,
    output sha1_last,
    output [31:0] sha1_out
);

// finite state machine
localparam LOAD = 3'd0, EXTEND = 3'd1, DONE = 3'd2;
reg [2:0] state, next_state;

// input buffer
reg tvalid_buf;
reg tlast_buf;
reg [31:0] tdata_buf;
reg [2-1:0] tdata_len_buf;

// sha1 padding
reg padding_enable;
wire padded_tready;
wire padded_valid;
wire padded_last;
wire [31:0] padded_data;

// sha1 extending
wire ext_valid;
wire ext_last;
wire [31:0] ext_data;

// sha1 compressing
wire comp_valid;
wire comp_last;
wire [31:0] comp_data;

// instance of sha1 padding
sha1_padding padding_inst (
    .clk(clk),
    .rst_n(rst_n),
    .enable(padding_enable),
    .tvalid(tvalid_buf),
    .tlast(tlast_buf),
    .tdata(tdata_buf),
    .tdata_len(tdata_len_buf),
    .ext_valid(ext_valid),
    .tready(padded_tready),
    .padded_valid(padded_valid),
    .padded_last(padded_last),
    .padded_data(padded_data)
);

// instance of sha1 extending
sha1_extending extending_inst (
    .clk(clk),
    .rst_n(rst_n),
    .padded_valid(padded_valid),
    .padded_last(padded_last),
    .padded_data(padded_data),
    .ext_valid(ext_valid),
    .ext_last(ext_last),
    .ext_data(ext_data)
);

// instance of sha1 compressing
sha1_compress compress_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ext_valid(ext_valid),
    .ext_last(ext_last),
    .ext_data(ext_data),
    .comp_valid(comp_valid),
    .comp_last(comp_last),
    .comp_data(comp_data)
);

// output tready
assign tready = padded_tready;
assign sha1_valid = comp_valid;
assign sha1_out = comp_data;
assign sha1_last = comp_last;


always @(*) begin
    padding_enable = 0;
    next_state = state;
    case (state)
        LOAD: begin
            if(padded_valid) begin
                next_state = EXTEND;
            end
            padding_enable = 1;
        end
        EXTEND: begin
            if(ext_last) begin
                next_state = DONE;
            end else if(!ext_valid) begin
                next_state = LOAD;
            end
        end
        DONE: begin
            // do nothing
        end
    endcase
end

always @(posedge clk) begin
    if (!rst_n) begin
        state <= LOAD;
    end else begin
        // state
        state <= next_state;
        // input buffer
        tvalid_buf <= tvalid;
        tlast_buf <= tlast;
        tdata_buf <= tdata;
        tdata_len_buf <= tdata_len;
    end
end

endmodule