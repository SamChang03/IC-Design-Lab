/*
* Module      : roP3_lut256
* DescriPtion : ImPlement this module using the look-uP table (LUT) 
*               This module should suPPort all the possible modes of ROP3.
* Notes       : Please remember to
*               (1) make the bit-length of {P, S, D, Result} parameterizable
*               (2) make the input/output to be a register
*/

module rop3_lut256
#(
  parameter N = 4
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

//look uP table
always @(*) begin
  result = 8'hzz;
  case (Mode_ff)
    //symmetric basis 8'h00 result = 0
    //symmetric basis 8'h11 result = ~(D|S)
    //symmetric basis 8'h22 result = ~S&D
    //symmetric basis 8'h33 result = ~S
    //symmetric basis 8'h44 result = S&(~D)
    //symmetric basis 8'h55 result = ~D
    //symmetric basis 8'h66 result = D^S
    //symmetric basis 8'h77 result = ~(S&D)
    //symmetric half
    //symmetric basis 8'h88 result = (S&D)
    //symmetric basis 8'h99 result = ~(D^S)
    //symmetric basis 8'haa result = D
    //symmetric basis 8'hbb result = (~S|D)
    //symmetric basis 8'hcc result = S
    //symmetric basis 8'hdd result = (S|~D)
    //symmetric basis 8'hee result = (S|D)
    //symmetric basis 8'hff result = 1

    //8'h0X:
    8'h00:
      result = 0;
    8'h01:
      result = ~(P|S|D);
    8'h02:
      result = ~P&~S&D;
    8'h03:
      result = ~(P|S);
    8'h04:
      result = ~P&S&(~D);
    8'h05:
      result = ~(P|D);
    8'h06:
      result = ~P&(D^S);
    8'h07:
      result = ~(P|(S&D));
    8'h08:
      result = ~P&(S&D);
    8'h09:
      result = ~(P|(D^S));
    8'h0a:
      result = ~P&D;
    8'h0b:
      result = ~P&(~S|D);
    8'h0c:
      result = (~P&S);
    8'h0d:
      result = ~P&(S|~D);
    8'h0e:
      result = ~P&(S|D);
    8'h0f:
      result = ~P;
    
    //8'h1X: P&~(S|D)
    8'h10:
      result = (P&~(S|D));
    8'h11:
      result = (P&~(S|D)) | ~(P|S|D);
    8'h12:
      result = (P&~(S|D)) | ~P&~S&D;
    8'h13:
      result = (P&~(S|D)) | ~(P|S);
    8'h14:
      result = (P&~(S|D)) | ~P&S&(~D);
    8'h15:
      result = (P&~(S|D)) | ~(P|D);
    8'h16:
      result = (P&~(S|D)) | ~P&(D^S);
    8'h17:
      result = (P&~(S|D)) | ~(P|(S&D));
    8'h18:
      result = (P&~(S|D)) | ~P&(S&D);
    8'h19:
      result = (P&~(S|D)) | ~(P|(D^S));
    8'h1a:
      result = (P&~(S|D)) | ~P&D;
    8'h1b:
      result = (P&~(S|D)) | ~P&(~S|D);
    8'h1c:
      result = (P&~(S|D)) | (~P&S);
    8'h1d:
      result = (P&~(S|D)) | ~P&(S|~D);
    8'h1e:
      result = (P&~(S|D)) | ~P&(S|D);
    8'h1f:
      result = (P&~(S|D)) | ~P;
    
    //8'h2X: P&~S&D
    8'h20:
      result = (P&~S&D);
    8'h21:
      result = (P&~S&D) | ~(P|S|D);
    8'h22:
      result = (P&~S&D) | ~P&~S&D;
    8'h23:
      result = (P&~S&D) | ~(P|S);
    8'h24:
      result = (P&~S&D) | ~P&S&(~D);
    8'h25:
      result = (P&~S&D) | ~(P|D);
    8'h26:
      result = (P&~S&D) | ~P&(D^S);
    8'h27:
      result = (P&~S&D) | ~(P|(S&D));
    8'h28:
      result = (P&~S&D) | ~P&(S&D);
    8'h29:
      result = (P&~S&D) | ~(P|(D^S));
    8'h2a:
      result = (P&~S&D) | ~P&D;
    8'h2b:
      result = (P&~S&D) | ~P&(~S|D);
    8'h2c:
      result = (P&~S&D) | (~P&S);
    8'h2d:
      result = (P&~S&D) | ~P&(S|~D);
    8'h2e:
      result = (P&~S&D) | ~P&(S|D);
    8'h2f:
      result = (P&~S&D) | ~P;
    
    //8'h3X: P&~S
    8'h30:
      result = (P&~S);
    8'h31:
      result = (P&~S) | ~(P|S|D);
    8'h32:
      result = (P&~S) | ~P&~S&D;
    8'h33:
      result = (P&~S) | ~(P|S);
    8'h34:
      result = (P&~S) | ~P&S&(~D);
    8'h35:
      result = (P&~S) | ~(P|D);
    8'h36:
      result = (P&~S) | ~P&(D^S);
    8'h37:
      result = (P&~S) | ~(P|(S&D));
    8'h38:
      result = (P&~S) | ~P&(S&D);
    8'h39:
      result = (P&~S) | ~(P|(D^S));
    8'h3a:
      result = (P&~S) | ~P&D;
    8'h3b:
      result = (P&~S) | ~P&(~S|D);
    8'h3c:
      result = (P&~S) | (~P&S);
    8'h3d:
      result = (P&~S) | ~P&(S|~D);
    8'h3e:
      result = (P&~S) | ~P&(S|D);
    8'h3f:
      result = (P&~S) | ~P;
    
    //8'h4X: P&S&~D
    8'h40:
      result = (P&S&~D);
    8'h41:
      result = (P&S&~D) | ~(P|S|D);
    8'h42:
      result = (P&S&~D) | ~P&~S&D;
    8'h43:
      result = (P&S&~D) | ~(P|S);
    8'h44:
      result = (P&S&~D) | ~P&S&(~D);
    8'h45:
      result = (P&S&~D) | ~(P|D);
    8'h46:
      result = (P&S&~D) | ~P&(D^S);
    8'h47:
      result = (P&S&~D) | ~(P|(S&D));
    8'h48:
      result = (P&S&~D) | ~P&(S&D);
    8'h49:
      result = (P&S&~D) | ~(P|(D^S));
    8'h4a:
      result = (P&S&~D) | ~P&D;
    8'h4b:
      result = (P&S&~D) | ~P&(~S|D);
    8'h4c:
      result = (P&S&~D) | (~P&S);
    8'h4d:
      result = (P&S&~D) | ~P&(S|~D);
    8'h4e:
      result = (P&S&~D) | ~P&(S|D);
    8'h4f:
      result = (P&S&~D) | ~P;
    
    //8'h5X: P&~D
    8'h50:
      result = (P&~D);
    8'h51:
      result = (P&~D) | ~(P|S|D);
    8'h52:
      result = (P&~D) | ~P&~S&D;
    8'h53:
      result = (P&~D) | ~(P|S);
    8'h54:
      result = (P&~D) | ~P&S&(~D);
    8'h55:
      result = (P&~D) | ~(P|D);
    8'h56:
      result = (P&~D) | ~P&(D^S);
    8'h57:
      result = (P&~D) | ~(P|(S&D));
    8'h58:
      result = (P&~D) | ~P&(S&D);
    8'h59:
      result = (P&~D) | ~(P|(D^S));
    8'h5a:
      result = (P&~D) | ~P&D;
    8'h5b:
      result = (P&~D) | ~P&(~S|D);
    8'h5c:
      result = (P&~D) | (~P&S);
    8'h5d:
      result = (P&~D) | ~P&(S|~D);
    8'h5e:
      result = (P&~D) | ~P&(S|D);
    8'h5f:
      result = (P&~D) | ~P;
    
    //8'h6X: P&(D^S)
    8'h60:
      result = (P&(D^S));
    8'h61:
      result = (P&(D^S)) | ~(P|S|D);
    8'h62:
      result = (P&(D^S)) | ~P&~S&D;
    8'h63:
      result = (P&(D^S)) | ~(P|S);
    8'h64:
      result = (P&(D^S)) | ~P&S&(~D);
    8'h65:
      result = (P&(D^S)) | ~(P|D);
    8'h66:
      result = (P&(D^S)) | ~P&(D^S);
    8'h67:
      result = (P&(D^S)) | ~(P|(S&D));
    8'h68:
      result = (P&(D^S)) | ~P&(S&D);
    8'h69:
      result = (P&(D^S)) | ~(P|(D^S));
    8'h6a:
      result = (P&(D^S)) | ~P&D;
    8'h6b:
      result = (P&(D^S)) | ~P&(~S|D);
    8'h6c:
      result = (P&(D^S)) | (~P&S);
    8'h6d:
      result = (P&(D^S)) | ~P&(S|~D);
    8'h6e:
      result = (P&(D^S)) | ~P&(S|D);
    8'h6f:
      result = (P&(D^S)) | ~P;
    
    //8'h7X: P& ~(S&D)
    8'h70:
      result = (P& ~(S&D));
    8'h71:
      result = (P& ~(S&D)) | ~(P|S|D);
    8'h72:
      result = (P& ~(S&D)) | ~P&~S&D;
    8'h73:
      result = (P& ~(S&D)) | ~(P|S);
    8'h74:
      result = (P& ~(S&D)) | ~P&S&(~D);
    8'h75:
      result = (P& ~(S&D)) | ~(P|D);
    8'h76:
      result = (P& ~(S&D)) | ~P&(D^S);
    8'h77:
      result = (P& ~(S&D)) | ~(P|(S&D));
    8'h78:
      result = (P& ~(S&D)) | ~P&(S&D);
    8'h79:
      result = (P& ~(S&D)) | ~(P|(D^S));
    8'h7a:
      result = (P& ~(S&D)) | ~P&D;
    8'h7b:
      result = (P& ~(S&D)) | ~P&(~S|D);
    8'h7c:
      result = (P& ~(S&D)) | (~P&S);
    8'h7d:
      result = (P& ~(S&D)) | ~P&(S|~D);
    8'h7e:
      result = (P& ~(S&D)) | ~P&(S|D);
    8'h7f:
      result = (P& ~(S&D)) | ~P;
    
    //8'h8X: P&(S&D)
    8'h80:
      result = (P&(S&D));
    8'h81:
      result = (P&(S&D)) | ~(P|S|D);
    8'h82:
      result = (P&(S&D)) | ~P&~S&D;
    8'h83:
      result = (P&(S&D)) | ~(P|S);
    8'h84:
      result = (P&(S&D)) | ~P&S&(~D);
    8'h85:
      result = (P&(S&D)) | ~(P|D);
    8'h86:
      result = (P&(S&D)) | ~P&(D^S);
    8'h87:
      result = (P&(S&D)) | ~(P|(S&D));
    8'h88:
      result = (P&(S&D)) | ~P&(S&D);
    8'h89:
      result = (P&(S&D)) | ~(P|(D^S));
    8'h8a:
      result = (P&(S&D)) | ~P&D;
    8'h8b:
      result = (P&(S&D)) | ~P&(~S|D);
    8'h8c:
      result = (P&(S&D)) | (~P&S);
    8'h8d:
      result = (P&(S&D)) | ~P&(S|~D);
    8'h8e:
      result = (P&(S&D)) | ~P&(S|D);
    8'h8f:
      result = (P&(S&D)) | ~P;
    
    //8'h9X: P&~(D^S)
    8'h90:
      result = (P&~(D^S));
    8'h91:
      result = (P&~(D^S)) | ~(P|S|D);
    8'h92:
      result = (P&~(D^S)) | ~P&~S&D;
    8'h93:
      result = (P&~(D^S)) | ~(P|S);
    8'h94:
      result = (P&~(D^S)) | ~P&S&(~D);
    8'h95:
      result = (P&~(D^S)) | ~(P|D);
    8'h96:
      result = (P&~(D^S)) | ~P&(D^S);
    8'h97:
      result = (P&~(D^S)) | ~(P|(S&D));
    8'h98:
      result = (P&~(D^S)) | ~P&(S&D);
    8'h99:
      result = (P&~(D^S)) | ~(P|(D^S));
    8'h9a:
      result = (P&~(D^S)) | ~P&D;
    8'h9b:
      result = (P&~(D^S)) | ~P&(~S|D);
    8'h9c:
      result = (P&~(D^S)) | (~P&S);
    8'h9d:
      result = (P&~(D^S)) | ~P&(S|~D);
    8'h9e:
      result = (P&~(D^S)) | ~P&(S|D);
    8'h9f:
      result = (P&~(D^S)) | ~P;
    
    //8'haX: P&D
    8'ha0:
      result = (P&D);
    8'ha1:
      result = (P&D) | ~(P|S|D);
    8'ha2:
      result = (P&D) | ~P&~S&D;
    8'ha3:
      result = (P&D) | ~(P|S);
    8'ha4:
      result = (P&D) | ~P&S&(~D);
    8'ha5:
      result = (P&D) | ~(P|D);
    8'ha6:
      result = (P&D) | ~P&(D^S);
    8'ha7:
      result = (P&D) | ~(P|(S&D));
    8'ha8:
      result = (P&D) | ~P&(S&D);
    8'ha9:
      result = (P&D) | ~(P|(D^S));
    8'haa:
      result = (P&D) | ~P&D;
    8'hab:
      result = (P&D) | ~P&(~S|D);
    8'hac:
      result = (P&D) | (~P&S);
    8'had:
      result = (P&D) | ~P&(S|~D);
    8'hae:
      result = (P&D) | ~P&(S|D);
    8'haf:
      result = (P&D) | ~P;
    
    //8'hbX: P&~(S&(~D))
    8'hb0:
      result = (P&~(S&(~D)));
    8'hb1:
      result = (P&~(S&(~D))) | ~(P|S|D);
    8'hb2:
      result = (P&~(S&(~D))) | ~P&~S&D;
    8'hb3:
      result = (P&~(S&(~D))) | ~(P|S);
    8'hb4:
      result = (P&~(S&(~D))) | ~P&S&(~D);
    8'hb5:
      result = (P&~(S&(~D))) | ~(P|D);
    8'hb6:
      result = (P&~(S&(~D))) | ~P&(D^S);
    8'hb7:
      result = (P&~(S&(~D))) | ~(P|(S&D));
    8'hb8:
      result = (P&~(S&(~D))) | ~P&(S&D);
    8'hb9:
      result = (P&~(S&(~D))) | ~(P|(D^S));
    8'hba:
      result = (P&~(S&(~D))) | ~P&D;
    8'hbb:
      result = (P&~(S&(~D))) | ~P&(~S|D);
    8'hbc:
      result = (P&~(S&(~D))) | (~P&S);
    8'hbd:
      result = (P&~(S&(~D))) | ~P&(S|~D);
    8'hbe:
      result = (P&~(S&(~D))) | ~P&(S|D);
    8'hbf:
      result = (P&~(S&(~D))) | ~P;
    
    //8'hcX: P&S
    8'hc0:
      result = (P&S);
    8'hc1:
      result = (P&S) | ~(P|S|D);
    8'hc2:
      result = (P&S) | ~P&~S&D;
    8'hc3:
      result = (P&S) | ~(P|S);
    8'hc4:
      result = (P&S) | ~P&S&(~D);
    8'hc5:
      result = (P&S) | ~(P|D);
    8'hc6:
      result = (P&S) | ~P&(D^S);
    8'hc7:
      result = (P&S) | ~(P|(S&D));
    8'hc8:
      result = (P&S) | ~P&(S&D);
    8'hc9:
      result = (P&S) | ~(P|(D^S));
    8'hca:
      result = (P&S) | ~P&D;
    8'hcb:
      result = (P&S) | ~P&(~S|D);
    8'hcc:
      result = (P&S) | (~P&S);
    8'hcd:
      result = (P&S) | ~P&(S|~D);
    8'hce:
      result = (P&S) | ~P&(S|D);
    8'hcf:
      result = (P&S) | ~P;
    
    //8'hdX: P&(S|~D)
    8'hd0:
      result = (P&(S|~D));
    8'hd1:
      result = (P&(S|~D)) | ~(P|S|D);
    8'hd2:
      result = (P&(S|~D)) | ~P&~S&D;
    8'hd3:
      result = (P&(S|~D)) | ~(P|S);
    8'hd4:
      result = (P&(S|~D)) | ~P&S&(~D);
    8'hd5:
      result = (P&(S|~D)) | ~(P|D);
    8'hd6:
      result = (P&(S|~D)) | ~P&(D^S);
    8'hd7:
      result = (P&(S|~D)) | ~(P|(S&D));
    8'hd8:
      result = (P&(S|~D)) | ~P&(S&D);
    8'hd9:
      result = (P&(S|~D)) | ~(P|(D^S));
    8'hda:
      result = (P&(S|~D)) | ~P&D;
    8'hdb:
      result = (P&(S|~D)) | ~P&(~S|D);
    8'hdc:
      result = (P&(S|~D)) | (~P&S);
    8'hdd:
      result = (P&(S|~D)) | ~P&(S|~D);
    8'hde:
      result = (P&(S|~D)) | ~P&(S|D);
    8'hdf:
      result = (P&(S|~D)) | ~P;
    
    //8'heX: P&(S|D)
    8'he0:
      result = (P&(S|D));
    8'he1:
      result = (P&(S|D)) | ~(P|S|D);
    8'he2:
      result = (P&(S|D)) | ~P&~S&D;
    8'he3:
      result = (P&(S|D)) | ~(P|S);
    8'he4:
      result = (P&(S|D)) | ~P&S&(~D);
    8'he5:
      result = (P&(S|D)) | ~(P|D);
    8'he6:
      result = (P&(S|D)) | ~P&(D^S);
    8'he7:
      result = (P&(S|D)) | ~(P|(S&D));
    8'he8:
      result = (P&(S|D)) | ~P&(S&D);
    8'he9:
      result = (P&(S|D)) | ~(P|(D^S));
    8'hea:
      result = (P&(S|D)) | ~P&D;
    8'heb:
      result = (P&(S|D)) | ~P&(~S|D);
    8'hec:
      result = (P&(S|D)) | (~P&S);
    8'hed:
      result = (P&(S|D)) | ~P&(S|~D);
    8'hee:
      result = (P&(S|D)) | ~P&(S|D);
    8'hef:
      result = (P&(S|D)) | ~P;
    
    //8'hfX: P
    8'hf0:
      result = P;
    8'hf1:
      result = P | ~(P|S|D);
    8'hf2:
      result = P | ~P&~S&D;
    8'hf3:
      result = P | ~(P|S);
    8'hf4:
      result = P | ~P&S&(~D);
    8'hf5:
      result = P | ~(P|D);
    8'hf6:
      result = P | ~P&(D^S);
    8'hf7:
      result = P | ~(P|(S&D));
    8'hf8:
      result = P | ~P&(S&D);
    8'hf9:
      result = P | ~(P|(D^S));
    8'hfa:
      result = P | ~P&D;
    8'hfb:
      result = P | ~P&(~S|D);
    8'hfc:
      result = P | (~P&S);
    8'hfd:
      result = P | ~P&(S|~D);
    8'hfe:
      result = P | ~P&(S|D);
    8'hFF:
      result = ~(1'b0<<(N-1)); 
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