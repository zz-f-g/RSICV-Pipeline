`timescale 1ns / 1ps
`include "controller_code.vh"

module BranchController (
    input [3:0] isB,
    input BrEQ,
    input BrLT,
    input PCSel_In,
    output reg PCSel_Out,
    output reg Clear
);
  always @(*) begin
    if (isB[3] == 1'b0) begin
      PCSel_Out = `PCSel_4;
      Clear = 1'b1;
    end else begin
      case (isB[2:0])
        `funct3_J: begin
          PCSel_Out = `PCSel_ALU;
          Clear = 1'b0;
        end
        `funct3_notBJ: begin
          PCSel_Out = PCSel_In;
          Clear = 1'b1;
        end
        `funct3_BEQ: begin
          PCSel_Out = (BrEQ) ? `PCSel_ALU : `PCSel_4;
          Clear = (BrEQ) ? 1'b0 : 1'b1;
        end
        `funct3_BNE: begin
          PCSel_Out = (BrEQ) ? `PCSel_4 : `PCSel_ALU;
          Clear = (BrEQ) ? 1'b1 : 1'b0;
        end
        `funct3_BLT: begin
          PCSel_Out = (BrLT) ? `PCSel_ALU : `PCSel_4;
          Clear = (BrLT) ? 1'b0 : 1'b1;
        end
        `funct3_BGT: begin
          PCSel_Out = (BrLT) ? `PCSel_4 : `PCSel_ALU;
          Clear = (BrLT) ? 1'b1 : 1'b0;
        end
        `funct3_BLTU: begin
          PCSel_Out = (BrLT) ? `PCSel_ALU : `PCSel_4;
          Clear = (BrLT) ? 1'b0 : 1'b1;
        end
        `funct3_BGEU: begin
          PCSel_Out = (BrLT) ? `PCSel_4 : `PCSel_ALU;
          Clear = (BrLT) ? 1'b1 : 1'b0;
        end
      endcase
    end
  end
endmodule
