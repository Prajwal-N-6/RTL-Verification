module adder(input [31:0] a,b,
			 output [31:0]y);

	   assign y = a+b;

endmodule
module aludec(input logic Opb5,
			  input logic [2:0] funct3,
			  input logic funct7b5,
			  input logic [1:0] ALUOp,
			  output logic [2:0] ALUControl);

			  logic RtypeSub;

			  assign RtypeSub = funct7b5 & Opb5;


			  always_comb

			  case(ALUOp)
			  			2'b00: ALUControl = 3'b000;
			  			2'b01: ALUControl = 3'b001;

						default: case(funct3)
											3'b00	: 	if(RtypeSub)
																ALUControl = 3'b001;
												   		else 
												   				ALUControl = 3'b000;
											
											3'b010	: 	ALUControl = 3'b101;
											3'b110	: 	ALUControl = 3'b011;
											3'b111	: 	ALUControl = 3'b010;
											default :   ALUControl = 3'bX;
								 
								 endcase
			  endcase

endmodule
module alu(
    input logic [31:0] SrcA,           
    input logic [31:0] SrcB,           
    input logic [2:0] ALUControl,      
    output logic [31:0] ALUResult,     
    output logic Zero);

	
    always_comb begin
        case(ALUControl)
            3'b000: ALUResult = SrcA + SrcB;       
            3'b001: ALUResult = SrcA - SrcB;       
            3'b010: ALUResult = SrcA & SrcB;
			3'b011: ALUResult = SrcA | SrcB;
            3'b101: ALUResult = SrcA < SrcB; 
            default: ALUResult = 32'b0;            
        endcase
        
        Zero = (ALUResult == 32'b0);  
    end
endmodule
module dmem(input logic clk,we,
			input logic [31:0] a,wd,
			output logic [31:0]rd);

			logic [31:0] RAM [63:0];
			assign rd = RAM[a[31:2]];

			always_ff@(posedge clk)
									if(we) RAM[a[31:2]] <= wd;
endmodule
module datapath(input logic clk,rst,PCSrc,ALUSrc,RegWrite,
				input logic [1:0] ResultSrc,ImmSrc,
				input logic [2:0] ALUControl,
				output logic Zero,
				output logic [31:0] PC,ALUResult,WriteData,
				input logic [31:0] Instr,
				input logic [31:0] ReadData);


				logic [31:0] PCNext,PCPlus4,PCTarget,ImmExt,SrcA,SrcB;
				logic [31:0] Result; //='b0;
				
				flopr #(32) pcreg(clk,rst,PCNext,PC);

				adder pcadd4(PC,32'd4,PCPlus4);
				
				adder pcaddbranch (PC,ImmExt,PCTarget);
				
				mux2 #(32) pcmux(PCPlus4,PCTarget,PCSrc,PCNext);
				
				regfile rf(clk,rst,RegWrite,Instr[19:15],Instr[24:20],Instr[11:7],Result,SrcA,WriteData);
				
				extend ext(Instr[31:7],ImmSrc,ImmExt);
				
				mux2 #(32) srcbmux(WriteData,ImmExt,ALUSrc,SrcB);
				
				alu alu1(SrcA,SrcB,ALUControl,ALUResult,Zero);
				
				mux3 #(32) resultmux(ALUResult,ReadData,PCPlus4,ResultSrc,Result);

	
endmodule
module maindec(input logic[6:0] Op,
			   output logic [1:0] ResultSrc,
			   output logic MemWrite,
			   output logic Branch,ALUSrc,ReqWrite,Jump,
			   output logic [1:0] ImmSrc,ALUOp);

			   logic [10:0] control;


			   assign {RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp,Jump} = control;


			   always_comb
			   case(Op)
			   			7'b0000011: control = 11'b10010010000;
			   			7'b0100011: control = 11'b00111000000;
			   			7'b0110011: control = 11'b1xx00000100;
			   			7'b1100011: control = 11'b01000001010;
			   			7'b0010011: control = 11'b10010000100;
			   			7'b1101111: control = 11'b11100100001;
						default   : control = 11'bX;
			  endcase

endmodule
module extend(input logic [31:7] instr,
			  input logic [1:0] immsrc,
			  output logic [31:0] immext);


			  always_comb
			  			case(immsrc)
									2'b00: immext = {{20{instr[31]}},instr[31:20]};
									2'b01: immext = {{20{instr[31]}},instr[31:25],instr[11:7]};
									2'b10: immext = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
									2'b11: immext = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};
									default: immext = 32'bX;
						endcase

endmodule
module flopnr #(parameter width = 32)
			  (input logic clk,rst,en,
			   input logic [width-1:0]d,
			   output logic [width-1:0]q);

			  
	  always_ff@(posedge clk,posedge rst)
	  
	  	if(rst) q<= 'b0;
		else if(en) q <= d;

endmodule
module flopr #(parameter width = 32)
			  (input logic clk,rst,
			   input logic [width-1:0] d,
			   output logic [width-1:0] q);

		always_ff@(posedge clk or posedge rst)
		
		if(rst) q <= 'b0;
		else q <= d;

endmodule

module imem(input logic [31:0]a,
			output logic [31:0] rd);

			logic [31:0] RAM [63:0];

			initial 
			$readmemh("riscvtest.txt",RAM);

			assign rd = RAM[a[31:2]];

endmodule
module mux2 #(parameter width = 32)
			 (input logic [width-1:0] d0,d1,
			  input logic s,
			  output logic [width-1:0]y);

			  assign y = s ? d1:d0;

endmodule
module mux3 #(parameter width = 32)
			 (input logic [width-1:0] d0,d1,d2,
			 input logic [1:0] s,
			 output logic [width-1:0] y);

			 assign y = s[1] ? d2: (s[0] ? d1:d0);
	
endmodule
module controller (input logic [6:0] Op,
				   input logic [2:0] funct3,
				   input logic funct7b5,
				   input logic Zero,
				   output logic [1:0] ResultSrc,
				   output logic MemWrite,PCSrc,ALUSrc, RegWrite,Jump,
				   output logic [1:0] ImmSrc,
				   output logic [2:0] ALUControl);

	   logic [1:0] ALUOp;
	   logic Branch;


	   maindec md(Op,ResultSrc,MemWrite,Branch,ALUSrc,RegWrite,Jump,ImmSrc,ALUOp);

	   aludec ad(Op[5],funct3,funct7b5,ALUOp,ALUControl);


	   assign PCSrc = Branch & Zero | Jump;

endmodule

module regfile(
    input logic clk,rst,             
    input logic RegWrite,            
    input logic [4:0] rs1,         
    input logic [4:0] rs2,           
    input logic [4:0] rd,            
    input logic [31:0] write_data,   
    output logic [31:0] read_data1,  
    output logic [31:0] read_data2);
	
    logic [31:0] registers [31:0];
    reg count = 1'b0;

    assign read_data1 = registers[rs1];
    assign read_data2 = registers[rs2];
    
    always_ff @(posedge clk or posedge rst) begin
		if(rst) 
		begin
			for(int i = 0; i <= 32; i++) 
			begin
				registers[i] = $random;
			end
		end
		//register config for BEQ Operation only
		//registers[5] = 'hAA;
		//registers[7] = 'hAA;
        if (RegWrite) begin
            registers[rd] <= write_data;
        end
    end
endmodule
module riscvsingle (input logic clk,rst,
					output logic [31:0] PC,
					input logic [31:0] Instr,
					output logic MemWrite,
					output logic [31:0] ALUResult,WriteData,
					input logic [31:0] ReadData);

		logic ALUSrc,RegWrite,Jump,Zero;
		logic [1:0] ResultSrc,ImmSrc;
		logic [2:0] ALUControl;

		controller c(Instr[6:0],Instr[14:12],Instr[30],Zero,ResultSrc,MemWrite,PCSrc,ALUSrc,RegWrite,Jump,ImmSrc,ALUControl);

		datapath dp(clk,rst,PCSrc,ALUSrc,RegWrite,ResultSrc,ImmSrc,ALUControl,Zero,PC,ALUResult,WriteData,Instr,ReadData);


endmodule
module tb();
	   logic clk,rst,MemWrite;
	   logic [31:0] WriteData; // = 'b0;
	   logic [31:0] DataAdr;

	   top dut(clk,rst,WriteData,DataAdr,MemWrite);

	   initial 
	   begin
	   		clk = 0;
	   		rst = 1; #5; rst = 0;
			#1000000; $finish;
	   end
	
	   always 
	   begin
	   		#15; clk = ~clk;
	   end

	  /* always@(negedge clk)
	   begin
	   		if(MemWrite)
			begin
				 if(DataAdr === 100 & WriteData === 25)
				 begin
				 		$display("PASS\n");
						$stop;
				end

				else if(DataAdr !== 96)
				begin
						$display("FAIL\n");
						$stop;
				end
			end
	  end*/

endmodule
module top(input logic clk,rst,
		   output logic [31:0] WriteData,DataAdr,
		   output logic MemWrite );

		   logic [31:0] PC,Instr,ReadData;

		   riscvsingle  rvsingle (.clk(clk),.rst(rst),.PC(PC),.Instr(Instr),.MemWrite(MemWrite),.WriteData(WriteData),.ReadData(ReadData),.ALUResult(DataAdr));
		   imem imemm(PC,Instr);
		   dmem dmemm(clk,MemWrite,DataAdr,WriteData,ReadData);

endmodule
