module ECPA (
    input clk,
    input rst_n,

    input add_start,
    input [255:0] X_1,
    input [255:0] Y_1,
    input [255:0] Z_1,
    input [255:0] X_2,
    input [255:0] Y_2,
    input [255:0] Z_2,

    output reg add_done,
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
localparam STEP_9 = 5'd9;
localparam STEP_10 = 5'd10;
localparam STEP_11 = 5'd11;
localparam STEP_12 = 5'd12;
localparam STEP_13 = 5'd13;
localparam DONE = 5'd20;

reg [4:0] state, state_n;
reg [1:0] cnt,cnt_n;
reg mul_start,mul_start_n;
reg adder_start, adder_start_n;
reg [255:0] A,B,C,D,X1,Y1,Z1,X2,Y2,Z2;
reg [255:0] A_n,B_n,C_n,D_n,X1_n,Y1_n,Z1_n,X2_n,Y2_n,Z2_n;

reg [255:0] in_a, in_b, in_a_2, in_b_2,
            in_a_3, in_b_3, in_a_4, in_b_4;

wire [255:0] mul_out, mul_out_2,
             mul_out_3, mul_out_4,
             add_out,
             sub_out, sub_out_2;

// wire mul_ready,mul_done,mul_busy;
wire mul_done, mul_done_2, mul_done_3, mul_done_4;
wire mul_done_comb = mul_done && mul_done_2 && mul_done_3 && mul_done_4 && (mul_start == 1'b0);

wire adder_done, sub_done, sub_done_2;

assign X3 = (add_done)? X1 : 0 ;
assign Y3 = (add_done)? Y1 : 0 ;
assign Z3 = (add_done)? Z1 : 0 ;

always @(*) begin
    state_n = state;
    mul_start_n = 0;
    adder_start_n = 0;
    add_done = 0;

    A_n = A;
    B_n = B;
    C_n = C;
    D_n = D;
    X1_n = X1;
    Y1_n = Y1;
    Z1_n = Z1;
    X2_n = X2;
    Y2_n = Y2;
    Z2_n = Z2;
    in_a = 0; 
    in_b = 0;  
    in_a_2 = 0;  
    in_b_2 = 0; 
    in_a_3 = 0; 
    in_b_3 = 0; 
    in_a_4 = 0; 
    in_b_4 = 0;
    cnt_n = cnt;
    case (state)
        IDLE:begin
            state_n = IDLE;
            add_done = 1;
            if (add_start) begin
                if(Z_1 == 0) begin
                    state_n = DONE;
                    X1_n = X_2;
                    Y1_n = Y_2;
                    Z1_n = Z_2;
                end else if (Z_2 == 0) begin
                    state_n = DONE;
                    X1_n = X_1;
                    Y1_n = Y_1;
                    Z1_n = Z_1;
                end else begin
                    state_n = STEP_1;
                    mul_start_n = 1;
                    A_n = 0;
                    B_n = 0;
                    C_n = 0;
                    D_n = 0;
                    X1_n = X_1;
                    Y1_n = Y_1;
                    Z1_n = Z_1;
                    X2_n = X_2;
                    Y2_n = Y_2;
                    Z2_n = Z_2;
                    cnt_n = 0;
                end
            end
        end 
        STEP_1:begin
            state_n = (mul_done_comb)? STEP_2 : STEP_1;
            mul_start_n = (mul_done_comb) ? 1 : 0;
            //multiplication IO
            in_a = Z1;
            in_b = Z1;
            A_n = (mul_done_comb) ? mul_out : A; // A = Z1^2
            //multiplication 2 IO
            in_a_2 = Z2;
            in_b_2 = Z2;
            B_n = (mul_done_comb) ? mul_out_2 : B; // B = Z2^2
            //multiplication 3 IO
            in_a_3 = Y1;
            in_b_3 = Z2;
            C_n = (mul_done_comb) ? mul_out_3 : C; // C = Y1Z2
            //multiplication 4 IO
            in_a_4 = Y2;
            in_b_4 = Z1;
            D_n = (mul_done_comb) ? mul_out_4 : D; // D = Y2Z1
        end
        STEP_2:begin
            state_n = (mul_done_comb)? STEP_3 : STEP_2;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            mul_start_n =0;
            //multiplication IO
            in_a = X2;
            in_b = A;
            A_n = (mul_done_comb) ? mul_out : A; // A = X2*Z1^2 = U'
            //multiplication 2 IO
            in_a_2 = X1;
            in_b_2 = B;
            B_n = (mul_done_comb) ? mul_out_2 : B; // B = X1*Z2^2 = U
            //multiplication 3 IO
            in_a_3 = B;
            in_b_3 = C;
            C_n = (mul_done_comb) ? mul_out_3 : C; // C = Y1Z2^3 = S
            //multiplication 4 IO
            in_a_4 = A;
            in_b_4 = D;
            D_n = (mul_done_comb) ? mul_out_4 : D; // D = Y2Z1^3 = S'
            
        end
        STEP_3:begin
            if(sub_done && sub_done_2 && adder_start == 1'b0) begin
                state_n = STEP_4;
                mul_start_n = 1;
                adder_start_n = 1;
            end
            //sub 3 IO
            in_a_3 = A;
            in_b_3 = B;
            A_n = sub_out; // A = U'-U = H
            //sub 4 IO
            in_a_4 = D;
            in_b_4 = C;
            D_n = sub_out_2; // D = S'-S = R
        end
        STEP_4:begin
            state_n = (mul_done_comb)? STEP_5 : STEP_4;
            mul_start_n = (mul_done_comb) ? 1 : 0;
            //multiplication IO
            in_a = Z2;
            in_b = Z1;
            Z1_n = (mul_done_comb) ? mul_out : Z1; // Z1 = Z1*Z2
            //multiplication 2 IO
            in_a_2 = A;
            in_b_2 = A;
            Z2_n = (mul_done_comb) ? mul_out_2 : Z2; // Z2 = H^2
            //multiplication 3 IO
            in_a_3 = D;
            in_b_3 = D;
            X1_n = (mul_done_comb) ? mul_out_3 : X1; // X1 = R^2
            //add 4 IO
            in_a_4 = B;
            in_b_4 = B;
            X2_n = (adder_done) ? add_out :X2; // X2 = 2U
        end
        STEP_5:begin
            state_n = (mul_done_comb)? STEP_6 : STEP_5;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            mul_start_n = 0;
            //multiplication IO
            in_a = Z1;
            in_b = A;
            Z1_n = (mul_done_comb) ? mul_out : Z1; // Z1 = H*Z1*Z2 done
            //multiplication 2 IO
            in_a_2 = Z2;
            in_b_2 = A;
            A_n = (mul_done_comb) ? mul_out_2 : A; // A = H^3
            //multiplication 3 IO
            in_a_3 = B;
            in_b_3 = Z2;
            B_n = (mul_done_comb) ? mul_out_3 : B; // B = UH^2
            //multiplication 4 IO
            in_a_4 = X2;
            in_b_4 = Z2;
            Z2_n = (mul_done_comb) ? mul_out_4 : Z2; // Z2 = 2UH^2
        end
        STEP_6:begin
            if(sub_done && adder_start == 1'b0) begin
                state_n = STEP_7;
                adder_start_n = 1;
            end
            //sub 3 IO
            in_a_3 = X1;
            in_b_3 = A;
            X1_n = sub_out; // X1 = R^2 - H^3
        end
        STEP_7:begin
            if(sub_done && adder_start == 1'b0) begin
                state_n = STEP_8;
                adder_start_n = 1;
            end
            //sub 3 IO
            in_a_3 = X1;
            in_b_3 = Z2;
            X1_n = sub_out; // X1 = R^2 - H^3 - 2UH^2 done
        end 
        STEP_8:begin
            if(sub_done && adder_start == 1'b0) begin
                state_n = STEP_9;
                mul_start_n = 1;
            end
            //sub 3 IO
            in_a_3 = B;
            in_b_3 = X1;
            X2_n = sub_out; // X2 = UH^2 - X1
        end
        STEP_9:begin
            state_n = (mul_done_comb)? STEP_10 : STEP_9;
            adder_start_n = (mul_done_comb) ? 1 : 0;
            mul_start_n = 0;
            //multiplication IO
            in_a = D;
            in_b = X2;
            X2_n = (mul_done_comb) ? mul_out : X2; // X2 = R*(UH^2 - X1)
            //multiplication IO
            in_a_2 = C;
            in_b_2 = A;
            Z2_n = (mul_done_comb) ? mul_out_2 : Z2; // Z2 = S*H^3   
        end
        STEP_10:begin
            if(sub_done && adder_start == 1'b0) begin
                state_n = DONE;
            end
            // state_n = DONE;
            mul_start_n = 0;
            //sub 3 IO
            in_a_3 = X2;
            in_b_3 = Z2;
            Y1_n = sub_out; // Y1 = R*(UH^2 - X1) - S*H^3 Done
        end
        DONE:begin
            state_n = IDLE;
            mul_start_n = 0;
            add_done = 1;
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
    X1 <= X1_n;
    Y1 <= Y1_n;
    Z1 <= Z1_n;
    X2 <= X2_n;
    Y2 <= Y2_n;
    Z2 <= Z2_n;
    cnt <= cnt_n;
    mul_start <= mul_start_n;
    adder_start <= adder_start_n;
end

// mod_mul u_ECPA_mul_1(
CSA_mod_mul u_ECPA_mul_1(
    .clk(clk),
    .rst_n(rst_n),
    .mul_start(mul_start),
    .a(in_a),
    .b(in_b),
    .mul_done(mul_done),  //active for one clock cycle to show the result is available
    .mul_result(mul_out) // mul_out = a * b mod m
);

// mod_mul u_ECPA_mul_2(
CSA_mod_mul u_ECPA_mul_2(
    .clk(clk),
    .rst_n(rst_n),
    .mul_start(mul_start),
    .a(in_a_2),
    .b(in_b_2),
    .mul_done(mul_done_2),  //active for one clock cycle to show the result is available
    .mul_result(mul_out_2) // mul_out = a * b mod m
);
// mod_mul u_ECPA_mul_3(
CSA_mod_mul u_ECPA_mul_3(
    .clk(clk),
    .rst_n(rst_n),
    .mul_start(mul_start),
    .a(in_a_3),
    .b(in_b_3),
    .mul_done(mul_done_3),  //active for one clock cycle to show the result is available
    .mul_result(mul_out_3) // mul_out = a * b mod m
);
// mod_mul u_ECPA_mul_4(
CSA_mod_mul u_ECPA_mul_4(
    .clk(clk),
    .rst_n(rst_n),
    .mul_start(mul_start),
    .a(in_a_4),
    .b(in_b_4),
    .mul_done(mul_done_4),  //active for one clock cycle to show the result is available
    .mul_result(mul_out_4) // mul_out = a * b mod m
);


CSA_mod_add u_ECPA_add (
    .clk(clk),
    .rst_n(rst_n),
    .add_start(adder_start),
    .a(in_a_4),
    .b(in_b_4),
    .add_done(adder_done),
    .result(add_out)
);

CSA_mod_sub u_ECPA_sub_1 (
    .clk(clk),
    .rst_n(rst_n),
    .sub_start(adder_start),
    .a(in_a_3),
    .b(in_b_3),
    .sub_done(sub_done),
    .result(sub_out)
);

CSA_mod_sub u_ECPA_sub_2 (
    .clk(clk),
    .rst_n(rst_n),
    .sub_start(adder_start),
    .a(in_a_4),
    .b(in_b_4),
    .sub_done(sub_done_2),
    .result(sub_out_2)
);

endmodule