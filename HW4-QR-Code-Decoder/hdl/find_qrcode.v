module find_qrcode(
    input clk,
    input srst_n,             
    input find_start,                         
    input find_index,
    input [5:0] i,
    input [5:0] j,
    input [2:0] cnt_block,
    input is_rank_b,

    output [5:0] i_find_32,
    output [5:0] j_find_32,
    output reg [5:0] loc_y,
    output reg [5:0] loc_x,
    output reg [1:0] type,
    output reg checking,
    output reg no_QRcode,
    output reg find_done         
);

localparam IDLE = 6'd0;
localparam FIND_1st_EYE = 6'd1;
localparam FIND_2nd_EYE = 6'd2;
localparam FIND_2nd_EYE_2 = 6'd10;
localparam FIND_3rd_EYE_1 = 6'd3;
localparam FIND_3rd_EYE_2 = 6'd4;
localparam FIND_3rd_EYE_3 = 6'd5;
localparam FIND_3rd_EYE_4 = 6'd6;
localparam CHECK_EYE = 6'd7;
localparam CHECK_0 = 6'd11;
localparam CHECK_90 = 6'd12;
localparam CHECK_180 = 6'd13;
localparam CHECK_270 = 6'd14;
localparam FAST_CHECK_QRCODE = 6'd15 ;
localparam FAST_SCAN =  6'd16;
localparam FAST_CHECK_FAKE_EYE = 6'd17;
localparam DONE = 6'd20;

localparam degree_0 = 2'd0;
localparam degree_90 = 2'd1;
localparam degree_180 = 2'd2;
localparam degree_270 = 2'd3;

reg [6:0] input_FIFO,input_FIFO_n;
reg [5:0] state,state_n,state_freeze,state_freeze_n;
reg [5:0] i_freeze, j_freeze, i_freeze_n, j_freeze_n;
reg [5:0] loc_x_reg,loc_y_reg;
reg [2:0] cnt,cnt_n;
reg [1:0] cnt_black, cnt_black_n;
reg [5:0] cnt_fast, cnt_fast_n;
reg [1:0] type_n;

wire [5:0] i_32,j_32;
assign i_32 = (cnt_block == 0) ? i :((i>31) ? i-32 : i);
assign j_32 = (cnt_block == 0) ? j :((j>31) ? j-32 : j);

reg [5:0] i_find, j_find;
assign i_find_32 = (cnt_block == 0) ? i_find : ((i_find > 31) ? i_find -32 : i_find) ;
assign j_find_32 = (cnt_block == 0) ? j_find : ((j_find > 31) ? j_find -32 : j_find) ;

wire j_2_boundary;
assign j_2_boundary = is_rank_b ? (j_32 == 63): (j_32 == 31);

always @(*) begin
    loc_y = loc_y_reg;
    loc_x = loc_x_reg;
    case (cnt_block)
        0: begin
            loc_y = loc_y_reg;
            loc_x = loc_x_reg;
        end
        1: begin
            loc_y = loc_y_reg;
            loc_x = loc_x_reg+32;
        end
        2: begin
            loc_y = loc_y_reg+32;
            loc_x = loc_x_reg;
        end
        3: begin
            loc_y = loc_y_reg+32;
            loc_x = loc_x_reg+32;
        end
    endcase
end

always @(*) begin    
    loc_y_reg = i_freeze;
    loc_x_reg = j_freeze;
    case (type)
        degree_0: begin
            loc_y_reg = i_freeze;
            loc_x_reg = j_freeze;
        end
        degree_90: begin
            loc_y_reg = i_freeze+24;
            loc_x_reg = j_freeze;
        end
        degree_180: begin
            loc_y_reg = i_freeze+24;
            loc_x_reg = j_freeze+6;
        end
        degree_270: begin
            loc_y_reg = i_freeze;
            loc_x_reg = j_freeze+24;
        end
    endcase
end

