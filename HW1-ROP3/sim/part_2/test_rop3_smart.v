
`define CYCLE 10
`define END_CYCLE 6100000
`define TEST_DATA_NUM 6000
`define TEST_RESULT_NUM 1024
`define N 3
module test_rop3_smart;

integer i,j,k,l,m;
integer a,b,c,d,e;
parameter N= `N;

reg [7:0]Mode_array[0:14];

//tast array
initial begin

    //Mode_array[14:0] = {8'h00,8'h11,8'h33,8'h44,8'h55,8'h5A,8'h66,8'h88,
    //                    8'hBB,8'hC0,8'hCC,8'hEE,8'hF0,8'hFB,8'hFF}
     Mode_array[0]   = 8'h00;
     Mode_array[1]   = 8'h11;
     Mode_array[2]   = 8'h33;
     Mode_array[3]   = 8'h44;
     Mode_array[4]   = 8'h55;
     Mode_array[5]   = 8'h5A;
     Mode_array[6]   = 8'h66;
     Mode_array[7]   = 8'h88;
     Mode_array[8]   = 8'hBB;
     Mode_array[9]   = 8'hC0;
     Mode_array[10]   = 8'hCC;
     Mode_array[11]   = 8'hEE;
     Mode_array[12]   = 8'hF0;
     Mode_array[13]   = 8'hFB;
     Mode_array[14]   = 8'hFF;

end

// create clk
reg clk;
initial begin
    clk = 0;
    while(1) #(`CYCLE/2) clk = ~clk;
end

//*** RTL input instantiation***//
reg din_valid;
reg  [3*`N-1:0] din_data;
reg  [1:0]   Order;
reg  [7:0]   Mode;

//*** RTL output instantiation***//
//lut16
wire dout_valid_lut;
wire [`N-1:0] dout_data_lut;
//smart
wire dout_valid_smart;
wire [`N-1:0] dout_data_smart;


rop3_smart #(.N(`N)) ROP3_smart
(
  .clk(clk),
  .din_valid(din_valid),
  .din_data(din_data),
  .Order(Order),
  .Mode(Mode),
  .dout_valid(dout_valid_smart),
  .dout_data(dout_data_smart)
);

rop3_lut16 #(.N(`N)) ROP3_lut16U
(
  .clk(clk),
  .din_valid(din_valid),
  .din_data(din_data),
  .Order(Order),
  .Mode(Mode),
  .dout_valid(dout_valid_lut),
  .dout_data(dout_data_lut)
);

/*initial begin
    $fsdbDumpfile("test_rop3_smart.fsdb");
    $fsdbDumpMDA();
    $fsdbDumpvars; 
end*/

// input feeding
initial begin

din_valid = 1'hz;
din_data  = {3*`N{1'bz}};
Mode      = 8'hzz;
Order     = 2'hz;

 for(i=0;i<N*N;i=i+1)begin
 din_valid = 1'h1;
    for(j=0;j<N*N;j=j+1)begin
        for(k=0;k<N*N;k=k+1)begin
            for(l=0;l<4;l=l+1)begin
                for(m=0;m<15;m=m+1)begin
                       @(negedge clk ) din_data[3*N-1:2*N]=i[N-1:0]; din_data[2*N-1:N]=j[N-1:0]; din_data[N-1:0]=k[N-1:0]; Order=l[N-1:0]; Mode=Mode_array[m];
                end
            end
        end
    end
 end

#(`CYCLE*2);
@(negedge clk ) din_valid = 1'hz; din_data  = {3*`N{1'bz}}; Mode = 8'hzz; Order = 2'hz;
    
end

// output comparision
integer total_error = 0;
integer pattern_num = 0;
initial begin

    // output comparison start
    // two stage pipeline register delay
    #(`CYCLE*2);

    // output comparison init
 if(dout_valid_lut & dout_valid_smart)begin
    for(a=0;a<N*N;a=a+1)begin
    for(b=0;b<N*N;b=b+1)begin
        for(c=0;c<N*N;c=c+1)begin
            for(d=0;d<4;d=d+1)begin
                for(e=0;e<15;e=e+1)begin
                      @(posedge clk); #1;
                       if(dout_data_lut!== dout_data_smart) begin
                            $display("!!!!! Comparison Fail @ pattern %0d !!!!!", pattern_num);
                            $display("[pattern %0d]        Mode=%2h, Order=%1h, {din_data}={%2h,%2h,%2h}, LUT16=%2h, Smart=%2h",
                            pattern_num , Mode, Order, din_data[3*N-1:2*N], din_data[2*N-1:N], din_data[N-1:0], dout_data_lut, dout_data_smart);
                            total_error = total_error + 1;
                        end 
                        else begin
                            $display(">>>>> Comparison Pass @ pattern %0d <<<<<", pattern_num);
                            $display("[pattern %0d]        Mode=%2h, Order=%1h, {din_data}={%2h,%2h,%2h}, LUT16=%2h, Smart=%2h",
                                        pattern_num, Mode, Order, din_data[3*N-1:2*N], din_data[2*N-1:N], din_data[N-1:0], dout_data_lut, dout_data_smart);
                        end
                    pattern_num = pattern_num + 1;
                end
            end
        end
    end
 end
end
    if (total_error > 0) begin
        $display("\nxxxxxxxxxxx Comparison Fail xxxxxxxxxxx");
        $display("            Total %0d errors\n  Please check your error messages...", total_error);
        $display("xxxxxxxxxxx Comparison Fail xxxxxxxxxxx\n");

        if (total_error > `TEST_DATA_NUM*0.8) begin
            $display("! Hmm...There are so many errors, Did you make the output registered?\n");
        end
        
    end else begin
        $display("\n============= Congratulations =============");
        $display("    All Test Pattern Are The Same !   ");
        $display("============= Congratulations =============\n");
    end
    $finish;
end

// early termination of simulation 
initial begin
  #(`END_CYCLE*`CYCLE);
  $display("\n============= Error =============");
  $display(  "   Simulation takes too long...  ");
  $display("============= Error =============\n");
  $finish;

end

endmodule
