module decode(
    input clk,
    input srst_n,             
    input data_in,
    input [2:0] mask_pattern,                         
    input codeword_start,
    input [5:0] i,
    input [5:0] j,
    input [5:0] loc_y,
    input [5:0] loc_x,
    input [1:0] type,       

    output reg codeword        
);

localparam degree_0 = 2'd0;
localparam degree_90 = 2'd1;
localparam degree_180 = 2'd2;
localparam degree_270 = 2'd3;

reg [2:0] mask_pattern_reg,mask_pattern_reg_n;
reg [5:0] i_decode,j_decode;


always @(*) begin
    i_decode = i - loc_y;
    j_decode = j - loc_x;
    case (type) //synopsis parallel case
        degree_0: begin
            i_decode = i - loc_y;
            j_decode = j - loc_x;
        end
        degree_90: begin
            i_decode = j - loc_x;
            j_decode = loc_y - i;
        end
        degree_180: begin
            i_decode = loc_y - i;
            j_decode = loc_x - j;
        end
        degree_270: begin
            i_decode = loc_x - j;
            j_decode = i - loc_y;
        end
    endcase
end

//lock mask_pattern
always @(*) begin
    mask_pattern_reg_n = mask_pattern_reg;
    if(codeword_start) begin
       mask_pattern_reg_n = mask_pattern; 
    end 
end

//change codeword pattern
always @(*) begin
    codeword = data_in;
    case (mask_pattern_reg)
        3'd0:begin
            codeword = data_in^(((i_decode+j_decode)%2)==0);
        end
        3'd1:begin
            codeword = data_in^(((i_decode)%2)==0);
        end
        3'd2:begin
            codeword = data_in^(((j_decode)%3)==0);
        end
        3'd3:begin
            codeword = data_in^(((i_decode+j_decode)%3)==0);
        end
        3'd4:begin
            codeword = data_in^((((i_decode/2)+(j_decode/3))%2)==0);
        end
        3'd5:begin
            codeword = data_in^(((i_decode*j_decode)%2 +(i_decode*j_decode)%3 )==0);
        end
        3'd6:begin
            codeword = data_in^((((i_decode*j_decode)%2 +(i_decode*j_decode)%3)%2)==0);
        end
        3'd7:begin
            codeword = data_in^((( ((i_decode*j_decode)%3) +((i_decode+j_decode)%2))%2)==0);
        end  
    endcase
end

//squential
always @(posedge clk) begin
    if (~srst_n) begin
        mask_pattern_reg <= 0;
    end
    else begin
        mask_pattern_reg <= mask_pattern_reg_n;
    end 
end

endmodule