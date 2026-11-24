module de_mask(
    input clk,
    input srst_n,             
    input mask_start,                         
    input mask_index,      

    output [2:0] mask_pattern,
    output reg mask_done         
);

localparam IDLE = 2'd0;
localparam LOAD = 2'd1;
localparam DONE = 2'd2;

reg [1:0] state,state_n;
reg [1:0] cnt,cnt_n;
reg [2:0] mask_pattern_reg,mask_pattern_reg_n;

assign mask_pattern = (mask_done)? (mask_pattern_reg ^3'b101) : 0;

//FSM
always @(*) begin
    mask_done =0;
    cnt_n = 0;
    state_n = IDLE;
    
    case (state)//synopsis parallel case
        IDLE: begin
            state_n = IDLE;
            if (mask_start) begin
                state_n = LOAD;
            end
        end
        LOAD:begin
            cnt_n = cnt + 1;
            state_n = LOAD;
            if (cnt == 2) begin
                state_n = DONE;
                cnt_n = 0;
            end
        end
        DONE:begin
            mask_done = 1;
            state_n = IDLE;
        end  
    endcase
end

//change mask pattern
always @(*) begin
    mask_pattern_reg_n = mask_pattern_reg;
    if (state == LOAD) begin
        mask_pattern_reg_n[cnt] = mask_index;
    end
end

//squential
always @(posedge clk) begin
    if (~srst_n) begin
        mask_pattern_reg <= 0;
        state <= IDLE;
        cnt <= 0;
    end
    else begin
         mask_pattern_reg <= mask_pattern_reg_n;
         state <= state_n;
         cnt <= cnt_n;
    end 
end

endmodule