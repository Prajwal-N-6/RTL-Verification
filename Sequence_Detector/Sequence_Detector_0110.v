// Sequence Detector_0110_Moore_Overlapping //
module seq(clk,rst,sin,out);
  input clk,rst,sin;
  output reg out = 1'b0;
  parameter s0 = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4;
  reg [2:0] cs,ns;
  
  always @(posedge clk or posedge rst)
    begin
      if(rst)
        cs <= s0;
      else
        cs <= ns;
    end
  
  always @(cs,sin)
    begin
      case(cs)
        s0 : begin if(sin == 0) ns =s1; else ns = s0; end
        s1 : begin if(sin == 1) begin ns =s2; end else ns = s1; end
        s2 : begin if(sin == 1) ns =s3; else ns = s1; end
        s3 : begin if(sin == 0) ns =s4; else ns = s0; end
        s4 : begin if(sin == 0) ns =s1; else ns = s2; end
        default : ns = s0;
      endcase
      if(cs == s4)
        out = 1'b1;
      else 
        out = 1'b0;
    end
endmodule 
