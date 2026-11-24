module FSM(
    input clk,
    input srst_n,             
    input start,                         
    input mask_done,
    input find_done,
    input [7:0] output_FIFO,
    input [5:0] i_find_32,
    input [5:0] j_find_32,
    input [5:0] loc_y,
    input [5:0] loc_x,
    input [1:0] type,
    input checking,
    input no_QRcode,      

    output reg [3:0] state,
    output reg find_start,
    output reg mask_start,
    output reg codeword_start,
    output reg [11:0] sram_raddr,
    output reg [5:0] i,
    output reg [5:0] j,
    output valid,
    output reg [2:0] cnt_block,
    output reg is_rank_b,
    output reg finish         
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

reg [3:0] state_n,state_freeze,state_freeze_n;
reg [11:0] sram_raddr_n;
reg [5:0] i_n,j_n;
reg [2:0] cnt,cnt_n;
reg [7:0] cnt_valid,cnt_valid_n;
reg [2:0] cnt_ignore,cnt_ignore_n;
reg [2:0] cnt_qrcode, cnt_qrcode_n;
reg [2:0] cnt_block_n;
reg [7:0] output_len_n,output_len;
reg valid_reg, is_rank_b_n;
reg codeword_done;

wire [5:0] i_next,j_next; //next for decode codeword

assign valid = (cnt_valid == 0) ? 0 :valid_reg;

//FSM
always @(*) begin
    //Default case
    mask_start = 0;
    codeword_start = 0;
    find_start = 0;
    sram_raddr_n = i_n*64+j_n;
    state_n = IDLE;
    state_freeze_n = state_freeze;
    cnt_n =0;
    cnt_valid_n=0;
    cnt_ignore_n =0;
    valid_reg = 0;
    finish = 0;
    cnt_qrcode_n = cnt_qrcode;
    cnt_block_n = cnt_block;
    codeword_done =0;
    is_rank_b_n =is_rank_b;
        //case condition
        case (state) //synopsis parallel case
        IDLE:begin
            i_n = 0;
            j_n = 0;
            if (start) begin
                state_n = SCAN_BLOCK_0;
                find_start = 1;
            end
        end
        SCAN_BLOCK_0:begin
            find_start = 1;
            i_n = i_find_32;
            j_n = j_find_32;
            state_n = SCAN_BLOCK_0;
            state_freeze_n = SCAN_BLOCK_0;
            
            if (find_done) begin
                state_n = DECODE_MASK;
                mask_start = 1;
                case (type) //i_n/j_n for mask
                    degree_0: begin
                        i_n = loc_y + 8;
                        j_n = loc_x + 4;
                    end
                    degree_90: begin
                        i_n = loc_y - 4;
                        j_n = loc_x + 8;
                    end
                    degree_180: begin
                        i_n = loc_y - 8;
                        j_n = loc_x - 4;
                    end
                    degree_270: begin
                        i_n = loc_y + 4;
                        j_n = loc_x - 8;
                    end 
                endcase
            end
            else if ((i>26)&( ~checking)) begin // end of box;
                is_rank_b_n = 1;
                state_n = SCAN_BLOCK_0;
                find_start = 1;
                i_n = i_find_32;
                j_n = j_find_32;
            end
            
            
        end

        SCAN_BLOCK_1:begin
            find_start = 1;
            i_n = i_find_32;
            j_n = j_find_32+32;
            state_n = SCAN_BLOCK_1;
            state_freeze_n = SCAN_BLOCK_1;
            if ((i==8 & j==56 & ~checking)|no_QRcode) begin // end of box;
                state_n = SCAN_BLOCK_2;
                cnt_block_n = cnt_block +1;
                i_n = 32;
                j_n = 0;
            end
            else if (find_done) begin
                state_n = DECODE_MASK;
                mask_start = 1;
                case (type) //i_n/j_n for mask
                    degree_0: begin
                        i_n = loc_y + 8;
                        j_n = loc_x + 4;
                    end
                    degree_90: begin
                        i_n = loc_y - 4;
                        j_n = loc_x + 8;
                    end
                    degree_180: begin
                        i_n = loc_y - 8;
                        j_n = loc_x - 4;
                    end
                    degree_270: begin
                        i_n = loc_y + 4;
                        j_n = loc_x - 8;
                    end 
                endcase
            end
        end

        SCAN_BLOCK_2:begin
            find_start = 1;
            i_n = i_find_32+32;
            j_n = j_find_32;
            state_n = SCAN_BLOCK_2;
            state_freeze_n = SCAN_BLOCK_2;
            if ((i==40 & j==24 & ~checking)|no_QRcode) begin // end of box;
                state_n = SCAN_BLOCK_3;
                cnt_block_n = cnt_block +1;
                i_n = 32;
                j_n = 32;
            end
            else if (find_done) begin
                state_n = DECODE_MASK;
                mask_start = 1;
                case (type) //i_n/j_n for mask
                    degree_0: begin
                        i_n = loc_y + 8;
                        j_n = loc_x + 4;
                    end
                    degree_90: begin
                        i_n = loc_y - 4;
                        j_n = loc_x + 8;
                    end
                    degree_180: begin
                        i_n = loc_y - 8;
                        j_n = loc_x - 4;
                    end
                    degree_270: begin
                        i_n = loc_y + 4;
                        j_n = loc_x - 8;
                    end 
                endcase
            end
        end

        SCAN_BLOCK_3:begin
            find_start = 1;
            i_n = i_find_32+32;
            j_n = j_find_32+32;
            state_n = SCAN_BLOCK_3;
            if ((cnt_qrcode == 4)|(i==39 & j==56 & ~checking)|no_QRcode) begin // final eye may appear;
                finish = 1;
                cnt_qrcode_n = 0;
                i_n = 0;
                j_n = 0;
            end

            else if (find_done) begin
                state_n = DECODE_MASK;
                mask_start = 1;
                case (type) //i_n/j_n for mask
                    degree_0: begin
                        i_n = loc_y + 8;
                        j_n = loc_x + 4;
                    end
                    degree_90: begin
                        i_n = loc_y - 4;
                        j_n = loc_x + 8;
                    end
                    degree_180: begin
                        i_n = loc_y - 8;
                        j_n = loc_x - 4;
                    end
                    degree_270: begin
                        i_n = loc_y + 4;
                        j_n = loc_x - 8;
                    end 
                endcase
            end
        end

        DECODE_MASK:begin
            i_n = i;
            j_n = j - 1;

            state_n = DECODE_MASK;
            if (mask_done) begin
                state_n = DECODE_CODEWORD;
                codeword_start = 1;
                i_n = loc_y + 24;
                j_n = loc_x + 24;
                case (type)
                    degree_0: begin
                        i_n = loc_y + 24;
                        j_n = loc_x + 24;
                    end
                    degree_90: begin
                        i_n = loc_y - 24;
                        j_n = loc_x + 24;
                    end
                    degree_180: begin
                        i_n = loc_y - 24;
                        j_n = loc_x - 24;
                    end
                    degree_270: begin
                        i_n = loc_y + 24;
                        j_n = loc_x - 24;
                    end
                endcase
            end
            else begin
                casez (type)
                    degree_0: begin
                        i_n = i;
                        j_n = j - 1;
                    end
                    degree_90: begin
                        i_n = i + 1;
                        j_n = j;
                    end
                    degree_180: begin
                        i_n = i;
                        j_n = j + 1;
                    end
                    degree_270: begin
                        i_n = i - 1;
                        j_n = j ;
                    end 
            endcase
            end
        end
        DECODE_CODEWORD:begin
            state_n = DECODE_CODEWORD;
            i_n = i_next;
            j_n = j_next;

            cnt_ignore_n = cnt_ignore +1 ;
            cnt_n = cnt;
            cnt_valid_n=cnt_valid;
            

            //ignore the forward bits
            if (cnt_ignore == 5) begin
                cnt_ignore_n = cnt_ignore;
                cnt_n = cnt + 1;
            end

            // detiermine valid & finish
            if (cnt == 7 & cnt_valid == output_len) begin
                i_n = 0;
                j_n = 0;
                valid_reg = 1;
                cnt_qrcode_n = cnt_qrcode +1;
                cnt_block_n = cnt_block +1;
                codeword_done =1;
                state_n = FIND_QR;
                finish = (is_rank_b & (cnt_block==0)) ? 1 : 0;

                case (state_freeze)
                    SCAN_BLOCK_0: state_n = SCAN_BLOCK_1; 
                    SCAN_BLOCK_1: state_n = SCAN_BLOCK_2;
                    SCAN_BLOCK_2: state_n = SCAN_BLOCK_3;
                endcase
            end
            else if (cnt == 7) begin
                valid_reg = 1;
                cnt_valid_n = cnt_valid +1; 
            end
        end
        default:begin
            i_n = 0;
            j_n = 0;
            if (start) begin
                state_n = FIND_QR;
                find_start = 1;
            end
        end
    endcase  
end

always @(*) begin
    // detiermine output legnth
    output_len_n = output_len;
    if (cnt_valid==0 & valid_reg) begin
        output_len_n = output_FIFO;
    end
end

//Decide address
lut_FSM lut_FSM_u0 
(
    //input
    .clk(clk),
    .srst_n(srst_n),
    .i(i),
    .j(j),
    .codeword_done(codeword_done),
    .finish(finish),
    .state(state),
    .type(type),

    //output
    .i_next(i_next),
    .j_next(j_next)
);

//squential
always @(posedge clk) begin  
    if (~srst_n) begin
        output_len <= 2;
        cnt_qrcode <= 0;
        state <= IDLE;
        state_freeze <= IDLE;
        sram_raddr <= 0;
        cnt <= 0;
        cnt_valid <= 0;
        cnt_ignore <= 0;
        cnt_block <= 0;
        i <= 0;
        j <= 0;
        is_rank_b <= 0;
    end
    else begin
        output_len <= output_len_n;
        cnt_qrcode <= cnt_qrcode_n;
        state <= state_n;
        state_freeze <= state_freeze_n;
        sram_raddr <= sram_raddr_n;
        cnt <= cnt_n;
        cnt_valid <= cnt_valid_n;
        cnt_ignore <= cnt_ignore_n;
        cnt_block <= cnt_block_n;
        i <= i_n;
        j <= j_n;
        is_rank_b <= is_rank_b_n;
    end
end

endmodule