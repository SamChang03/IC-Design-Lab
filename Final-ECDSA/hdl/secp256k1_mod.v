// module secp256k1_mod (
//     input [511:0] x,        // 輸入值（最大支援 512 位）
//     output [255:0] mod_out // 输出 256 位结果
// );
//     // p = 2^256 - 2^32 - 977
//     //reg [255:0] p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
//     //reg [31:0] subtract_val = 32'hffffffff;
//     //reg [31:0] const_val = 32'd977;

//     localparam p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
//     localparam subtract_val = 32'h00000001<<32;
//     localparam const_val = 32'd977;

//     wire [255:0] x_high, x_low;
//     wire [287:0] x_high_reduced,reduced_1; //(256+32) bits <-mutiply
//     wire [255:0] reduced_2;
//     wire [31:0] secp256k1_parameter;
    
//     assign secp256k1_parameter = (32'h00000001<<32) + 32'd977;

//     // 將輸入 x 分解為高位與低位
//     assign x_high = x[511:256]; // 高 256 位
//     assign x_low  = x[255:0];  // 低 256 位

//     // 高位縮減：計算 x_high * (2^32 + 977)
//     assign x_high_reduced = x_high * secp256k1_parameter;

//     // 合併高位與低位：逐步縮減
//     assign reduced_1 = x_high_reduced[255:0] + x_low;
//     assign reduced_2 = (x_high_reduced[287:256]*secp256k1_parameter) 
//                        + reduced_1[255:0]; 

//     //assign output
//     assign mod_out = (reduced_2 >= p) ? (reduced_2 - p) : reduced_2;

// endmodule

module secp256k1_mod (
    input [511:0] x,         // 輸入值（最大支援 512 位）
    output [255:0] mod_out   // 輸出 256 位結果
);

    // p = 2^256 - 2^32 - 977
    localparam p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    localparam secp256k1_parameter = 36'h1000003D1; // 2^32 + 977

    // 分解輸入 x 為高位與低位
    wire [255:0] x_high = x[511:256]; // 高 256 位
    wire [255:0] x_low  = x[255:0];  // 低 256 位

    // 中間計算結果
    wire [290:0] x_high_reduced = x_high * secp256k1_parameter + x_low; // 高位縮減
    // wire [255:0] reduced_1 = x_high_reduced[255:0] + x_low;     // 合併高位與低位
    wire [255:0] reduced_1 = x_high_reduced[255:0];

    // 繼續縮減
    wire [290:0] reduced_2_temp = x_high_reduced[290:256] * secp256k1_parameter + reduced_1;
    wire [255:0] reduced_2 = (reduced_2_temp >= p) ? (reduced_2_temp - p) : reduced_2_temp; // 縮減到 256 位

    // 最終模數運算
    assign mod_out = reduced_2[255:0];

endmodule
