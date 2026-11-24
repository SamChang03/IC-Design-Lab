module mod_mul (
    input clk,
    input rst_n,
    input mul_start,
    input [255:0] a,
    input [255:0] b,
    input [255:0] m,

    output mul_done,  //active for one clock cycle to show the result is available
    // output mul_ready, // remains active until the multiplier is cleared
    // output reg mul_busy,
    output [255:0] mul_result
);

localparam IDLE = 2'd0;
localparam COMPUTE = 2'd1;
localparam DONE = 2'd2;

//let mul_done only activate one cycle   
// reg ready1, ready1_n, ready0, ready0_n, mul_busy_n;
reg ready1, ready1_n, ready0, ready0_n;
assign mul_done = ready0 ^ ready1;

reg [257:0] u, s, u_n, s_n;
reg [7:0] cnt, cnt_n;
reg [1:0] state, state_n;

//caculate next s
wire [257:0] plus_u = s + u; // s + u
wire [257:0] minus_m = plus_u - {2'b00,m}; // s + u - m
wire [257:0] new_s = b[cnt] ? minus_m[257] ? plus_u : minus_m : s; // new s

//caculate next u
wire [257:0] two_u = {u[256:0],1'b0}; // 2u
wire [257:0] two_u_m = two_u - {2'b00,m}; // 2u - m
wire [257:0] new_u = two_u_m[257] ? two_u : two_u_m; // new u

//assign output
assign mul_result = s[255:0];

always @(*) begin
    state_n = IDLE;
    s_n = s;
    u_n = u;
    ready0_n = ready0;
    ready1_n = ready0;
    // mul_busy_n = mul_busy;
    cnt_n = cnt;
    case (state)
        IDLE: begin
            state_n = IDLE;
            u_n = 0;
            s_n = 0;
            ready0_n = 0;
            ready1_n = 0;
            // mul_busy_n = 1;
            cnt_n = 0;
            if (mul_start) begin
                state_n = COMPUTE;
                u_n = {2'b0,a};
                s_n = 0;
            end
        end 
        COMPUTE:begin
            state_n = COMPUTE;
            s_n = new_s;
            if (cnt == 8'd255) begin
                ready0_n = 1;
                // mul_busy_n = 0;
                state_n = DONE;
            end
            else begin
                u_n = new_u;
                cnt_n = cnt + 1;
            end
        end
        DONE:begin
            state_n = IDLE;
            // mul_busy_n = 0;  
        end
    endcase
end

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        ready0 <= 0;
        ready1 <= 0;
        // mul_busy <= 0;
    end
    else begin
        state <= state_n;
        ready0 <= ready0_n;
        ready1 <= ready1_n;
        // mul_busy <= mul_busy_n;
    end
    s <= s_n;
    u <= u_n;
    cnt <= cnt_n;
end

endmodule