//FSM
always @(*) begin
    find_done = 0;
    no_QRcode = 0;
    cnt_n = 0;
    cnt_black_n = 0;
    cnt_fast_n = 0;
    state_n = IDLE;
    state_freeze_n = state_freeze;
    i_find =i;
    j_find =j;
    i_freeze_n = i_freeze;
    j_freeze_n = j_freeze;
    type_n = type;
    checking = 0;

    //Input FIFO
    input_FIFO_n = (state != IDLE) ?{input_FIFO[6:0],find_index}: 7'b000_0000 ;
    
    case (state) //synopsis parallel case
        IDLE: begin
            state_n = IDLE;
            if (find_start) begin
                state_n = FAST_CHECK_QRCODE;
            end
        end
        FAST_CHECK_QRCODE: begin
            state_n = FAST_CHECK_QRCODE;
            cnt_black_n = cnt_black;
            cnt_fast_n = cnt_fast + 1;
            i_find =i_32;
            j_find =j_32+4;
            
            if (cnt_black == 2 | is_rank_b) begin // There may be QR-code
                state_n = FAST_SCAN;
                i_find =0;
                j_find =0;
            end
            else if (cnt_fast == 42) begin // There is no QR-code
                state_n = IDLE;
                no_QRcode = 1;
            end 
            else if (j == 28 | j==60) begin
                i_find =i_32+6;
                j_find =0;
            end 

            if (find_index) begin
                cnt_black_n = cnt_black + 1;
            end
        end
        FAST_SCAN: begin
            state_n = FAST_SCAN;
            i_find =i_32;
            j_find =j_32+6;
            
            if (find_index) begin
                state_n = FAST_CHECK_FAKE_EYE;
                i_find =i_32+18;
                j_find =j_32;
            end
            else if (cnt_block == 0) begin
                i_find = (j==62) ? i_32+1 : i_32 ;
                j_find = (j==62) ?  0 : j_32+6;
            end
            else if (j == 30 | j==62) begin
                i_find =i_32+1;
                j_find =0;
            end 
        end

        FAST_CHECK_FAKE_EYE: begin
            state_n = FAST_CHECK_FAKE_EYE;
            i_find =i_32;
            j_find =j_32+5;
            cnt_n = cnt +1;
            
            if (find_index) begin
                state_n = FIND_1st_EYE;
                input_FIFO_n =0;
                i_find =i_32-18;
                j_find =0;
            end
            else if (cnt_block == 0) begin
                state_n = FIND_1st_EYE;
                i_find =i_32-18;
                j_find =0;
            end 
            else if (j_32 > 26 ) begin
                state_n = FAST_SCAN;
                i_find =i_32-18+1;
                j_find =6;
            end 
            else if (cnt == 1) begin
                state_n = FAST_SCAN;
                i_find =i_32-18;
                j_find =j_32-5 +6;
            end
            
        end
        FIND_1st_EYE:begin
            state_n = FIND_1st_EYE;
            i_find =i_32;
            j_find =j_32+1;
            
            if (input_FIFO == 7'b11_111_11) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_1st_EYE;
                i_find =i_32+6; //change
                j_find = j_32-7; //the row
                i_freeze_n = i_32;
                j_freeze_n = j_32-7;
            end
            else if (j_2_boundary & input_FIFO == 7'b01_111_11 & find_index ) begin //revise for boundary condition
                state_n = CHECK_EYE;
                state_freeze_n = FIND_1st_EYE;
                i_find =i_32+6; //change
                j_find = j_32-6; //the row
                i_freeze_n = i_32;
                j_freeze_n = j_32-6;
            end
            else if (j_2_boundary) begin
                state_n = FAST_SCAN;
                i_find =i_32+1;
                j_find =0;
            end
        end
        FIND_2nd_EYE:begin
            checking =1;
            state_n = FIND_2nd_EYE;
            i_find =i_32;
            j_find =j_32+1;
            cnt_n = cnt + 1;
            if (input_FIFO == 7'b11_111_11& cnt == 7) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_2nd_EYE;
                i_find =i_32+6; //change
                j_find =j_32-7; //the row
            end
            else if (cnt == 7) begin
                state_n = FIND_2nd_EYE_2;
                i_find =i_freeze; //change
                j_find =j_freeze+18; //pattern
                input_FIFO_n = 0;
            end
        end
        FIND_2nd_EYE_2:begin
            checking =1;
            state_n = FIND_2nd_EYE_2;
            i_find =i_32;
            j_find =j_32+1;
            cnt_n = cnt + 1;
            if (input_FIFO == 7'b11_111_11 & cnt == 7) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_2nd_EYE_2;
                i_find =i_32+6; //change
                j_find = j_32-7; //the row
            end
            else if (cnt == 7) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze; //change
                j_find =j_freeze+1; //pattern
                input_FIFO_n = 0;
            end
        end
        FIND_3rd_EYE_1:begin
            checking =1;
            state_n = FIND_3rd_EYE_1;
            i_find =i_32;
            j_find =j_32+1;
            cnt_n = cnt + 1;
            
            if (input_FIFO == 7'b11_111_11 & cnt == 7) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_3rd_EYE_1;
                i_find =i_32+6; //change
                j_find = j_32-7; //the row
            end
            else if (cnt == 7) begin
                state_n = FIND_3rd_EYE_2;
                i_find =i_freeze+18; //change
                j_find =j_freeze+18; //pattern
                input_FIFO_n = 0;
            end
        end
        FIND_3rd_EYE_2:begin
            checking =1;
            state_n = FIND_3rd_EYE_2;
            i_find =i_32;
            j_find =j_32+1;
            cnt_n = cnt + 1;
            
            if (input_FIFO == 7'b11_111_11 & cnt == 7) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_3rd_EYE_2;
                i_find =i_32+6; //change
                j_find = j_32-7; //the row
            end
            else if (cnt == 7) begin
                state_n = FIND_3rd_EYE_3;
                i_find =i_freeze+18; //change
                j_find =j_freeze-18; //pattern
                input_FIFO_n = 0;
            end
        end
        FIND_3rd_EYE_3:begin
            checking =1;
            state_n = FIND_3rd_EYE_3;
            i_find =i_32;
            j_find =j_32+1;
            cnt_n = cnt + 1;
            
            if (input_FIFO == 7'b11_111_11 & cnt == 7) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_3rd_EYE_3;
                i_find =i_32+6; //change
                j_find =j_32-7; //the row
            end
            else if (cnt == 7) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze; //change
                j_find =j_freeze+7; //pattern
                input_FIFO_n = 0;
            end
        end
        FIND_3rd_EYE_4:begin
            checking =1;
            state_n = FIND_3rd_EYE_4;
            i_find =i_32;
            j_find =j_32+1;
            cnt_n = cnt + 1;
            
            if (input_FIFO == 7'b11_111_11 & cnt == 7) begin
                state_n = CHECK_EYE;
                state_freeze_n = FIND_3rd_EYE_4;
                i_find =i_32+6; //change
                j_find = j_32-7; //the row
            end
            else if (cnt == 7) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze; //change
                j_find =j_freeze+7; //pattern
                input_FIFO_n = 0;
            end
        end
        
        CHECK_EYE:begin
            checking =1;
            state_n = CHECK_EYE;
            cnt_n = cnt + 1;
            i_find =i_32;
            j_find =j_32+1;
            if (input_FIFO == 7'b11_111_11 & cnt == 7) begin
                state_n = state_freeze+1;
                cnt_n = 0;
                i_find =i_freeze; //change
                j_find =j_freeze; //the row
                case (state_freeze)
                    FIND_1st_EYE:  begin i_find =i_freeze+18; j_find =j_freeze; end
                    FIND_2nd_EYE:  begin i_find =i_freeze; j_find =j_freeze+18; end
                    FIND_2nd_EYE_2:  begin i_find =i_freeze+18; j_find =j_freeze+18; state_n = FIND_3rd_EYE_4; end
                    FIND_3rd_EYE_1: begin 
                        i_find =i_freeze+18;
                        j_find =j_freeze+16;
                        state_n = CHECK_0;
                    end
                    FIND_3rd_EYE_2: begin 
                        i_find =i_freeze+6;
                        j_find =j_freeze+16;
                        state_n = CHECK_90;
                    end
                    FIND_3rd_EYE_3: begin 
                        i_find =i_freeze+6;
                        j_find =j_freeze-14;
                        state_n = CHECK_180;
                    end
                    FIND_3rd_EYE_4: begin 
                        i_find =i_freeze+18;
                        j_find =j_freeze+4;
                        state_n = CHECK_270;
                    end                      
                endcase
            end
            else if (cnt == 7) begin
                state_n = state_freeze;
                i_find =i_freeze;
                j_find =(state_freeze == FIND_2nd_EYE)?j_freeze+2:j_freeze+1;
                cnt_n = 0;
                input_FIFO_n = 0;
            end
        end
        CHECK_0:begin
            checking =1;
            state_n = CHECK_0;
            cnt_n = cnt + 1;
            i_find =i_32;
            j_find =j_32+1;
            if (input_FIFO[4:0] == 5'b101_01 & cnt == 5) begin
                i_find =i_freeze;
                j_find =j_freeze;
                type_n = degree_0;
                state_n = DONE;
            end
            else if (cnt == 5) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze;
                j_find =j_freeze+1;
                cnt_n = 0;
                input_FIFO_n = 0;
            end
        end
        CHECK_90:begin
            checking =1;
            state_n = CHECK_90;
            cnt_n = cnt + 1;
            i_find =i_32;
            j_find =j_32+1;
            if (input_FIFO[4:0] == 5'b101_01 & cnt == 5) begin
                i_find =i_freeze;
                j_find =j_freeze;
                type_n = degree_90;
                state_n = DONE;
            end
            else if (cnt == 5) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze;
                j_find =j_freeze+1;
                cnt_n = 0;
                input_FIFO_n = 0;
            end
        end
        CHECK_180:begin
            checking =1;
            state_n = CHECK_180;
            cnt_n = cnt + 1;
            i_find =i_32;
            j_find =j_32+1;
            if (input_FIFO[4:0] == 5'b101_01 & cnt == 5) begin
                i_find =i_freeze;
                j_find =j_freeze;
                type_n = degree_180;
                state_n = DONE;
            end
            else if (cnt == 5) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze;
                j_find =j_freeze+1;
                cnt_n = 0;
                input_FIFO_n = 0;
            end
        end
        CHECK_270:begin
            checking =1;
            state_n = CHECK_270;
            cnt_n = cnt + 1;
            i_find =i_32;
            j_find =j_32+1;
            if (input_FIFO[4:0] == 5'b101_01 & cnt == 5) begin
                i_find =i_freeze;
                j_find =j_freeze;
                type_n = degree_270;
                state_n = DONE;
            end
            else if (cnt == 5) begin
                state_n = FIND_1st_EYE;
                i_find =i_freeze;
                j_find =j_freeze+1;
                cnt_n = 0;
                input_FIFO_n = 0;
            end
        end

        DONE:begin
            find_done = 1;
            state_n = IDLE;
            cnt_n = 0;
            i_freeze_n = i_freeze;
            j_freeze_n = j_freeze;
        end
        default: begin
            state_n = IDLE;
            if (find_start) begin
                state_n = FIND_1st_EYE;
            end
        end  
    endcase
end


//squential
always @(posedge clk) begin
    if (~srst_n) begin
         state <= IDLE;
        state_freeze <= IDLE;
        i_freeze <= 0;
        j_freeze <= 0;
        cnt <= 0;
        cnt_black <= 0;
        cnt_fast <= 0;
        type <= 0;
        input_FIFO <= 0;
    end
    else begin
        state <= state_n;
        state_freeze <= state_freeze_n;
        i_freeze <= i_freeze_n;
        j_freeze <= j_freeze_n;
        cnt <= cnt_n;
        cnt_black <= cnt_black_n;
        cnt_fast <= cnt_fast_n;
        type <= type_n;
        input_FIFO <= input_FIFO_n;
    end
end

endmodule
