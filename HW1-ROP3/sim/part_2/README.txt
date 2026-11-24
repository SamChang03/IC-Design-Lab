1. There are 3 parts in my testbench including IO indenfication & connection, input feeding and output comparision

2. In the IO indenfication & connection, it just a simple stage to type IO of the module and  generate clock signal . However, since there are only 15 Modes we can use in part2,
I generate a Mode array to let the value of the Mode can be feeded in the module in some order way.
(Mode_array[14:0] = {8'h00,8'h11,8'h33,8'h44,8'h55,8'h5A,8'h66,8'h88,8'hBB,8'hC0,8'hCC,8'hEE,8'hF0,8'hFB,8'hFF})

3. In the input feeding stage, I set the inital value first. Until the first negative clock edge, we start feeding test pattern into the engine(input valid =1).
The test pattern includes 5 for loop (for 3 partisions of din_data, order, Mode_array), which can generate all the posible conbination of the input data.

4. In the output comparision stage, since there are 2 stage pipelines in this system, I stall two cycle to synchornize the data from test pattern and feeder.
Then, we still need to wait dout_valid_lut & dout_valid_smart go to 1 to ensure the output data is valid.
Then, there is a simple comparision to check the results from lut16 are the same as that from smart formula.
Besides, print some information to check the all result is OK and for debug.