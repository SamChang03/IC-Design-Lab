module ECPD (
    input clk,
    input rst_n,

    input double_start,
    input [255:0] X1,
    input [255:0] Y1,
    input [255:0] Z1,

    output reg double_done,
    output [255:0] X3,
    output [255:0] Y3,
    output [255:0] Z3
);

localparam IDLE = 5'd0;
localparam STEP_1 = 5'd1;
localparam STEP_2 = 5'd2;
localparam STEP_3 = 5'd3;
localparam STEP_4 = 5'd4;
localparam STEP_5 = 5'd5;
localparam STEP_6 = 5'd6;
localparam STEP_7 = 5'd7;
localparam STEP_8 = 5'd8;
localparam DONE = 5'd20;

reg [4:0] state, state_n;
reg mul_start,mul_start_n;
reg adder_start, adder_start_n;
reg [255:0] A,B,C,D,X,Y,Z;
reg [255:0] A_n,B_n,C_n,D_n,X_n,Y_n,Z_n;

reg [255:0] in_a, in_b, 
            in_a_2, in_b_2,
            in_a_3, in_b_3,
            in_a_4, in_b_4;
wire [255:0] mul_out, mul_out_2, 
             add_out, add_out_2,
             sub_out;

// wire mul_ready,mul_done,mul_busy;
wire mul_done,mul_done_2;
wire mul_done_comb = mul_done && mul_done_2 && (mul_start == 1'b0);

wire adder_done, adder_done_2, sub_done;

assign X3 = (double_done)? X : 0 ;
assign Y3 = (double_done)? Y : 0 ;
assign Z3 = (double_done)? Z : 0 ;

always @(*) begin
    state_n = state;
    mul_start_n = 0;
    adder_start_n = 0;
    double_done = 0;

    A_n = A;
    B_n = B;
    C_n = C;
    D_n = D;
    X_n = X;
    Y_n = Y;
    Z_n = Z;
    in_a = 0; 
    in_b = 0; 
    in_a_2 = 0; 
    in_b_2 = 0;
    in_a_3 = 0; 
    in_b_3 = 0;
    in_a_4 = 0; 
    in_b_4 = 0; 
    case (state)
        IDLE:begin
            state_n = IDLE;
            // double_done = 0;
            double_done = 1;
            if (double_start) begin
                state_n = STEP_1;
                mul_start_n = 1;
                adder_start_n = 1;
                A_n = 0;
                B_n = 0;
                C_n = 0;
                D_n = 0;
                X_n = X1;
                Y_n = Y1;
                Z_n = Z1;
            end
        end 
        STEP_1:begin
            state_n = (mul_done_comb)? STEP_2 : STEP_1;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            //multiplication IO
            in_a = Y;
            in_b = Y;
            A_n = (mul_done_comb) ? mul_out : A; //A = Y^2
            //multiplication 2 IO
            in_a_2 = X;
            in_b_2 = X;
            B_n = (mul_done_comb) ? mul_out_2 : B; //B = X^2
            //add 1 IO
            in_a_3 = X;
            in_b_3 = X;
            C_n = (mul_done_comb) ? add_out : C; //C = 2X
        end
        STEP_2:begin
            if (adder_done && adder_done_2 && adder_start == 1'b0) begin
                state_n = STEP_3;
                mul_start_n = 1;
                adder_start_n = 1;
            end
            //addtion/substraction  1 IO
            in_a_3 = C;
            in_b_3 = C;
            C_n = (adder_done) ? add_out : C; // C = 4X
            //addtion/substraction 2 IO
            in_a_4 = B;
            in_b_4 = B;
            D_n = (adder_done_2) ? add_out_2 : D; // D = 2X^2
        end
        STEP_3:begin
            state_n = (mul_done_comb) ? STEP_4 : STEP_3;
            mul_start_n = (mul_done_comb) ? 1 : 0;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            //multiplication IO
            in_a = C;
            in_b = A;
            C_n = (mul_done_comb) ? mul_out : C; //C = 4XY^2 = S
            //multiplication 2 IO
            in_a_2 = Y;
            in_b_2 = Z;
            Z_n = (mul_done_comb) ? mul_out_2 : Z; //Z = YZ
            //addtion/substraction 1 IO
            in_a_3 = B;
            in_b_3 = D;
            B_n = (mul_done_comb) ? add_out : B; // B = 3X^2 = M
        end
        STEP_4:begin
            state_n = (mul_done_comb) ? STEP_5 : STEP_4;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            mul_start_n = 0;
            //multiplication IO
            in_a = A;
            in_b = A;
            A_n = (mul_done_comb) ? mul_out : A; //A = Y^4
            //multiplication 2 IO
            in_a_2 = B;
            in_b_2 = B;
            X_n = (mul_done_comb) ? mul_out_2 : X; //X = M^2
            //addtion/substraction 1 IO
            in_a_3 = Z;
            in_b_3 = Z;
            Z_n = (mul_done_comb) ? add_out : Z; //Z = 2YZ done
            //addtion/substraction 2 IO
            in_a_4 = C;
            in_b_4 = C;
            Y_n = (mul_done_comb) ? add_out_2 : Y; //Y = 2S
        end
        STEP_5:begin
            if (adder_done && sub_done && adder_start == 1'b0) begin
                state_n = STEP_6;
                mul_start_n = 0;
                adder_start_n = 1;
            end
            //addtion/substraction 1 IO
            in_a_4 = X;
            in_b_4 = Y;
            X_n = (sub_done) ? sub_out : X; //X = M^2 - 2S done
            //addtion/substraction 2 IO
            in_a_3 = A;
            in_b_3 = A;
            A_n = (adder_done) ? add_out : A; //A = 2Y^4
        end
        STEP_6:begin
            if (adder_done && sub_done && adder_start == 1'b0) begin
                state_n = STEP_7;
                mul_start_n = 1;
                adder_start_n = 1;
            end
            //addtion/substraction 1 IO
            in_a_4 = C;
            in_b_4 = X;
            C_n = (sub_done) ? sub_out : C; //C = S - X
            //addtion/substraction 2 IO
            in_a_3 = A;
            in_b_3 = A;
            A_n = (adder_done) ? add_out : A; //Y = 4Y^4
        end
        STEP_7:begin
            state_n = (mul_done_comb) ? STEP_8 : STEP_7;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            //multiplication IO
            in_a = B;
            in_b = C;
            B_n = (mul_done_comb) ? mul_out : B; //B = M*(S - X)
            //addtion/substraction 1 IO
            in_a_3 = A;
            in_b_3 = A;
            Y_n = (mul_done_comb) ? add_out : Y; //Y = 8Y^4
        end 
        STEP_8:begin
            if (sub_done && adder_start == 1'b0) begin
                state_n = DONE;
            end
            // state_n = DONE;
            //addtion/substraction IO
            in_a_4 = B;
            in_b_4 = Y;
            Y_n = (sub_done) ? sub_out : Y; //Y = M*(S - X) - 8Y^4 done
        end
        DONE:begin
            state_n = IDLE;
            double_done = 1;
        end 
    endcase
end

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
    end
    else begin
        state <= state_n;
    end
    A <= A_n;
    B <= B_n;
    C <= C_n;
    D <= D_n;
    X <= X_n;
    Y <= Y_n;
    Z <= Z_n;
    mul_start <= mul_start_n;
    adder_start <= adder_start_n;
end

CSA_mod_mul u_ECPD_mul(
    .clk(clk),
    .rst_n(rst_n),
    .mul_start(mul_start),
    .a(in_a),
    .b(in_b),
    .mul_done(mul_done),  //active for one clock cycle to show the result is available
    .mul_result(mul_out) // mul_out = a * b mod m
);

CSA_mod_mul u_ECPA_mul_2(
    .clk(clk),
    .rst_n(rst_n),
    .mul_start(mul_start),
    .a(in_a_2),
    .b(in_b_2),
    .mul_done(mul_done_2),
    .mul_result(mul_out_2) // mul_out = a * b mod m
);

CSA_mod_add u_ECPD_add (
    .clk(clk),
    .rst_n(rst_n),
    .add_start(adder_start),
    .a(in_a_3),
    .b(in_b_3),
    .add_done(adder_done),
    .result(add_out)
);

CSA_mod_add u_ECPD_add_2 (
    .clk(clk),
    .rst_n(rst_n),
    .add_start(adder_start),
    .a(in_a_4),
    .b(in_b_4),
    .add_done(adder_done_2),
    .result(add_out_2)
);

CSA_mod_sub u_ECPD_sub (
    .clk(clk),
    .rst_n(rst_n),
    .sub_start(adder_start),
    .a(in_a_4),
    .b(in_b_4),
    .sub_done(sub_done),
    .result(sub_out)
);

endmodule
