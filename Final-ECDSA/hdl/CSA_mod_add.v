module CSA_mod_add#(parameter MOD_CONSTANT = 256'h1000003d1)(
    input clk,
    input rst_n,
    input add_start,
    input [255:0] a,
    input [255:0] b,
    output reg add_done,
    output [255:0] result
);

localparam ADDER_WIDTH = 32;
// fsm
localparam CSA_IDLE = 3'd0, CSA_COMPUTE = 3'd1, CSA_MOD_ADD = 3'd2, CSA_DONE = 3'd3;
reg [2:0] state, nxt_state;

// CSA
reg [ADDER_WIDTH-1:0] csa_a0, csa_a1, csa_a2, csa_a3, csa_a4, csa_a5, csa_a6, csa_a7;
reg [ADDER_WIDTH-1:0] csa_b0, csa_b1, csa_b2, csa_b3, csa_b4, csa_b5, csa_b6, csa_b7;
reg [ADDER_WIDTH:0] csa_c0, csa_c1, csa_c2, csa_c3, csa_c4, csa_c5, csa_c6, csa_c7;

// carry in = 0
reg [ADDER_WIDTH:0] csa_sum00, csa_sum01, csa_sum02, csa_sum03, csa_sum04, csa_sum05, csa_sum06, csa_sum07;
reg [ADDER_WIDTH:0] nxt_csa_sum00, nxt_csa_sum01, nxt_csa_sum02, nxt_csa_sum03, nxt_csa_sum04, nxt_csa_sum05, nxt_csa_sum06, nxt_csa_sum07;
wire csa_c00, csa_c01, csa_c02, csa_c03, csa_c04, csa_c05, csa_c06, csa_c07;
assign csa_c00 = csa_sum00[ADDER_WIDTH], csa_c01 = csa_sum01[ADDER_WIDTH], csa_c02 = csa_sum02[ADDER_WIDTH], csa_c03 = csa_sum03[ADDER_WIDTH];
assign csa_c04 = csa_sum04[ADDER_WIDTH], csa_c05 = csa_sum05[ADDER_WIDTH], csa_c06 = csa_sum06[ADDER_WIDTH], csa_c07 = csa_sum07[ADDER_WIDTH];
// carry in = 1
reg [ADDER_WIDTH:0] csa_sum11, csa_sum12, csa_sum13, csa_sum14, csa_sum15, csa_sum16, csa_sum17;
reg [ADDER_WIDTH:0] nxt_csa_sum11, nxt_csa_sum12, nxt_csa_sum13, nxt_csa_sum14, nxt_csa_sum15, nxt_csa_sum16, nxt_csa_sum17;
wire csa_c11, csa_c12, csa_c13, csa_c14, csa_c15, csa_c16, csa_c17;
assign csa_c11 = csa_sum11[ADDER_WIDTH], csa_c12 = csa_sum12[ADDER_WIDTH], csa_c13 = csa_sum13[ADDER_WIDTH];
assign csa_c14 = csa_sum14[ADDER_WIDTH], csa_c15 = csa_sum15[ADDER_WIDTH], csa_c16 = csa_sum16[ADDER_WIDTH], csa_c17 = csa_sum17[ADDER_WIDTH];
// result
reg overflow;
reg [ADDER_WIDTH-1:0] result_7, result_6, result_5, result_4, result_3, result_2, result_1, result_0;
reg [ADDER_WIDTH-1:0] nxt_result_7, nxt_result_6, nxt_result_5, nxt_result_4, nxt_result_3, nxt_result_2, nxt_result_1, nxt_result_0;
assign result = {result_7, result_6, result_5, result_4, result_3, result_2, result_1, result_0};
// result selector
reg result_sel_1, result_sel_2, result_sel_3, result_sel_4, result_sel_5, result_sel_6;

