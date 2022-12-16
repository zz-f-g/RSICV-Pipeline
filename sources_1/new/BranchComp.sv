`timescale 1ns / 1ps
`include "controller_code.vh"

module BranchComp (
    input [31:0] DataA,
    input [31:0] DataB,
    input BrUn,
    output reg BrEQ,
    output reg BrLT
);
  always @(*) begin
    if (DataA == DataB) begin
      BrEQ = `BrEQ_BEQ;
      BrLT = `BrLT_BGE;
    end else begin
      BrEQ = `BrEQ_BNE;
      case (BrUn)
        `BrUn_UNSIGNED: begin
          if (DataA < DataB) begin
            BrLT = `BrLT_BLT;
          end else begin
            BrLT = `BrLT_BGE;
          end
        end
        `BrUn_SIGNED: begin
          if ($signed(DataA) < $signed(DataB)) begin
            BrLT = `BrLT_BLT;
          end else begin
            BrLT = `BrLT_BGE;
          end
        end
      endcase
    end
  end
endmodule
