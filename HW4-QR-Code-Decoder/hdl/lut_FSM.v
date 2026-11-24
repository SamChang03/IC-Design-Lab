module lut_FSM 
(
    input clk,
    input srst_n,
    input [5:0] i,
    input [5:0] j,
    input [3:0] state,
    input [1:0] type,
    input codeword_done,
    input finish,

    output reg [5:0] i_next,
    output reg [5:0] j_next
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

localparam degree_0 = 2'd0;
localparam degree_90 = 2'd1;
localparam degree_180 = 2'd2;
localparam degree_270 = 2'd3;

reg [3-1:0] cnt_bit, cnt_bit_n; // count bits order
reg [5-1:0] cnt_block, cnt_block_n; // count witch block

always @(*) begin
    //Default case
    cnt_bit_n = cnt_bit;
    cnt_block_n = cnt_block;
    i_next = i;
    j_next = j;

    if (codeword_done | finish) begin
        cnt_bit_n = 0;
        cnt_block_n = 0;
    end

    else if (state == DECODE_CODEWORD) begin
    cnt_bit_n = cnt_bit +1;
    case (type)
        degree_0:begin
           case (cnt_block)
            5'd0: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd1: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd2: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd3: begin
                if (cnt_bit==7) begin
                    i_next = i;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd4: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd5: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd6: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd7: begin
                if (cnt_bit==7) begin
                    i_next = i;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd8: begin
                if (cnt_bit==7) begin
                    i_next = i-6;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd9: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd10: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==6 | cnt_bit==5 ) begin
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd11: begin
               if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end 
            end
            5'd12: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==3) begin
                    i_next = i+6;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd13: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==1) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else if (cnt_bit==5) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd14: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==0 | cnt_bit==2 ) begin
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit==1) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd15: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end 
            end
            5'd16: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end 
            end
            5'd17: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit==2) begin
                    i_next = i-2;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd18: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit==6) begin
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd19: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd20: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit==2) begin
                    i_next = i+2;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd21: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd22: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd23: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd24: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit==6) begin
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd25: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd26: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd27: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = 0;
                    j_next = 0;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end   
        endcase 
        end
        degree_90:begin
             case (cnt_block)
            5'd0: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd1: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd2: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd3: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd4: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd5: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd6: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd7: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd8: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-6;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd9: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd10: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==6 | cnt_bit==5 ) begin
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd11: begin
               if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end 
            end
            5'd12: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==3) begin
                    i_next = i-1;
                    j_next = j+6;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd13: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==1) begin
                    i_next = i-1;
                    j_next = j+1;
                end
                else if (cnt_bit==5) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd14: begin
                if (cnt_bit==7) begin
                    i_next = i;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==0 | cnt_bit==2 ) begin
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit==1) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j-1;
                end
            end
            5'd15: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end 
            end
            5'd16: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end 
            end
            5'd17: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit==2) begin
                    i_next = i-1;
                    j_next = j-2;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd18: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit==6) begin
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd19: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd20: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit==2) begin
                    i_next = i-1;
                    j_next = j+2;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd21: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd22: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd23: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd24: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit==6) begin
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j+1;
                end
            end
            5'd25: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd26: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd27: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i+1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end   
        endcase  
        end
        degree_180:begin
            case (cnt_block)
            5'd0: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd1: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd2: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd3: begin
                if (cnt_bit==7) begin
                    i_next = i;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd4: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd5: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd6: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd7: begin
                if (cnt_bit==7) begin
                    i_next = i;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd8: begin
                if (cnt_bit==7) begin
                    i_next = i+6;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd9: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd10: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==6 | cnt_bit==5 ) begin
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd11: begin
               if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end 
            end
            5'd12: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==3) begin
                    i_next = i-6;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd13: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==1) begin
                    i_next = i-1;
                    j_next = j-1;
                end
                else if (cnt_bit==5) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd14: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==0 | cnt_bit==2 ) begin
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit==1) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i+1;
                    j_next = j;
                end
            end
            5'd15: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end 
            end
            5'd16: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end 
            end
            5'd17: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit==2) begin
                    i_next = i+2;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd18: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit==6) begin
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd19: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd20: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit==2) begin
                    i_next = i-2;
                    j_next = j-1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd21: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd22: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd23: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd24: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit==6) begin
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j-1;
                end
            end
            5'd25: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd26: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i;
                    j_next = j+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd27: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = 0;
                    j_next = 0;
                end
                else if (cnt_bit[0]) begin
                    i_next = i;
                    j_next = j+1;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end   
        endcase 
        end
        degree_270:begin
             case (cnt_block)
            5'd0: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd1: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd2: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd3: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd4: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd5: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd6: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd7: begin
                if (cnt_bit==7) begin
                    i_next = i-1;
                    j_next = j;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd8: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+6;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd9: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd10: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==6 | cnt_bit==5 ) begin
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd11: begin
               if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end 
            end
            5'd12: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j-1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==3) begin
                    i_next = i+1;
                    j_next = j-6;
                end
                else if (cnt_bit[0]) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd13: begin
                if (cnt_bit==7) begin
                    i_next = i+1;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==1) begin
                    i_next = i+1;
                    j_next = j-1;
                end
                else if (cnt_bit==5) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i-1;
                    j_next = j;
                end
            end
            5'd14: begin
                if (cnt_bit==7) begin
                    i_next = i;
                    j_next = j+1;
                    cnt_block_n = cnt_block+1;
                end
                else if (cnt_bit==0 | cnt_bit==2 ) begin
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit==1) begin
                    i_next = i+1;
                    j_next = j+1;
                end
                else begin
                    i_next = i;
                    j_next = j+1;
                end
            end
            5'd15: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end 
            end
            5'd16: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end 
            end
            5'd17: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit==2) begin
                    i_next = i+1;
                    j_next = j+2;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd18: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit==6) begin
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd19: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd20: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit==2) begin
                    i_next = i+1;
                    j_next = j-2;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd21: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd22: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd23: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd24: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit==6) begin
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j-1;
                end
            end
            5'd25: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd26: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end
            5'd27: begin
                if (cnt_bit==7) begin
                    cnt_block_n = cnt_block+1;
                    i_next = i-1;
                    j_next = j;
                end
                else if (cnt_bit[0]) begin
                    i_next = i-1;
                    j_next = j;
                end
                else begin
                    i_next = i+1;
                    j_next = j+1;
                end
            end   
        endcase  
        end  
    endcase
        
    end
end

//squential
always @(posedge clk) begin
    if (~srst_n) begin
        cnt_bit <= 0;
        cnt_block <= 0;
    end
    else begin
        cnt_bit <= cnt_bit_n;
        cnt_block <= cnt_block_n;
    end
end

endmodule