`timescale 1ns / 1ps
`include "controller_code.vh"

module top (
    input clk,
    input rst,
    output [3:0] sp_part
);
  wire [31:0] pc;
  wire [31:0] inst;
  wire [31:0] s_data;
  wire [31:0] addr;
  wire [31:0] l_data;
  wire [31:0] dp_ram_addr;
  wire [31:0] dp_ram_data;
  wire dp_ram_rw;
  wire [31:0] rom_data;
  wire avail;
  wire [31:0] rom_addr;
  wire [31:0] mc_ram_addr;
  wire [31:0] mc_ram_data;
  wire mc_ram_rw;
  wire mem_rw;
  wire [31:0] sp;
  assign sp_part = sp[3:0];
  datapath my_dp (
      .clk(clk),
      .rst(~avail),
      .inst(inst),
      .l_data(l_data),
      .addr_inst(pc),
      .addr_data(dp_ram_addr),
      .s_data(dp_ram_data),
      .mem_rw(dp_ram_rw),
      .sp(sp)
  );
  MemCopy my_mc (
      .clk(clk),
      .rst(~rst),
      .ROM_Data(rom_data),
      .available(avail),
      .ROM_Addr(rom_addr),
      .RAM_Addr(mc_ram_addr),
      .RAM_Data(mc_ram_data),
      .MemRW(mc_ram_rw)
  );
  IMem my_im (
      .a(rom_addr[9:2]),  // input wire [7 : 0] a
      .spo(rom_data)  // output wire [31 : 0] spo
  );
  RAM my_ram (
      .clka (~clk),        // input wire clka
      .ena  (1'b1),        // input wire ena
      .wea  (1'b0),        // input wire [0 : 0] wea
      .addra(pc[11:2]),    // input wire [9 : 0] addra
      .dina (0),           // input wire [31 : 0] dina
      .douta(inst),        // output wire [31 : 0] douta
      .clkb (~clk),        // input wire clkb
      .enb  (1'b1),        // input wire enb
      .web  (mem_rw),      // input wire [0 : 0] web
      .addrb(addr[11:2]),  // input wire [9 : 0] addrb
      .dinb (s_data),      // input wire [31 : 0] dinb
      .doutb(l_data)       // output wire [31 : 0] doutb
  );
  assign mem_rw = (avail == 1'b1) ? dp_ram_rw : mc_ram_rw;
  assign s_data = (avail == 1'b1) ? dp_ram_data : mc_ram_data;
  assign addr   = (avail == 1'b1) ? dp_ram_addr : mc_ram_addr;
endmodule
