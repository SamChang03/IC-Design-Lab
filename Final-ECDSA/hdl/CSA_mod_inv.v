module CSA_mod_inv#(
    parameter SUB_CONSTANT = 256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffe17,
    parameter MOD_CONSTANT = 256'h1000003d1,
    parameter P =  256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
)
(
    input clk,
    input rst_n,
    input [255:0] a,
    input inv_start,
    output reg inv_done,
    output reg [255:0] inv_result
);

// localparam P3 = 256'h7fffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffe17; // P3 = P-P/2
// fsm
localparam IDLE = 3'd0, EVEN_U = 3'd1, EVEN_ADD_U = 3'd2, EVEN_V = 3'd3, EVEN_ADD_V = 3'd4, UMV = 3'd5, VMU = 3'd6, DONE = 3'd7;
reg [2:0] state, nxt_state;

// start signal for CSA_mod_add and CSA_mod_sub
reg sub_start, nxt_sub_start;

// CSA mod sub
reg [255:0] sub_a, sub_b;
wire sub_done;
wire [255:0] sub_result;

// CSA mod sub 2
reg [255:0] sub2_a, sub2_b;
wire sub2_done;
wire [255:0] sub2_result;

reg [255:0] u, v, x, y;
reg [255:0] nxt_u, nxt_v, nxt_x, nxt_y;

reg return_sel, nxt_return_sel;

always@(*) begin
    nxt_state = state;
    nxt_sub_start = 0;
    sub_a = 0; sub_b = 0;
    sub2_a = 0; sub2_b = 0;
    nxt_u = u; nxt_v = v; nxt_x = x; nxt_y = y;
    nxt_return_sel = return_sel;
    inv_done = 0;
    inv_result = 0;
    case(state)
        IDLE: begin
            nxt_u = a; nxt_v = P; nxt_x = 1; nxt_y = 0;
            if(inv_start) begin
                nxt_state = EVEN_U;
            end
        end
        EVEN_U: begin
            if(u[0] == 1'b1) begin
                nxt_state = EVEN_V;
            end else begin
                if(x[0] == 1'b1) begin
                    nxt_state = EVEN_ADD_U;
                    nxt_sub_start = 1'b1;
                end else begin
                    nxt_state = EVEN_U;
                    nxt_u = {1'b0, u[255:1]};
                    nxt_x = {1'b0, x[255:1]};
                end
            end
        end
        EVEN_ADD_U: begin
            if(sub_done == 1'b1 && sub_start == 1'b0) begin
                nxt_state = EVEN_U;
                nxt_u = {1'b0, u[255:1]};
                nxt_x = sub_result;
            end
            sub_a = {1'b0, x[255:1]};
            sub_b = SUB_CONSTANT;
        end
        EVEN_V: begin
            if(v[0] == 1'b1) begin
                if(u >= v) begin
                    nxt_state = UMV;
                    nxt_sub_start = 1'b1;
                end else begin
                    nxt_state = VMU;
                    nxt_sub_start = 1'b1;
                end
            end else begin
                if(y[0] == 1'b1) begin
                    nxt_state = EVEN_ADD_V;
                    nxt_sub_start = 1'b1;
                end else begin
                    nxt_state = EVEN_V;
                    nxt_v = {1'b0, v[255:1]};
                    nxt_y = {1'b0, y[255:1]};
                end
            end
        end
        EVEN_ADD_V: begin
            if(sub_done == 1'b1 && sub_start == 1'b0) begin
                nxt_state = EVEN_V;
                nxt_v = {1'b0, v[255:1]};
                nxt_y = sub_result;
            end
            sub_a = {1'b0, y[255:1]};
            sub_b = SUB_CONSTANT;
        end
        UMV: begin
            if(sub_done == 1'b1 && sub2_done == 1'b1 && sub_start == 1'b0) begin
                if(u == 256'd1 || v == 256'd1) begin
                    nxt_state = DONE;
                end else begin
                    nxt_state = EVEN_U;
                end
                nxt_u = sub_result;
                nxt_x = sub2_result;
                nxt_return_sel = (u == 256'd1)? 1'b1:1'b0;
            end
            sub_a = u;
            sub_b = v;
            sub2_a = x;
            sub2_b = y;
        end
        VMU: begin
            if(sub_done == 1'b1 && sub2_done == 1'b1 && sub_start == 1'b0) begin
                if(u == 256'd1 || v == 256'd1) begin
                    nxt_state = DONE;
                end else begin
                    nxt_state = EVEN_U;
                end
                nxt_v = sub_result;
                nxt_y = sub2_result;
                nxt_return_sel = (u == 256'd1)? 1'b1:1'b0;
            end
            sub_a = v;
            sub_b = u;
            sub2_a = y;
            sub2_b = x;
        end
        DONE: begin
            inv_done = 1;
            inv_result = (return_sel == 1'b1)? x:y;
        end
    endcase
end


always@(posedge clk) begin
    if(!rst_n) begin
        state <= IDLE;
        sub_start <= 0;
        return_sel <= 0;
    end
    else begin
        state <= nxt_state;
        sub_start <= nxt_sub_start;
        return_sel <= nxt_return_sel;
    end
    u <= nxt_u; v <= nxt_v; x <= nxt_x; y <= nxt_y;
end


// instance of CSA_mod_sub
CSA_mod_sub #(
    .MOD_CONSTANT(MOD_CONSTANT)
) mod_sub_inst(
    .clk(clk),
    .rst_n(rst_n),
    .sub_start(sub_start),
    .a(sub_a),
    .b(sub_b),
    .sub_done(sub_done),
    .result(sub_result)
);

CSA_mod_sub #(
    .MOD_CONSTANT(MOD_CONSTANT)
) mod_sub2_inst(
    .clk(clk),
    .rst_n(rst_n),
    .sub_start(sub_start),
    .a(sub2_a),
    .b(sub2_b),
    .sub_done(sub2_done),
    .result(sub2_result)
);

endmodule