`timescale 1ns / 1ps
`include "controller_code.vh"

module alu (
    input [31:0] op1,
    input [31:0] op2,
    input [3:0] ALUSel,
    output reg [31:0] res
);
  wire [31:0] srlres;
  wire [31:0] srlmask;
  assign srlres = op1 >> op2[4:0];
  assign srlmask = 32'hffffffff >> op2[4:0];
  always @(*) begin
    case (ALUSel)
      `ALUSel_ADD: begin
        res = op1 + op2;
      end
      `ALUSel_SUB: begin
        res = op1 - op2;
      end
      `ALUSel_XOR: begin
        res = op1 ^ op2;
      end
      `ALUSel_OR: begin
        res = op1 | op2;
      end
      `ALUSel_AND: begin
        res = op1 & op2;
      end
      `ALUSel_SLL: begin
        res = op1 << op2[4:0];
      end
      `ALUSel_SRL: begin
        res = srlres;
      end
      `ALUSel_SRA: begin
        res = srlres | ({32{op1[31]}} & (~srlmask));
      end
      `ALUSel_B: begin
        res = op2;
      end
      `ALUSel_SLT: begin
        res = {32{(~($signed(op1) >= $signed(op2)))}} & 32'h1;
      end
      `ALUSel_SLTU: begin
        res = {32{(~(op1 >= op2))}} & 32'h1;
      end
      default: res <= 32'h11111111;
    endcase
  end
endmodule
