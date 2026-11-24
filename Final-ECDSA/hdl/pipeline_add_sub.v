module pipeline_add_sub (
    input clk,
    input rst_n,
    input [255:0] pipe_add_a,
    input [255:0] pipe_add_b,
    input pipe_add_start,
    input pipe_add_mode, //mode 0:add 1:sub

    // output reg pipe_add_busy,
    output reg pipe_add_done,
    output [255:0] pipe_add_result
);

localparam IDLE = 2'd0;
localparam COMPUTE = 2'd1;
localparam DONE = 2'd2;

reg [32-1:0] a,b;
reg [256-1:0] sum_FIFO,sum_FIFO_n;
reg [1:0] state,state_n;
reg [4-1:0] cnt,cnt_n;

wire [32:0] sum_temp; // 32bits sum + 1bit carry_out
reg [32-1:0] add_a_temp, add_b_temp;
reg cin_temp,cin_temp_n;

assign sum_temp = add_a_temp + add_b_temp + cin_temp;
assign pipe_add_result = sum_FIFO;

always @(*) begin
    state_n = IDLE;
    pipe_add_done = 0;
    sum_FIFO_n = sum_FIFO;
    cnt_n = cnt;
    cin_temp_n = pipe_add_mode;
    case (state)
        IDLE:begin
            state_n = IDLE;
            a = 32'hff; //degug
            b = 32'hff; //degug
            cnt_n = 0;
            sum_FIFO_n = 0;
            if (pipe_add_start) begin
                state_n = COMPUTE;
                a = pipe_add_a[31:0];
                b = (pipe_add_mode) ? ~pipe_add_b[31:0] :pipe_add_b[31:0];
            end
        end
        COMPUTE: begin
            state_n = COMPUTE;
            a = 32'hff; //degug
            b = 32'hff; //degug
            cnt_n = (cnt == 7) ? 0 : cnt+1;
            cin_temp_n = sum_temp[32];
            sum_FIFO_n = {sum_temp,sum_FIFO[255:32]};
            case (cnt)
                4'd0: begin
                    a = pipe_add_a[63:32];
                    b = (pipe_add_mode) ? ~pipe_add_b[63:32]:pipe_add_b[63:32];
                end
                4'd1: begin
                    a = pipe_add_a[95:64];
                    b = (pipe_add_mode) ? ~pipe_add_b[95:64]:pipe_add_b[95:64];
                end
                4'd2: begin
                    a = pipe_add_a[127:96];
                    b = (pipe_add_mode) ? ~pipe_add_b[127:96]:pipe_add_b[127:96];
                end
                4'd3: begin
                    a = pipe_add_a[159:128];
                    b = (pipe_add_mode) ? ~pipe_add_b[159:128]:pipe_add_b[159:128];
                end
                4'd4: begin
                    a = pipe_add_a[191:160];
                    b = (pipe_add_mode) ? ~pipe_add_b[191:160]:pipe_add_b[191:160];
                end
                4'd5: begin
                    a = pipe_add_a[223:192];
                    b = (pipe_add_mode) ? ~pipe_add_b[223:192] :pipe_add_b[223:192];
                end
                4'd6: begin
                    a = pipe_add_a[255:224];
                    b = (pipe_add_mode) ? ~pipe_add_b[255:224]:pipe_add_b[255:224];
                end
                4'd7: begin
                    state_n = DONE;
                end
            endcase
        end
        DONE:begin
            state_n = IDLE;
            pipe_add_done = 1;
            sum_FIFO_n = sum_FIFO;
        end
    endcase
end

always @(posedge clk) begin
    if (~rst_n) begin
        state <= IDLE;
        sum_FIFO <= 0;
    end
    else begin
        state <= state_n;
        sum_FIFO <= sum_FIFO_n;
    end
    cnt <= cnt_n;
    add_a_temp <= a;
    add_b_temp <= b;
    cin_temp <= cin_temp_n; 
end

endmodule