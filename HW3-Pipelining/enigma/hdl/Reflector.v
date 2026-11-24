module Reflector (data_in, data_out);

//input clk;
input [6-1:0] data_in;

output [6-1:0]  data_out;

assign data_out = ~data_in;	
endmodule