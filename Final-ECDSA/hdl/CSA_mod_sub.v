module CSA_mod_sub#(parameter MOD_CONSTANT = 256'h1000003d1)(
    input clk,
    input rst_n,
    input sub_start,
    input [255:0] a,
    input [255:0] b,
    output reg sub_done,
    output [255:0] result
);

localparam ADDER_WIDTH = 32;
// fsm
localparam CSA_IDLE = 3'd0, CSA_COMPUTE = 3'd1, CSA_MOD_ADD = 3'd2, CSA_DONE = 3'd3;
reg [2:0] state, nxt_state;

// CSA
reg [ADDER_WIDTH-1:0] csa_a0, csa_a1, csa_a2, csa_a3, csa_a4, csa_a5, csa_a6, csa_a7;
reg [ADDER_WIDTH-1:0] csa_b0, csa_b1, csa_b2, csa_b3, csa_b4, csa_b5, csa_b6, csa_b7;
reg [ADDER_WIDTH:0] csa_sum00, csa_sum01, csa_sum02, csa_sum03, csa_sum04, csa_sum05, csa_sum06, csa_sum07;
reg [ADDER_WIDTH:0] nxt_csa_sum00, nxt_csa_sum01, nxt_csa_sum02, nxt_csa_sum03, nxt_csa_sum04, nxt_csa_sum05, nxt_csa_sum06, nxt_csa_sum07;
wire csa_b00, csa_b01, csa_b02, csa_b03, csa_b04, csa_b05, csa_b06, csa_b07; // borrow signals for borrow_in=0
assign csa_b00 = csa_sum00[ADDER_WIDTH]; 
assign csa_b01 = csa_sum01[ADDER_WIDTH]; 
assign csa_b02 = csa_sum02[ADDER_WIDTH]; 
assign csa_b03 = csa_sum03[ADDER_WIDTH];
assign csa_b04 = csa_sum04[ADDER_WIDTH]; 
assign csa_b05 = csa_sum05[ADDER_WIDTH]; 
assign csa_b06 = csa_sum06[ADDER_WIDTH]; 
assign csa_b07 = csa_sum07[ADDER_WIDTH];

// carry in = 1 (now borrow in = 1)
reg [ADDER_WIDTH:0] csa_sum11, csa_sum12, csa_sum13, csa_sum14, csa_sum15, csa_sum16, csa_sum17;
reg [ADDER_WIDTH:0] nxt_csa_sum11, nxt_csa_sum12, nxt_csa_sum13, nxt_csa_sum14, nxt_csa_sum15, nxt_csa_sum16, nxt_csa_sum17;
wire csa_b11, csa_b12, csa_b13, csa_b14, csa_b15, csa_b16, csa_b17;
assign csa_b11 = csa_sum11[ADDER_WIDTH]; 
assign csa_b12 = csa_sum12[ADDER_WIDTH]; 
assign csa_b13 = csa_sum13[ADDER_WIDTH];
assign csa_b14 = csa_sum14[ADDER_WIDTH]; 
assign csa_b15 = csa_sum15[ADDER_WIDTH]; 
assign csa_b16 = csa_sum16[ADDER_WIDTH]; 
assign csa_b17 = csa_sum17[ADDER_WIDTH];

// result
reg borrow_flag;
reg [ADDER_WIDTH-1:0] result_7, result_6, result_5, result_4, result_3, result_2, result_1, result_0;
reg [ADDER_WIDTH-1:0] nxt_result_7, nxt_result_6, nxt_result_5, nxt_result_4, nxt_result_3, nxt_result_2, nxt_result_1, nxt_result_0;
assign result = {result_7, result_6, result_5, result_4, result_3, result_2, result_1, result_0};

// result selector
reg result_sel_1, result_sel_2, result_sel_3, result_sel_4, result_sel_5, result_sel_6;

always@(*) begin
    nxt_result_0 = csa_sum00[31:0];
    if(csa_b00) begin
        result_sel_1 = csa_b11;
        nxt_result_1 = csa_sum11[31:0];
    end else begin
        result_sel_1 = csa_b01;
        nxt_result_1 = csa_sum01[31:0];
    end
    if(result_sel_1) begin
        result_sel_2 = csa_b12;
        nxt_result_2 = csa_sum12[31:0];
    end else begin
        result_sel_2 = csa_b02;
        nxt_result_2 = csa_sum02[31:0];
    end
    if(result_sel_2) begin
        result_sel_3 = csa_b13;
        nxt_result_3 = csa_sum13[31:0];
    end else begin
        result_sel_3 = csa_b03;
        nxt_result_3 = csa_sum03[31:0];
    end
    if(result_sel_3) begin
        result_sel_4 = csa_b14;
        nxt_result_4 = csa_sum14[31:0];
    end else begin
        result_sel_4 = csa_b04;
        nxt_result_4 = csa_sum04[31:0];
    end
    if(result_sel_4) begin
        result_sel_5 = csa_b15;
        nxt_result_5 = csa_sum15[31:0];
    end else begin
        result_sel_5 = csa_b05;
        nxt_result_5 = csa_sum05[31:0];
    end
    if(result_sel_5) begin
        result_sel_6 = csa_b16;
        nxt_result_6 = csa_sum16[31:0];
    end else begin
        result_sel_6 = csa_b06;
        nxt_result_6 = csa_sum06[31:0];
    end
    if(result_sel_6) begin
        borrow_flag = csa_b17;
        nxt_result_7 = csa_sum17[31:0];
    end else begin
        borrow_flag = csa_b07;
        nxt_result_7 = csa_sum07[31:0];
    end
