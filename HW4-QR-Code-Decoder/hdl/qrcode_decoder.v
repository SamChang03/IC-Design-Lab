//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2024 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module qrcode_decoder(
    input clk,
    input srst_n,             
    input start,                         
    input sram_rdata,       

    output [11:0] sram_raddr,
    output [5:0] loc_y,
    output [5:0] loc_x,
    output [7:0] decode_text,
    output valid,
    output finish         
);

wire mask_start,mask_done;
wire [2:0] mask_pattern;
wire [3:0] state;
wire [5:0] i,j,i_find_32,j_find_32;
wire [1:0] type;
wire [2:0] cnt_block;

reg srst_n_FF,start_FF,srst_n_FF2,start_FF2,sram_rdata_FF;

FSM FSM_u0
(
	//input
    .clk(clk),
	.srst_n(srst_n_FF),
	.start(start_FF),

    //input signal
    .find_done(find_done),
    .mask_done(mask_done),
    .output_FIFO(decode_text),
    .i_find_32(i_find_32),
    .j_find_32(j_find_32),
    .type(type),
    .checking(checking),
    .loc_y(loc_y),
	.loc_x(loc_x),
    .no_QRcode(no_QRcode),

    //output signal
    .state(state),
    .find_start(find_start),
    .mask_start(mask_start),
    .codeword_start(codeword_start),
    .cnt_block(cnt_block),
    .i(i),
    .j(j),
    .is_rank_b(is_rank_b),
    

    //output
    .sram_raddr(sram_raddr),
	.valid(valid),
	.finish(finish)
);

find_qrcode find_qrcode_u0
(
    .clk(clk),
    .srst_n(srst_n_FF),             
    .find_start(find_start),                         
    .find_index(sram_rdata),
    .cnt_block(cnt_block),
    .i(i),
    .j(j),
    .is_rank_b(is_rank_b),       

    .type(type),
    .i_find_32(i_find_32),
    .j_find_32(j_find_32),
    .loc_y(loc_y),
    .loc_x(loc_x), 
    .find_done(find_done),
    .checking(checking),
    .no_QRcode(no_QRcode)        
);

de_mask de_mask_u0
(
    .clk(clk),
    .srst_n(srst_n_FF),             
    .mask_start(mask_start),                         
    .mask_index(sram_rdata),   

    .mask_pattern(mask_pattern),
    .mask_done(mask_done)         
);

decode decode_u0(
    .clk(clk),
    .srst_n(srst_n_FF),             
    .data_in(sram_rdata),
    .mask_pattern(mask_pattern),                         
    .codeword_start(codeword_start),
    .i(i),
    .j(j),
    .loc_y(loc_y),
    .loc_x(loc_x),
    .type(type),       

    .codeword(codeword)        
);

FIFO output_FIFO_uo(
    .clk(clk),
    .state(state),
    .data_in(codeword),
    .data_out(decode_text)
);

always @(posedge clk) begin
    start_FF <= start;
    srst_n_FF <= srst_n;
    start_FF2 <= start_FF;
    srst_n_FF2 <= srst_n_FF;  
    sram_rdata_FF <= sram_rdata;
end

endmodule