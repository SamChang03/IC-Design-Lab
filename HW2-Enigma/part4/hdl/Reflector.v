module Reflector (data_in, data_out);

input [6-1:0] data_in;

output [6-1:0]  data_out;

assign data_out = 6'h3f - data_in;
	
endmodule