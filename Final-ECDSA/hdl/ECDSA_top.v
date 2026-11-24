module ECDSA_top (
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

    // sha256_top module
    wire internal_tready;
    wire internal_sha256_valid;
    wire internal_sha256_last;
    wire [31:0] internal_sha256_out;

    // signing module
    wire internal_sign_r_ready;
    wire internal_sign_valid;
    wire [255:0] internal_sign_s;

    // ECC_top module
    wire internal_ecc_valid;
    wire internal_ecc_last;
    wire [255:0] internal_ecc_data;

    // Instance of sha256_top
    sha256_top sha256_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tvalid(tvalid),
        .tlast(tlast),
        .tdata(tdata),
        .tdata_len(tdata_len),
        .r_ready(internal_sign_r_ready),
        .tready(internal_tready),
        .sha256_valid(internal_sha256_valid),
        .sha256_last(internal_sha256_last),
        .sha256_out(internal_sha256_out)
    );
    // Assign top module outputs
    assign tready = internal_tready;


    // Instance of ECC_top
    ECC_top ecc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .SHA_ECC_valid(tvalid),
        // .SHA_ECC_last(tlast),
        .SHA_ECC_data(k),
        // .SHA_ECC_ready(internal_ecc_ready),
        .ECC_SIGN_valid(internal_ecc_valid),
        // .ECC_SIGN_last(internal_ecc_last),
        .ECC_SIGN_data(internal_ecc_data)
    );
    // Assign top module outputs
    assign ecdsa_r = internal_ecc_data;

    // Instance of signing
    signing signing_inst (
        .clk(clk),
        .rst_n(rst_n),
        .t_valid(tvalid),
        .k(k),
        .da(da),
        .sha256_valid(internal_sha256_valid),
        .sha256_last(internal_sha256_last),
        .sha256_data(internal_sha256_out),
        .ml_valid(internal_ecc_valid),
        .ml_data(internal_ecc_data),
        .r_ready(internal_sign_r_ready),
        .sign_valid(internal_sign_valid),
        .sign_result(internal_sign_s)
    );
    // Assign top module outputs
    assign ecdsa_valid = internal_sign_valid;
    assign ecdsa_s = internal_sign_s;

endmodule