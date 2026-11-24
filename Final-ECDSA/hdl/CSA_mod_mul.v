module CSA_mod_mul #(
    parameter MOD_CONSTANT = 256'h1000003d1
) (
    input clk,
    input rst_n,
    input mul_start,
    input [255:0] a,
    input [255:0] b,

    output reg mul_done,  //active for one clock cycle to show the result is available
    output [255:0] mul_result
);

localparam IDLE = 2'd0;
localparam COMPUTE = 2'd1;
localparam DONE = 2'd2;

reg [1:0] state, state_n;

// CSA_mod_add 0: add s and u, 1: add u and u
reg CSA_mod_add_start0, CSA_mod_add_start1;
reg [255:0] CSA_mod_add_a0, CSA_mod_add_a1;
reg [255:0] CSA_mod_add_b0, CSA_mod_add_b1;
wire CSA_mod_add_done0, CSA_mod_add_done1;
wire [255:0] new_s, new_u;
reg [255:0] extend_b, extend_b_n;
wire is_add = extend_b[0];

//assign output
assign mul_result = new_s;

always @(*) begin
    state_n = state;
    CSA_mod_add_start0 = 0; CSA_mod_add_start1 = 0;
    CSA_mod_add_a0 = (is_add) ? new_u : 256'd0;
    CSA_mod_add_b0 = new_s;
    CSA_mod_add_a1 = new_u;
    CSA_mod_add_b1 = new_u;
    extend_b_n = extend_b;
    mul_done = 0;
    case (state)
        IDLE: begin
            if (mul_start) begin
                state_n = COMPUTE;
                extend_b_n = {1'b1, b[255:1]};
                CSA_mod_add_start0 = 1;
                CSA_mod_add_start1 = 1;
                CSA_mod_add_a0 = (b[0]) ? a : 256'd0;
                CSA_mod_add_b0 = 256'd0;
                CSA_mod_add_a1 = a;
                CSA_mod_add_b1 = a;
            end
        end 
        COMPUTE:begin
            if(CSA_mod_add_done0 && CSA_mod_add_done1) begin
                if(extend_b == 256'd1) begin
                    state_n = DONE;
                end else begin
                    CSA_mod_add_start0 = 1;
                    CSA_mod_add_start1 = 1;
                    extend_b_n = {1'b0, extend_b[255:1]};
                end
            end
        end
        DONE:begin
            mul_done = 1;
            if(mul_start) begin
                // state_n = IDLE;
                state_n = COMPUTE;
                extend_b_n = {1'b1, b[255:1]};
                CSA_mod_add_start0 = 1;
                CSA_mod_add_start1 = 1;
                CSA_mod_add_a0 = (b[0]) ? a : 256'd0;
                CSA_mod_add_b0 = 256'd0;
                CSA_mod_add_a1 = a;
                CSA_mod_add_b1 = a;
            end
        end
    endcase
end

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        extend_b <= 0;
    end
    else begin
        state <= state_n;
        extend_b <= extend_b_n;
    end
end

CSA_mod_add #(
    .MOD_CONSTANT(MOD_CONSTANT)
) u_CSA_mod_add_0(
    .clk(clk),
    .rst_n(rst_n),
    .add_start(CSA_mod_add_start0),
    .a(CSA_mod_add_a0),
    .b(CSA_mod_add_b0),
    .add_done(CSA_mod_add_done0),
    .result(new_s)
);

CSA_mod_add #(
    .MOD_CONSTANT(MOD_CONSTANT)
) u_CSA_mod_add_1(
    .clk(clk),
    .rst_n(rst_n),
    .add_start(CSA_mod_add_start1),
    .a(CSA_mod_add_a1),
    .b(CSA_mod_add_b1),
    .add_done(CSA_mod_add_done1),
    .result(new_u)
);


endmodule
