module rop3_lut256
#(
  parameter N = 32
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

rop3_lut256_pipeline #(.N(N)) ROP3_lut256_pipeline
(
  .clk(clk),
  .din_valid(din_valid),
  .din_data(din_data),
  .Order(Order),
  .Mode(Mode),
  .dout_valid(dout_valid),
  .dout_data(dout_data)
);

endmodule