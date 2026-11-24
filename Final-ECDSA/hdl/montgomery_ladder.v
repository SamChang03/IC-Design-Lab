module montgomery_ladder #(parameter WIDTH = 256) (
    input clk,
    input rst_n,
    input [255:0] m,

    //ECC to ML
    input ECC_ML_valid,
    input ECC_ML_last,
    input [WIDTH-1:0] ECC_ML_data, //input tdata k
    output reg ECC_ML_ready,

    //ML to ECC
    input ML_ECC_ready,    
    output reg ML_ECC_valid, // ML = Montgomery Ladder
    output reg ML_ECC_last,
    output [2*WIDTH-1:0] ML_ECC_data // output {x,y}
);

    localparam Gx = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    localparam Gy = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    localparam Gz = 256'd1;
    localparam Ox = 256'd1;
    localparam Oy = 256'd1;
    localparam Oz = 256'd1;

    localparam ML_IDLE = 0;
    localparam ML_ITERATION = 1;
    localparam ML_WAIT_ADD_DONE = 2;
    localparam ML_DONE = 3;

    reg [2:0] ML_state, ML_state_n;
    reg add_start, double_start;
    wire add_done,  double_done;

    reg [255:0] Qx,Qy,Qz,Rx,Ry,Rz;
    reg [255:0] Qx_n,Qy_n,Qz_n,Rx_n,Ry_n,Rz_n;
    reg [255:0] k, k_n;

    reg [255:0] add_in_x1, add_in_y1, add_in_z1, 
                 add_in_x2, add_in_y2, add_in_z2;
    wire [255:0] add_out_x, add_out_y, add_out_z;

    reg [255:0] double_in_x, double_in_y, double_in_z; 
    wire [255:0] double_out_x, double_out_y, double_out_z;


    ECPA u_point_add(
        //input
        .clk(clk),
        .rst_n(rst_n),
        .m(m),
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
        .m(m),
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

    always @(*) begin
        ML_state_n = ML_IDLE;
        ECC_ML_ready = 0;
        ML_ECC_valid = 0;
        add_start = 0;
        double_start = 0;
        k_n = k;
        Qx_n = Qx;
        Qy_n = Qy;
        Qz_n = Qz;
        Rx_n = Rx;
        Ry_n = Ry;
        Rz_n = Rz; 
        case (ML_state)
            ML_IDLE:begin
                ML_state_n = ML_IDLE;
                ECC_ML_ready = 1;
                k_n = ECC_ML_data;
                Qx_n = Ox;
                Qy_n = Oy;
                Qz_n = Oz;
                Rx_n = Gx;
                Ry_n = Gy;
                Rz_n = Gz;
                if (ECC_ML_valid) begin
                    ML_state_n = ML_ITERATION;
                end
            end 
            ML_ITERATION:begin
                ML_state_n = ML_ITERATION;
                if (k == 0) begin
                    ML_state_n = ML_DONE;
                end
                else begin
                    ML_state_n = ML_WAIT_ADD_DONE;
                    add_start = 1;
                    double_start = 1;

                    add_in_x1 = Qx;
                    add_in_y1 = Qy;
                    add_in_z1 = Qz;

                    add_in_x2 = Rx;
                    add_in_y2 = Ry;
                    add_in_z2 = Rz;
                    if (k[0]) begin 
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
            ML_WAIT_ADD_DONE:begin
                ML_state_n = ML_WAIT_ADD_DONE;
                if (add_done & double_done) begin
                    ML_state_n = ML_ITERATION;
                    k_n = k >> 1;
                    if (k[0]) begin 
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
            ML_DONE:begin
                ML_state_n = ML_DONE;
                ML_ECC_valid = 1;
                if (ECC_ML_ready) begin
                    ML_state_n = ML_IDLE;
                end
            end 
        endcase
    end
    always @(posedge clk) begin
        if (~rst_n) begin
            ML_state <= ML_IDLE;
        end
        else begin
            ML_state <= ML_state_n;
        end
        Qx <= Qx_n;
        Qy <= Qy_n;
        Qz <= Qz_n;
        Rx <= Rx_n;
        Ry <= Ry_n;
        Rz <= Rz_n;
        k  <= k_n;
    end
endmodule
