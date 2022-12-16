`timescale 1ns / 1ps


module tb();
  reg clk;
  reg rst;
  wire [3:0] sp;
  top mytop (
      clk,
      rst,
      sp
  );
  initial begin
    rst = 0;
    clk = 0;
    #1 rst = 1;
    forever begin
      #1 clk = ~clk;
    end
  end
endmodule
