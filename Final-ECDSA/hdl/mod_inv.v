module mod_inv (
    input clk,
    input rst_n,
    input [255:0] a,
    input [255:0] p,
    input inv_start,

    // output reg inv_busy,
    output reg inv_done,
    output [255:0] inv_result
);
    localparam IDLE = 2'd0;
    localparam COMPUTE = 2'd1;
    localparam DONE = 2'd2;

    reg [1:0] state, state_n;
    reg [255:0] x, y, u, v;
    reg [255:0] x_n, y_n, u_n, v_n;

    wire [255:0] quotient, temp;
    wire [256:0] Reg1, Reg2, Reg3,Reg4;
    wire [1:0] even_odd_case;

    assign Reg1 = u - v;
    assign Reg2 = x - y;
    assign Reg3 = x + p;
    assign Reg4 = y + p;

    assign inv_result = (u == 1)? x:y;
    assign even_odd_case = {u[0],v[0]};

    //FSM
    always @(*) begin
        state_n = IDLE;
        // inv_busy = 0;
        inv_done = 0;
        u_n = u;
        v_n = v;
        x_n = x;
        y_n = y;
        case (state)
            IDLE:begin
                state_n = IDLE;
                u_n = a;
                v_n = p;
                x_n = 1;
                y_n = 0;
                if (inv_start) begin
                    state_n = COMPUTE;
                end
            end 
            COMPUTE:begin
                state_n = COMPUTE;
                // inv_busy = 1;
                u_n = u;
                x_n = x;
                v_n = v;
                y_n = y;
                if ((u != 1) & (v != 1)) begin  
                    case (even_odd_case)
                        2'b00: begin
                            u_n = {1'b0,u[255:1]};
                            x_n = x[0] ? Reg3[256:1] : {1'b0,x[255:1]};
                            v_n = {1'b0,v[255:1]};
                            y_n = y[0] ? Reg4[256:1] : {1'b0,y[255:1]};
                        end
                        2'b01: begin
                            u_n = {1'b0,u[255:1]};
                            x_n = x[0] ? Reg3[256:1] : {1'b0,x[255:1]};
                        end
                        2'b10: begin
                            v_n = {1'b0,v[255:1]};
                            y_n = y[0] ? Reg4[256:1] : {1'b0,y[255:1]};
                        end
                        2'b11: begin
                            if (Reg1[256]) begin
                                v_n = (v - u);
                                y_n = (Reg2[256])? (y - x):(y - x + p);
                            end 
                            else begin
                                u_n = (u - v);
                                x_n = (Reg2[256])? (x - y + p):(x - y);
                            end
                        end    
                endcase
                end
                else begin
                    state_n = DONE;
                end
            end
            DONE:begin
                inv_done = 1;
                // state_n = IDLE;
                state_n = DONE;
            end  
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= state_n;
            u <= u_n;
            v <= v_n;
            x <= x_n;
            y <= y_n;
        end
    end
endmodule
