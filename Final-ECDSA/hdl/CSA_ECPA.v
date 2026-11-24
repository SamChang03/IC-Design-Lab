module ECPA (
    input clk,
    input rst_n,
    input [255:0] m,

    input add_start,
    input [255:0] X_1,
    input [255:0] Y_1,
    input [255:0] Z_1,
    input [255:0] X_2,
    input [255:0] Y_2,
    input [255:0] Z_2,

    output reg add_done,
    output [255:0] X3,
    output [255:0] Y3,
    output [255:0] Z3
);

localparam IDLE = 5'd0;
localparam STEP_1 = 5'd1;
localparam STEP_2 = 5'd2;
localparam STEP_3 = 5'd3;
localparam STEP_4 = 5'd4;
localparam STEP_5 = 5'd5;
localparam STEP_6 = 5'd6;
localparam STEP_7 = 5'd7;
localparam STEP_8 = 5'd8;
localparam STEP_9 = 5'd9;
localparam STEP_10 = 5'd10;
localparam STEP_11 = 5'd11;
localparam STEP_12 = 5'd12;
localparam STEP_13 = 5'd13;
localparam DONE = 5'd20;

endmodule