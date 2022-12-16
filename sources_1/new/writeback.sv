`timescale 1ns / 1ps

`include "controller_code.vh"

module writeback (
    input [31:0] rd,
    input [31:0] mem,
    input [31:0] pc,
    input [1:0] WBSel,
    output reg [31:0] wb
);
  always @(*) begin
    case (WBSel)
      `WBSel_ALU: wb = rd;
      `WBSel_Mem: wb = mem;
      `WBSel_PC: wb = pc + 32'h00000004;
      default: wb = rd;
    endcase
  end
endmodule
