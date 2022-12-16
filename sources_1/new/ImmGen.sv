`timescale 1ns / 1ps
`include "controller_code.vh"


module ImmGen (
    input [24:0] inst_imm,
    input [2:0] ImmSel,
    output reg [31:0] imm
);
  always @(*) begin
    case (ImmSel)
      `ImmSel_I: begin
          imm[11:0]  = inst_imm[24:13];
          imm[31:12] = {(32 - 12) {imm[11]}};
      end
      `ImmSel_S: begin
        imm[11:5]  = inst_imm[24:18];
        imm[4:0]   = inst_imm[4:0];
        imm[31:12] = {(32 - 12) {imm[11]}};
      end
      `ImmSel_B: begin
        imm[12] = inst_imm[24];
        imm[11] = inst_imm[0];
        imm[10:5] = inst_imm[23:18];
        imm[4:1] = inst_imm[4:1];
        imm[0] = 1'b0;
        imm[31:13] = {(32 - 13) {imm[11]}};
      end
      `ImmSel_J: begin
        imm[20] = inst_imm[24];
        imm[19:12] = inst_imm[12:7];
        imm[11] = inst_imm[13];
        imm[10:1] = inst_imm[23:14];
        imm[0] = 1'b0;
        imm[31:21] = {(32 - 21) {imm[11]}};
      end
      `ImmSel_U1: begin
        imm[31:12] = inst_imm[24:5];
        imm[11:0]  = 12'h000;
      end
      `ImmSel_U2: begin
        imm[31:12] = inst_imm[24:5];
        imm[11:0]  = 12'h000;
      end
      default: imm[31:0] = 32'h00000000;
    endcase
  end
endmodule