end

// 計算 next state 的減法結果
always @(*) begin
    // borrow_in = 0 (不需借位時)
    nxt_csa_sum00 = {1'b0, csa_a0} - {1'b0, csa_b0};
    nxt_csa_sum01 = {1'b0, csa_a1} - {1'b0, csa_b1};
    nxt_csa_sum02 = {1'b0, csa_a2} - {1'b0, csa_b2};
    nxt_csa_sum03 = {1'b0, csa_a3} - {1'b0, csa_b3};
    nxt_csa_sum04 = {1'b0, csa_a4} - {1'b0, csa_b4};
    nxt_csa_sum05 = {1'b0, csa_a5} - {1'b0, csa_b5};
    nxt_csa_sum06 = {1'b0, csa_a6} - {1'b0, csa_b6};
    nxt_csa_sum07 = {1'b0, csa_a7} - {1'b0, csa_b7};

    // borrow_in = 1 (需要借位時，等同多減 1)
    nxt_csa_sum11 = ({1'b0, csa_a1} - {1'b0, csa_b1}) - 1;
    nxt_csa_sum12 = ({1'b0, csa_a2} - {1'b0, csa_b2}) - 1;
    nxt_csa_sum13 = ({1'b0, csa_a3} - {1'b0, csa_b3}) - 1;
    nxt_csa_sum14 = ({1'b0, csa_a4} - {1'b0, csa_b4}) - 1;
    nxt_csa_sum15 = ({1'b0, csa_a5} - {1'b0, csa_b5}) - 1;
    nxt_csa_sum16 = ({1'b0, csa_a6} - {1'b0, csa_b6}) - 1;
    nxt_csa_sum17 = ({1'b0, csa_a7} - {1'b0, csa_b7}) - 1;
end

always@(*) begin
    nxt_state = state;
    sub_done = 0;

    // 預設值
    csa_a0 = a[31:0]; csa_a1 = a[63:32]; csa_a2 = a[95:64]; csa_a3 = a[127:96];
    csa_a4 = a[159:128]; csa_a5 = a[191:160]; csa_a6 = a[223:192]; csa_a7 = a[255:224];

    csa_b0 = b[31:0]; csa_b1 = b[63:32]; csa_b2 = b[95:64]; csa_b3 = b[127:96];
    csa_b4 = b[159:128]; csa_b5 = b[191:160]; csa_b6 = b[223:192]; csa_b7 = b[255:224];

    case (state)
        CSA_IDLE: begin
            if(sub_start) begin
                nxt_state = CSA_COMPUTE;
            end
        end
        CSA_COMPUTE: begin
            // 如果最後結果有 borrow (borrow_flag = 1) 表示結果為負數，需要加上 MOD_CONSTANT
            if(borrow_flag) begin
                nxt_state = CSA_MOD_ADD;
                csa_a0 = nxt_result_0; csa_a1 = nxt_result_1; csa_a2 = nxt_result_2; csa_a3 = nxt_result_3;
                csa_a4 = nxt_result_4; csa_a5 = nxt_result_5; csa_a6 = nxt_result_6; csa_a7 = nxt_result_7;

                // 減法結果為負數 -> 加上 MOD_CONSTANT
                // 即 result + MOD_CONSTANT
                csa_b0 = MOD_CONSTANT[31:0]; csa_b1 = MOD_CONSTANT[63:32]; csa_b2 = MOD_CONSTANT[95:64]; csa_b3 = MOD_CONSTANT[127:96];
                csa_b4 = MOD_CONSTANT[159:128]; csa_b5 = MOD_CONSTANT[191:160]; csa_b6 = MOD_CONSTANT[223:192]; csa_b7 = MOD_CONSTANT[255:224];
            end else begin
                nxt_state = CSA_DONE;
            end
        end
        CSA_MOD_ADD: begin
            nxt_state = CSA_DONE;
        end
        CSA_DONE: begin
            sub_done = 1;
            // nxt_state = CSA_IDLE;
            if(sub_start) begin
                nxt_state = CSA_COMPUTE;
            end 
        end
    endcase
end

always@(posedge clk) begin
    if (!rst_n) begin
        state <= CSA_IDLE;
    end else begin
        state <= nxt_state;  
    end
    // result
    if(state != CSA_DONE || sub_start) begin    
        result_7 <= nxt_result_7; result_6 <= nxt_result_6; result_5 <= nxt_result_5; result_4 <= nxt_result_4;
        result_3 <= nxt_result_3; result_2 <= nxt_result_2; result_1 <= nxt_result_1; result_0 <= nxt_result_0;
    end
    // borrow_in = 0
    csa_sum00 <= nxt_csa_sum00; csa_sum01 <= nxt_csa_sum01; csa_sum02 <= nxt_csa_sum02; csa_sum03 <= nxt_csa_sum03;
    csa_sum04 <= nxt_csa_sum04; csa_sum05 <= nxt_csa_sum05; csa_sum06 <= nxt_csa_sum06; csa_sum07 <= nxt_csa_sum07;
    // borrow_in = 1
    csa_sum11 <= nxt_csa_sum11; csa_sum12 <= nxt_csa_sum12; csa_sum13 <= nxt_csa_sum13; csa_sum14 <= nxt_csa_sum14;
    csa_sum15 <= nxt_csa_sum15; csa_sum16 <= nxt_csa_sum16; csa_sum17 <= nxt_csa_sum17;
end

endmodule
