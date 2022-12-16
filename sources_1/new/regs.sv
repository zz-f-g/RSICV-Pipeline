`timescale 1ns / 1ps
`include "controller_code.vh"

module regs (
    input clk,
    input rst,
    input [4:0] AddrA,
    input [4:0] AddrB,
    input [4:0] AddrD,
    input RegWEn,
    input [31:0] DataD,
    output [31:0] DataA,
    output [31:0] DataB,
    output [31:0] sp
);
  reg [31:0] registers[31:0];
  initial begin
    registers[0]  = 32'h00000000;
    registers[1]  = `PC_END_ADDR;
    registers[2]  = `PC_START_ADDR;
    registers[3]  = 32'h00000000;
    registers[4]  = 32'h00000000;
    registers[5]  = 32'h00000000;
    registers[6]  = 32'h00000000;
    registers[7]  = 32'h00000000;
    registers[8]  = `PC_START_ADDR;
    registers[3]  = 32'h00000000;
    registers[9]  = 32'h00000000;
    registers[10] = 32'h00000000;
    registers[11] = 32'h00000000;
    registers[12] = 32'h00000000;
    registers[13] = 32'h00000000;
    registers[14] = 32'h00000000;
    registers[15] = 32'h00000000;
    registers[16] = 32'h00000000;
    registers[17] = 32'h00000000;
    registers[18] = 32'h00000000;
    registers[19] = 32'h00000000;
    registers[20] = 32'h00000000;
    registers[21] = 32'h00000000;
    registers[22] = 32'h00000000;
    registers[23] = 32'h00000000;
    registers[24] = 32'h00000000;
    registers[25] = 32'h00000000;
    registers[26] = 32'h00000000;
    registers[27] = 32'h00000000;
    registers[28] = 32'h00000000;
    registers[29] = 32'h00000000;
    registers[30] = 32'h00000000;
    registers[31] = 32'h00000000;
  end
  assign sp = registers[2];
  assign DataA = (AddrA == 5'b00000) ? 32'h00000000 : registers[AddrA];
  assign DataB = (AddrB == 5'b00000) ? 32'h00000000 : registers[AddrB];
  always @(posedge clk, posedge rst) begin
    if (rst == 1) begin
        registers[2] = `PC_START_ADDR;
        registers[8] = `PC_START_ADDR;
    end else begin
      if (RegWEn == 1) begin
        registers[AddrD] <= DataD;
      end
    end
  end
endmodule
