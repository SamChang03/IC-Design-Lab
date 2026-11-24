module ECDSA_wrapper (
    input clk,
    input rst_n,
    input tvalid,
    input tlast,
    input [31:0] tdata,
    input [1:0] tdata_len,
    input [255:0] k,
    input [255:0] da,

    output tready,

    output ecdsa_valid,
    output [255:0] ecdsa_r,
    output [255:0] ecdsa_s
);
    wire internal_tready;
    wire internal_ecdsa_valid;
    wire [255:0] internal_ecdsa_r;
    wire [255:0] internal_ecdsa_s;

    ECDSA_top ecdsa_top_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tvalid(tvalid),
        .tlast(tlast),
        .tdata(tdata),
        .tdata_len(tdata_len),
        .k(k),
        .da(da),
        .tready(internal_tready),
        .ecdsa_valid(internal_ecdsa_valid),
        .ecdsa_r(internal_ecdsa_r),
        .ecdsa_s(internal_ecdsa_s)
    );

    assign tready = internal_tready;
    assign ecdsa_valid = internal_ecdsa_valid;
    assign ecdsa_r = internal_ecdsa_r;
    assign ecdsa_s = internal_ecdsa_s;

endmodule