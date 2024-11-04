module adder(input clk,reset,           
// Clock input 
// Reset input 
input [7:0] in1, // 8-bit input variable 
in2,             
// 8-bit input variable 
output reg [8:0] out); // 9-bit output variable 
// Sequential logic sensitive to positive edge of clock or reset 
always @(posedge clk or posedge reset) begin  
if(reset) 
out <= 0;    
else 
// Reset condition: set output to 0 
out <= in1 + in2; // Normal operation: add inputs in1 and in2 and 
assign to output out 
end 
endmodule
