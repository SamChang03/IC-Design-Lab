module karatsuba_multiply (
    input [255:0] A,    // 256-bit number A
    input [255:0] B,    // 256-bit number B
    output reg [511:0] product // 512-bit result
);
    reg [127:0] a, b, c, d;
    reg [255:0] ac, bd;
    reg [257:0] ab_cd;

    always @* begin
        // Step 1: Split A and B into two 32-bit numbers each
        a = A[255:128];
        b = A[127:0];
        c = B[255:128];
        d = B[127:0];

        // Step 2: Compute three products using recursive Karatsuba algorithm
        ac = a * c;
        bd = b * d;
        ab_cd = (a + b) * (c + d) - ac - bd;

        // Step 3: Combine results to form the final product
        product = {ac, 256'b0} + {ab_cd, 128'b0} + bd;
    end

endmodule