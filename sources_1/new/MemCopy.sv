`timescale 1ns / 1ps
`define ROM_BEGIN 32'h00000000
`define ROM_END 32'h00000200
`include "controller_code.vh"

module MemCopy (
    input clk,
    input rst,
    input [31:0] ROM_Data,
    output reg available,
    output reg [31:0] ROM_Addr,
    output reg [31:0] RAM_Addr,
    output [31:0] RAM_Data,
    output reg MemRW
);
  initial begin
    available = 1'b0;
    ROM_Addr = `ROM_BEGIN - 4;
    RAM_Addr = `PC_START_ADDR - 4;
    MemRW = `MemRW_S;
  end
  assign RAM_Data = ROM_Data;
  always @(posedge clk, posedge rst) begin
    if (rst == 1'b0) begin
      if ($signed(ROM_Addr) >= $signed(`ROM_END)) begin
        available <= 1'b1;
        MemRW <= `MemRW_L;
      end else begin
        ROM_Addr <= ROM_Addr + 4;
        RAM_Addr <= RAM_Addr + 4;
      end
    end else begin
      available = 1'b0;
      ROM_Addr = `ROM_BEGIN - 4;
      RAM_Addr = `PC_START_ADDR - 4;
      MemRW = `MemRW_S;
    end
  end
endmodule
