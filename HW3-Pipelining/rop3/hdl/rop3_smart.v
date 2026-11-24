/*
* Module      : rop3_smart
* Description : Implement this module using the bit-hack technique mentioned in the assignment handout.
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_smart
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

rop3_smart_pipeline #(.N(N)) ROP3_smart_pipeline
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