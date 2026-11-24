module FIFO 
(
    input clk,
    input [3:0] state,
    input data_in,
    output [7:0] data_out
);

localparam IDLE = 4'd0;
localparam FIND_QR = 4'd1;
localparam SCAN_BLOCK_0 = 4'd10;
localparam SCAN_BLOCK_1 = 4'd11;
localparam SCAN_BLOCK_2 = 4'd12;
localparam SCAN_BLOCK_3 = 4'd13;
localparam DECODE_MASK = 4'd2;
localparam DECODE_CODEWORD = 4'd3;
localparam ALLDONE = 4'd4;

reg [7:0] FIFO,FIFO_n;
assign data_out = FIFO;

always @(*) begin
   FIFO_n = (state==DECODE_CODEWORD) ? {FIFO[6:0],data_in}: 7'b111_1111 ;
end

always @(posedge clk) begin
    FIFO <= FIFO_n;
end

endmodule