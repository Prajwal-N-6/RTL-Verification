// Testbench //
module test;
  
  reg clk,rst,sin;
  wire out;
  seq duv(clk,rst,sin,out);
  initial 
    begin 
      $dumpfile("dump.vcd"); 
      $dumpvars;
      clk = 0;
      rst = 1;
      #10
      rst  = 0;
    end
  
  always #5 clk = ~clk;
  
  initial 
    begin
      sin = 0; #10 sin = 0; #10 sin = 1; #10 sin = 1;
      #10
      sin = 0; #10 sin = 1; #10 sin = 1; #10 sin = 0;
      #10
      sin = 1; #10 sin = 1; #10 sin = 1; #10 sin = 0;
      #10;
      $finish;
    end
  
endmodule 