// result select
always@(*) begin
    nxt_result_0 = csa_sum00[31:0];
    if(csa_c00) begin
        result_sel_1 = csa_c11;
        nxt_result_1 = csa_sum11[31:0];
    end else begin
        result_sel_1 = csa_c01;
        nxt_result_1 = csa_sum01[31:0];
    end
    if(result_sel_1) begin
        result_sel_2 = csa_c12;
        nxt_result_2 = csa_sum12[31:0];
    end else begin
        result_sel_2 = csa_c02;
        nxt_result_2 = csa_sum02[31:0];
    end
    if(result_sel_2) begin
        result_sel_3 = csa_c13;
        nxt_result_3 = csa_sum13[31:0];
    end else begin
        result_sel_3 = csa_c03;
        nxt_result_3 = csa_sum03[31:0];
    end
    if(result_sel_3) begin
        result_sel_4 = csa_c14;
        nxt_result_4 = csa_sum14[31:0];
    end else begin
        result_sel_4 = csa_c04;
        nxt_result_4 = csa_sum04[31:0];
    end
    if(result_sel_4) begin
        result_sel_5 = csa_c15;
        nxt_result_5 = csa_sum15[31:0];
    end else begin
        result_sel_5 = csa_c05;
        nxt_result_5 = csa_sum05[31:0];
    end
    if(result_sel_5) begin
        result_sel_6 = csa_c16;
        nxt_result_6 = csa_sum16[31:0];
    end else begin
        result_sel_6 = csa_c06;
        nxt_result_6 = csa_sum06[31:0];
    end
    if(result_sel_6) begin
        overflow = csa_c17;
        nxt_result_7 = csa_sum17[31:0];
    end else begin
        overflow = csa_c07;
        nxt_result_7 = csa_sum07[31:0];
    end
end

always @(*) begin
    // carry in = 0
    nxt_csa_sum00 = csa_a0 + csa_b0;
    nxt_csa_sum01 = csa_a1 + csa_b1;
    nxt_csa_sum02 = csa_a2 + csa_b2;
    nxt_csa_sum03 = csa_a3 + csa_b3;
    nxt_csa_sum04 = csa_a4 + csa_b4;
    nxt_csa_sum05 = csa_a5 + csa_b5;
    nxt_csa_sum06 = csa_a6 + csa_b6;
    nxt_csa_sum07 = csa_a7 + csa_b7;
    // carry in = 1
    nxt_csa_sum11 = csa_a1 + csa_b1 + 1;
    nxt_csa_sum12 = csa_a2 + csa_b2 + 1;
    nxt_csa_sum13 = csa_a3 + csa_b3 + 1;
    nxt_csa_sum14 = csa_a4 + csa_b4 + 1;
    nxt_csa_sum15 = csa_a5 + csa_b5 + 1;
    nxt_csa_sum16 = csa_a6 + csa_b6 + 1;
    nxt_csa_sum17 = csa_a7 + csa_b7 + 1;
end

always@(*) begin
    nxt_state = state;
    add_done = 0;
    csa_a0 = a[31:0]; csa_a1 = a[63:32]; csa_a2 = a[95:64]; csa_a3 = a[127:96];
    csa_a4 = a[159:128]; csa_a5 = a[191:160]; csa_a6 = a[223:192]; csa_a7 = a[255:224];
    csa_b0 = b[31:0]; csa_b1 = b[63:32]; csa_b2 = b[95:64]; csa_b3 = b[127:96];
    csa_b4 = b[159:128]; csa_b5 = b[191:160]; csa_b6 = b[223:192]; csa_b7 = b[255:224];
    case (state)
        CSA_IDLE: begin
            if(add_start) begin
                nxt_state = CSA_COMPUTE;
            end
        end
        CSA_COMPUTE: begin
            if(overflow) begin
                nxt_state = CSA_MOD_ADD;
                csa_a0 = nxt_result_0; csa_a1 = nxt_result_1; csa_a2 = nxt_result_2; csa_a3 = nxt_result_3;
                csa_a4 = nxt_result_4; csa_a5 = nxt_result_5; csa_a6 = nxt_result_6; csa_a7 = nxt_result_7;
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
            add_done = 1;
            // nxt_state = CSA_IDLE;
            if(add_start) begin
                nxt_state = CSA_COMPUTE;
            end 
            // else begin
            //     add_done = 1;
            // end
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
    if(state != CSA_DONE || add_start) begin
        result_7 <= nxt_result_7; result_6 <= nxt_result_6; result_5 <= nxt_result_5; result_4 <= nxt_result_4;
        result_3 <= nxt_result_3; result_2 <= nxt_result_2; result_1 <= nxt_result_1; result_0 <= nxt_result_0;
    end
    // carry in = 0
    csa_sum00 <= nxt_csa_sum00; csa_sum01 <= nxt_csa_sum01; csa_sum02 <= nxt_csa_sum02; csa_sum03 <= nxt_csa_sum03;
    csa_sum04 <= nxt_csa_sum04; csa_sum05 <= nxt_csa_sum05; csa_sum06 <= nxt_csa_sum06; csa_sum07 <= nxt_csa_sum07;
    // carry in = 1
    csa_sum11 <= nxt_csa_sum11; csa_sum12 <= nxt_csa_sum12; csa_sum13 <= nxt_csa_sum13; csa_sum14 <= nxt_csa_sum14;
    csa_sum15 <= nxt_csa_sum15; csa_sum16 <= nxt_csa_sum16; csa_sum17 <= nxt_csa_sum17;
end

endmodule