module mod_add (
    input [255:0] a,
    input [255:0] b,
    input [255:0] m,
    output [255:0] add_result
);
    wire [257:0] sum, s_m;

    assign sum = {2'b00,a} + {2'b00,b};
    assign s_m = sum - {2'b00,m};
    assign add_result = s_m[257] ? sum[255:0] : s_m[255:0];
endmodule 