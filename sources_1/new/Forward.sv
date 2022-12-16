`timescale 1ns / 1ps
`include "controller_code.vh"

module Forward (
    input [4:0] Addr,
    input [4:0] AddrD4,
    input RDValid4,
    input [4:0] AddrD5,
    input RDValid5,
    input WBSel4,
    input WBSel5,
    input [31:0] DataALU4,
    input [31:0] DataALU5,
    input [31:0] DataMem4,
    input [31:0] DataMem5,
    input [31:0] DataIn,
    output [31:0] DataOut
);
  wire [1:0] ForwardSel;
  assign ForwardSel[1] = (Addr == AddrD5) & (RDValid5 == 1'b1);  // data hazard
  assign ForwardSel[0] = (Addr == AddrD4) & (RDValid4 == 1'b1);  // in which step
  wire [31:0] DataForward4 = (WBSel4 == 1'b1) ? DataALU4 : DataMem4;
  wire [31:0] DataForward5 = (WBSel5 == 1'b1) ? DataALU5 : DataMem5;
  wire [31:0] DataForward = (ForwardSel[0]) ? DataForward4 : DataForward5;
  assign DataOut = (Addr == 5'b00000) ? 5'b00000 : ((ForwardSel[0] | ForwardSel[1]) ? DataForward : DataIn);
endmodule
