module ECC_top #(parameter WIDTH = 256) (
    input clk,
    input rst_n,

    //ECC to ML
    input SHA_ECC_valid,
    // input SHA_ECC_last,
    input [WIDTH-1:0] SHA_ECC_data, //input tdata k
    // output reg SHA_ECC_ready,

    //ML to ECC
    // input ECC_SIGN_ready,    
    output reg ECC_SIGN_valid, // ML = Montgomery Ladder
    // output ECC_SIGN_last,
    output [WIDTH-1:0] ECC_SIGN_data // output {x,y}
);
    // secp256k1 parameter b,p and initail point G(x,y)
    localparam Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    localparam Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    localparam Gz = 256'd1;
    localparam Ox = 256'd1;
    localparam Oy = 256'd1;
    localparam Oz = 256'd0;
    localparam p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    localparam n = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;


    localparam ECC_IDLE = 3'd0;
    localparam ECC_ITERATION = 3'd1;
    localparam ECC_WAIT_ADD_DONE = 3'd2;
    localparam ECC_Z_SQUARE = 3'd3;
    localparam ECC_Z_INVERSE = 3'd4;
    localparam ECC_JACOBIAN_AFFINE = 3'd5;
    localparam ECC_DONE = 3'd6;

    reg [2:0] ECC_state, ECC_state_n;
    reg add_start, double_start, mul_start,mul_start_n, inv_start, inv_start_n;
    wire add_done, double_done, mul_done, inv_done;

    reg [255:0] Qx,Qy,Qz,Rx,Ry,Rz;
    reg [255:0] Qx_n,Qy_n,Qz_n,Rx_n,Ry_n,Rz_n;
    reg [256:0] k, k_n;
    wire action_bit = k[256];

    reg [255:0] add_in_x1, add_in_y1, add_in_z1, 
                 add_in_x2, add_in_y2, add_in_z2;
    wire [255:0] add_out_x, add_out_y, add_out_z;

    reg [255:0] double_in_x, double_in_y, double_in_z; 
    wire [255:0] double_out_x, double_out_y, double_out_z;

    reg [255:0] mul_in_a, mul_in_b;
    wire [255:0] mul_out;

    reg [255:0] inv_in;
    wire [255:0] inv_out;

    wire [255:0] x_jacobian,z_jacobian;

    assign ECC_SIGN_data = Rx;
    // assign ECC_SIGN_last = ECC_SIGN_valid;


    ECPA u_point_add(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .add_start(add_start),

        .X_1(add_in_x1),
        .Y_1(add_in_y1),
        .Z_1(add_in_z1),        

        .X_2(add_in_x2),
        .Y_2(add_in_y2),
        .Z_2(add_in_z2),

        //output
        .add_done(add_done),

        .X3(add_out_x),
        .Y3(add_out_y),
        .Z3(add_out_z)
    );

    ECPD u_point_double(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .double_start(double_start),

        .X1(double_in_x),
        .Y1(double_in_y),
        .Z1(double_in_z),        

        //output
        .double_done(double_done),

        .X3(double_out_x),
        .Y3(double_out_y),
        .Z3(double_out_z)
    );
    CSA_mod_mul u_ECPA_mul_1(
        .clk(clk),
        .rst_n(rst_n),
        .mul_start(mul_start),
        .a(mul_in_a),
        .b(mul_in_b),
        .mul_done(mul_done),  //active for one clock cycle to show the result is available
        .mul_result(mul_out) // mul_out = a * b mod m
    );

    CSA_mod_inv u_mod_inv(
        .clk(clk),
        .rst_n(rst_n),
        .a(inv_in),
        .inv_start(inv_start),
        .inv_done(inv_done),
        .inv_result(inv_out)
    );

    always @(*) begin
        ECC_state_n = ECC_IDLE;
        // SHA_ECC_ready = 0;
        ECC_SIGN_valid = 0;
        add_start = 0;
        double_start = 0;
        mul_start_n = 0;
        inv_start_n = 0;
        k_n = k;

        Qx_n = Qx;
        Qy_n = Qy;
        Qz_n = Qz;
        Rx_n = Rx;
        Ry_n = Ry;
        Rz_n = Rz;

        add_in_x1 = 0;
        add_in_y1 = 0;
        add_in_z1 = 0;

        add_in_x2 = 0;
        add_in_y2 = 0;
        add_in_z2 = 0;

        double_in_x = 0;
        double_in_y = 0;
        double_in_z = 0;

        mul_in_a = 0;
        mul_in_b = 0;

        inv_in = 0; 
        case (ECC_state)
            ECC_IDLE:begin
                ECC_state_n = ECC_IDLE;
                // SHA_ECC_ready = 1;
                k_n = {SHA_ECC_data, 1'b1};
                Qx_n = Ox;
                Qy_n = Oy;
                Qz_n = Oz;
                Rx_n = Gx;
                Ry_n = Gy;
                Rz_n = Gz;
                if (SHA_ECC_valid) begin
                    ECC_state_n = ECC_ITERATION;
                end
            end 
            ECC_ITERATION:begin
                ECC_state_n = ECC_ITERATION;
                if (k[255:0] == 0) begin
                    ECC_state_n = ECC_Z_SQUARE;
                    mul_start_n = 1;
                end
                else begin
                    ECC_state_n = ECC_WAIT_ADD_DONE;
                    add_start = 1;
                    double_start = 1;

                    add_in_x1 = Qx;
                    add_in_y1 = Qy;
                    add_in_z1 = Qz;

                    add_in_x2 = Rx;
                    add_in_y2 = Ry;
                    add_in_z2 = Rz;
                    if (action_bit) begin 
                        double_in_x = Rx;
                        double_in_y = Ry;
                        double_in_z = Rz;
                    end
                    else begin
                        double_in_x = Qx;
                        double_in_y = Qy;
                        double_in_z = Qz;
                    end
                end
            end
            ECC_WAIT_ADD_DONE:begin
                ECC_state_n = ECC_WAIT_ADD_DONE;
                if (add_done & double_done) begin
                    ECC_state_n = ECC_ITERATION;
                    k_n = k << 1;
                    if (action_bit) begin 
                        Qx_n = add_out_x;
                        Qy_n = add_out_y;
                        Qz_n = add_out_z;
                        Rx_n = double_out_x;
                        Ry_n = double_out_y;
                        Rz_n = double_out_z;
                    end
                    else begin
                        Qx_n = double_out_x;
                        Qy_n = double_out_y;
                        Qz_n = double_out_z;
                        Rx_n = add_out_x;
                        Ry_n = add_out_y;
                        Rz_n = add_out_z;
                    end
                end
            end
            ECC_Z_SQUARE:begin
                ECC_state_n = (mul_done && mul_start == 1'b0) ? ECC_Z_INVERSE : ECC_Z_SQUARE;
                inv_start_n = (mul_done && mul_start == 1'b0) ? 1 : 0;
                mul_in_a = Qz;
                mul_in_b = Qz;
                Rz_n = (mul_done) ? mul_out : Rz; // Rz = Z^2
            end
            ECC_Z_INVERSE:begin
                ECC_state_n = (inv_done) ? ECC_JACOBIAN_AFFINE : ECC_Z_INVERSE;
                mul_start_n = (inv_done) ? 1 : 0;
                inv_in = Rz;
                Rz_n = (inv_done) ? inv_out : Rz; // Rz = (Z^2)^-1
            end
            ECC_JACOBIAN_AFFINE:begin
                ECC_state_n = (mul_done && mul_start == 1'b0) ? ECC_DONE : ECC_JACOBIAN_AFFINE;
                mul_in_a = Qx; // Qx = X
                mul_in_b = Rz; // Rz = (Z^2)^-1
                Rx_n = (mul_done) ? mul_out: Rx; // Rx = x : Final x @ affine coordination
            end
            ECC_DONE:begin
                ECC_state_n = ECC_DONE;
                ECC_SIGN_valid = 1;
                // if (ECC_SIGN_ready) begin
                //     ECC_state_n = ECC_IDLE;
                // end
            end 
        endcase
    end
    always @(posedge clk) begin
        if (~rst_n) begin
            ECC_state <= ECC_IDLE;
        end
        else begin
            ECC_state <= ECC_state_n;
        end
        inv_start <= inv_start_n;
        mul_start <= mul_start_n;

        Qx <= Qx_n;
        Qy <= Qy_n;
        Qz <= Qz_n;
        Rx <= Rx_n;
        Ry <= Ry_n;
        Rz <= Rz_n;
        k  <= k_n;
    end
endmodule
