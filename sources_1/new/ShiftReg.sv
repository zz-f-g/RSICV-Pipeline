`timescale 1ns / 1ps

module ShiftReg #(
    parameter STEP  = 4,
    parameter WIDTH = 1,
    parameter RST   = 1'b0
) (
    input clk,
    input rst,
    input [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);
  integer i;
  reg [WIDTH-1:0] Info[STEP-1:0];
  assign out = Info[0];
  always @(posedge clk, posedge rst) begin
    if (rst == 1'b1) begin
      for (i = 0; i < STEP; i = i + 1) begin
        Info[i] <= RST;
      end
    end else begin
      for (i = 0; i < STEP - 1; i = i + 1) begin
        Info[i] <= Info[i+1];
      end
      Info[STEP-1] <= in;
    end
  end
endmodule
