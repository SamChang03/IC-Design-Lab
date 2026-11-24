module signing # (parameter WIDTH = 256) (
    input clk,
    input rst_n,
    input t_valid,
    // input [WIDTH-1:0] n,
    input [WIDTH-1:0] k,
    input [WIDTH-1:0] da,
    // SHA256
    input sha256_valid,
    input sha256_last,
    input [31:0] sha256_data,
    // ML
    input ml_valid,
    input [WIDTH-1:0] ml_data,
    // output
    output reg r_ready,
    output reg sign_valid,
    output reg [WIDTH-1:0] sign_result
);

// FSM for post_ML
localparam IDLE = 3'd0, KINV = 3'd1, KIDA = 3'd2, ZLOAD = 3'd3,
           KIZ = 3'd4, KIRDA = 3'd5, SIGN = 3'd6, DONE = 3'd7;


reg [2:0] state, nxt_state;
reg [WIDTH-1:0] R1, R2, nxt_R1, nxt_R2;

// MOD INV
reg MI_start;
reg [WIDTH-1:0] MI_a;

// wire MI_busy, MI_done;
wire MI_done;
wire [WIDTH-1:0] MI_result;

// MOD MULT
reg MM_start, MM_start_n;
reg [WIDTH-1:0] MM_a, MM_b;
// wire [WIDTH-1:0] MM_m = N;
// wire MM_busy, MM_done;
wire MM_done;
wire MM_done_comb = MM_done && (MM_start == 1'b0);
wire [WIDTH-1:0] MM_result;

// MOD ADD
reg MA_start;
reg [WIDTH-1:0] MA_a, MA_b;
wire MA_done;
wire [WIDTH-1:0] MA_result;


// FSM
always @(*) begin
    nxt_state = state;
    MI_start = 0; MI_a = 0;
    MM_start_n = 0; MM_a = 0; MM_b = 0;
    MA_start = 0; MA_a = 0; MA_b = 0;
    nxt_R1 = R1; nxt_R2 = R2;
    r_ready = 0;
    sign_valid = 0;
    sign_result = 0;
    case (state)
        IDLE: begin
            if (t_valid) begin
                nxt_state = KINV;
                MI_start = 1;
                MI_a = k;
                nxt_R1 = da;
            end
        end
        KINV: begin
            if (MI_done) begin
                nxt_state = KIDA;
                MM_start_n = 1;
            end
        end
        KIDA: begin
            if (MM_done_comb) begin
                nxt_state = ZLOAD;
                nxt_R1 = MM_result; // R1 = k^-1 * da
            end 
            MM_a = MI_result;
            MM_b = R1;
        end
        ZLOAD: begin
            if(sha256_last) begin
                nxt_state = KIZ;
                MM_start_n = 1;
            end
            if(sha256_valid) begin
                nxt_R2 = {sha256_data, R2[WIDTH-1:32]};
            end
            r_ready = 1;
        end
        KIZ: begin
            if(MM_done_comb && ml_valid) begin
                nxt_state = KIRDA;
                nxt_R2 = MM_result;
                MM_start_n = 1;
            end 
            MM_a = MI_result;
            MM_b = R2;
        end
        KIRDA: begin
            if(MM_done_comb) begin
                nxt_state = SIGN;
                nxt_R1 = MM_result;
            end
            MM_a = R1;
            MM_b = ml_data;
        end
        SIGN: begin
            if(MA_done) begin
                nxt_state = DONE;
                nxt_R1 = MA_result;
            end else begin
                MA_start = 1;
                MA_a = R1;
                MA_b = R2;
            end
        end
        DONE: begin
            nxt_state = IDLE;
            sign_valid = 1;
            sign_result = R1;
        end
    endcase
end

always @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
        R1 <= 0;
        R2 <= 0;
        MM_start <= 0;
    end
    else begin
        state <= nxt_state;
        R1 <= nxt_R1;
        R2 <= nxt_R2;
        MM_start <= MM_start_n;
    end
end

CSA_mod_inv #(
    .SUB_CONSTANT(256'h7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0),
    .MOD_CONSTANT(256'h14551231950b75fc4402da1732fc9bebf),
    .P(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141)
) u_CSA_mod_inv(
    .clk(clk),
    .rst_n(rst_n),
    .a(MI_a),
    .inv_start(MI_start),
    .inv_done(MI_done),
    .inv_result(MI_result)
);

CSA_mod_mul #(
    .MOD_CONSTANT(256'h14551231950b75fc4402da1732fc9bebf)
) u_mod_mul(
    .clk(clk),
    .rst_n(rst_n),
    .a(MM_a),
    .b(MM_b),
    .mul_start(MM_start),
    .mul_done(MM_done),
    .mul_result(MM_result)
);

CSA_mod_add #(
    .MOD_CONSTANT(256'h14551231950b75fc4402da1732fc9bebf)
) u_CSA_mod_add (
    .clk(clk),
    .rst_n(rst_n),
    .add_start(MA_start),
    .a(MA_a),
    .b(MA_b),
    .add_done(MA_done),
    .result(MA_result)
);
endmodule
