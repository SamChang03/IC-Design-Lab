/*
* Module      : rop3_lut16
* Description : Implement this module using the look-up table (LUT) 
*               This module should support all the 15-modes listed in table-1
*               For modes not in the table-1, set the Result to 0
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register 
*/

module rop3_lut16
#(
  parameter N = 8
)
(
  input clk,
  input din_valid,
  input [3*N-1:0] din_data,
  input [7:0] Mode,
  input [1:0] Order,
  output dout_valid,
  output [N-1:0] dout_data
);

///********** IO Defination **********///

//input after ff
reg din_valid_ff;
reg [3*N-1:0] din_data_ff;
reg [7:0] Mode_ff;
reg [1:0] Order_ff;

//output before ff
reg dout_valid_ff;
reg [N-1:0] result;
wire [N-1:0] dout_data_ff;

assign dout_data_ff = result;

//connect to output wire
reg dout_valid_reg;
reg [N-1:0] dout_data_reg;
assign dout_valid =  dout_valid_reg;
assign dout_data =  dout_data_reg;

//max med min reg
reg [N-1:0] max;
reg [N-1:0] med;
reg [N-1:0] min;
wire [N-1:0] array [0:2];

assign array[0] = din_data_ff[3*N-1:2*N];
assign array[1] = din_data_ff[2*N-1:N];
assign array[2] = din_data_ff[N-1:0];

//PSD
reg [N-1:0] P;
reg [N-1:0] S;
reg [N-1:0] D;

///********** Conbinational **********///

//valid controll
 always @(*)
  dout_valid_ff = din_valid_ff;

//find min med min
always @(*) begin
  if(array[0]>= array[1] & array[1]>=array[2])begin //0>1>2
    max = din_data_ff[3*N-1:2*N];
    med = din_data_ff[2*N-1:N];
    min = din_data_ff[N-1:0];
  end
  else if (array[0]>= array[2] & array[2]>=array[1]) begin //0>2>1
    max = din_data_ff[3*N-1:2*N];
    med = din_data_ff[N-1:0];
    min = din_data_ff[2*N-1:N];
  end
  else if (array[1]>= array[0] & array[0]>=array[2]) begin //1>0>2
    max = din_data_ff[2*N-1:N];
    med = din_data_ff[3*N-1:2*N];
    min = din_data_ff[N-1:0];
  end
  else if (array[1]>= array[2] & array[2]>=array[0]) begin //1>2>0
    max = din_data_ff[2*N-1:N];
    med = din_data_ff[N-1:0];
    min = din_data_ff[3*N-1:2*N];
  end
  else if (array[2]>= array[0] & array[0]>=array[1]) begin //2>0>1
    max = din_data_ff[N-1:0];
    med = din_data_ff[3*N-1:2*N];
    min = din_data_ff[2*N-1:N];
  end
  else if (array[2]>= array[1] & array[1]>=array[0]) begin //2>1>0
    max = din_data_ff[N-1:0];
    med = din_data_ff[2*N-1:N];
    min = din_data_ff[3*N-1:2*N];
  end
  else begin //debug
    max = 0;
    med = 0;
    min = 0;
  end
end

//reoder
always @(*) begin
  case (Order_ff)
    2'd0:begin
      P = array[0];
      S = array[1];
      D = array[2];
    end
    2'd1:begin
      P = max;
      S = med;
      D = min;
    end
    2'd2:begin
      P = min;
      S = max;
      D = med;
    end
    2'd3:begin
      P = med;
      S = min;
      D = max;
    end 
    default:begin
      P = 0;
      S = 0;
      D = 0;
    end 
  endcase
end

//look up table
always @(*) begin
  case (Mode_ff)
    8'h00:
      result = 0;
    8'h11:
      result = ~(D|S); 
    8'h33:
      result = ~S; 
    8'h44:
      result = S&~D; 
    8'h55:
      result = ~D; 
    8'h5A:
      result = D^P; 
    8'h66:
      result = D^S; 
    8'h88:
      result = D&S;
    8'hBB:
      result = D|~S;  
    8'hC0:
      result = P&S; 
    8'hCC:
      result = S; 
    8'hEE:
      result = D|S; 
    8'hF0:
      result = P; 
    8'hFB:
      result = D|P|~S; 
    8'hFF:
      result = ~(1'b0<<(N-1)); 
    default:
      result = 0;
  endcase
end

///********** Squencial **********///
//input FF
  always @(posedge clk) begin
      din_valid_ff <= din_valid;
      din_data_ff <= din_data;
      Order_ff <= Order;
      Mode_ff <= Mode;
  end
//output FF
  always @(posedge clk) begin
      dout_valid_reg <= dout_valid_ff;
      dout_data_reg <= dout_data_ff;
  end
endmodule