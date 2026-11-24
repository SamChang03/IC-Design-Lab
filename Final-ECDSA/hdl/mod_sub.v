module mod_sub (
    input [255:0] a,
    input [255:0] b,
    input [255:0] m,
    output [255:0] sub_result
);
    wire [257:0] diff, d_ff;

    assign diff = {2'b00,a} - {2'b00,b};
    assign d_ff = diff + {2'b00,m};
    assign sub_result = diff[257] ? d_ff[255:0] : diff[255:0];
endmodule 