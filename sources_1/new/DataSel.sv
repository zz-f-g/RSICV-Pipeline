`timescale 1ns / 1ps
`include "controller_code.vh"

module DataSel (
    input  [31:0] DataIn,
    input  [ 2:0] DataSel,
    output reg [31:0] DataOut
);
  reg [31:0] ByteSel = 32'h000000ff;
  reg [31:0] HalfSel = 32'h0000ffff;
  always @(*) begin
    case (DataSel)
      `funct3_B:  DataOut = ((DataIn & ByteSel) | ({32{DataIn[7]}}) & (~ByteSel));
      `funct3_H:  DataOut = ((DataIn & HalfSel) | ({32{DataIn[15]}}) & (~HalfSel));
      `funct3_W:  DataOut = DataIn;
      `funct3_BU: DataOut = DataIn & ByteSel;
      `funct3_HU: DataOut = DataIn & HalfSel;
      default: DataOut = 32'h00000000;
    endcase
  end
endmodule
