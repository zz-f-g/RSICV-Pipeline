`timescale 1ns / 1ps
`include "controller_code.vh"

module datapath (
    input clk,
    input rst,
    input [31:0] inst,
    input [31:0] l_data,
    output [31:0] addr_inst,
    output reg [31:0] addr_data,
    output reg [31:0] s_data,
    output reg mem_rw,
    output [31:0] sp
);
  reg [31:0] pc;
  assign addr_inst = pc;
  reg [3:0] isB_buf[1:0];
  reg mem_rw_buf[2:0];
  reg reg_w_en_buf[3:0];
  wire [4:0] addr_a2;
  wire [4:0] addr_b2;
  reg [4:0] addr_a3;
  reg [4:0] addr_b3;
  wire [4:0] addr_d4;
  reg [4:0] addr_d5;
  wire rd_valid_ctrl;
  reg rd_valid[3:0];
  reg [31:0] alu_out_wb;
  reg [31:0] l_data_reg;
  reg [1:0] wb_sel;
  initial begin
    pc = `PC_START_ADDR - 4;
    addr_data = 32'h00000000;
    s_data = 32'h00000000;
    mem_rw = `MemRW_L;
    isB_buf[0] = 4'h0;
    isB_buf[1] = 4'h0;
    mem_rw_buf[0] = `MemRW_L;
    mem_rw_buf[1] = `MemRW_L;
    mem_rw_buf[2] = `MemRW_L;
    reg_w_en_buf[0] = 1'b0;
    reg_w_en_buf[1] = 1'b0;
    reg_w_en_buf[2] = 1'b0;
    reg_w_en_buf[3] = 1'b0;
    addr_d5 = 5'b11111;
    alu_out_wb = 32'h00000000;
    l_data_reg = 32'h00000000;
    wb_sel = 2'b11;
    rd_valid[0] = 1'b0;
    rd_valid[1] = 1'b0;
    rd_valid[2] = 1'b0;
    rd_valid[3] = 1'b0;
    addr_a3 = 5'b00000;
    addr_b3 = 5'b00000;
  end

  /*
   * step 1: instruction fetch
   */
  wire [31:0] pc_n;
  wire pc_sel;
  wire [31:0] alu_out;
  assign pc_n = (pc_sel == `PCSel_4) ? (pc + 32'h00000004) : alu_out;

  wire [31:0] s_data_selected;


  wire clr;
  wire [3:0] isB;
  wire [3:0] isB_ctrl;
  assign isB = isB_buf[1];

  wire mem_rw_ctrl;
  wire [31:0] l_data_selected;

  wire reg_w_en;
  wire reg_w_en_ctrl;
  assign reg_w_en = reg_w_en_buf[3];

  wire [1:0] wb_sel_forward;

  always @(posedge clk, posedge rst) begin
    if (rst == 0) begin
      // step 1
      pc <= pc_n;

      // step 3
      addr_data <= alu_out;
      s_data <= s_data_selected;

      // step 4
      alu_out_wb <= addr_data;
      l_data_reg <= l_data_selected;

      // buffers
      isB_buf[1] <= (clr == 1'b1) ? isB_buf[0] : 4'h0;
      isB_buf[0] <= (clr == 1'b1) ? isB_ctrl : 4'h0;
      mem_rw <= mem_rw_buf[1];
      mem_rw_buf[1] <= mem_rw_buf[0] & clr;
      mem_rw_buf[0] <= mem_rw_ctrl & clr;
      reg_w_en_buf[3] <= reg_w_en_buf[2];
      reg_w_en_buf[2] <= reg_w_en_buf[1];
      reg_w_en_buf[1] <= reg_w_en_buf[0] & clr;
      reg_w_en_buf[0] <= reg_w_en_ctrl & clr;

      // data forwarding
      wb_sel <= wb_sel_forward;
      addr_a3 <= addr_a2;
      addr_b3 <= addr_b2;
      addr_d5 <= addr_d4;
      rd_valid[3] <= rd_valid[2];
      rd_valid[2] <= rd_valid[1];
      rd_valid[1] <= rd_valid[0] & clr;
      rd_valid[0] <= rd_valid_ctrl & clr;
    end else begin
      pc <= `PC_START_ADDR;
    end
  end

  wire [31:0] pc_alu;
  ShiftReg #(
      .STEP (2),
      .WIDTH(32),
      .RST  (32'h00000000)
  ) pc_alu_sr (
      .clk(clk),
      .rst(rst),
      .in (pc),
      .out(pc_alu)
  );

  wire [31:0] pc_wb;
  ShiftReg #(
      .STEP (2),
      .WIDTH(32),
      .RST  (32'h00000000)
  ) pc_wb_sr (
      .clk(clk),
      .rst(rst),
      .in (pc_alu),
      .out(pc_wb)
  );

  wire [4:0] addr_a1;
  assign addr_a1 = inst[19:15];
  ShiftReg #(
      .STEP (1),
      .WIDTH(5),
      .RST  (5'b00000)
  ) addr_a_sr (
      .clk(clk),
      .rst(rst),
      .in (addr_a1),
      .out(addr_a2)
  );

  wire [4:0] addr_b1;
  assign addr_b1 = inst[24:20];
  ShiftReg #(
      .STEP (1),
      .WIDTH(5),
      .RST  (5'b00000)
  ) addr_b_sr (
      .clk(clk),
      .rst(rst),
      .in (addr_b1),
      .out(addr_b2)
  );

  wire [4:0] addr_d1;
  assign addr_d1 = inst[11:7];
  ShiftReg #(
      .STEP (3),
      .WIDTH(5),
      .RST  (5'b00000)
  ) addr_d_sr (
      .clk(clk),
      .rst(rst),
      .in (addr_d1),
      .out(addr_d4)
  );

  wire pc_sel_ctrl;
  wire [2:0] imm_sel_ctrl;
  wire br_un_ctrl;
  wire asel_ctrl;
  wire bsel_ctrl;
  wire [3:0] alu_sel_ctrl;
  wire [1:0] wb_sel_ctrl;
  controller my_controller (
      .inst(inst),
      .isB(isB_ctrl),
      .PCSel(pc_sel_ctrl),
      .ImmSel(imm_sel_ctrl),
      .BrUn(br_un_ctrl),
      .ASel(asel_ctrl),
      .BSel(bsel_ctrl),
      .ALUSel(alu_sel_ctrl),
      .MemRW(mem_rw_ctrl),
      .RegWen(reg_w_en_ctrl),
      .WBSel(wb_sel_ctrl),
      .RDValid(rd_valid_ctrl)
  );

  wire pc_sel_branch;
  ShiftReg #(
      .STEP (2),
      .WIDTH(1),
      .RST  (`PCSel_4)
  ) pc_sel_sr (
      .clk(clk),
      .rst(rst),
      .in (pc_sel_ctrl),
      .out(pc_sel_branch)
  );

  wire [2:0] imm_sel;
  ShiftReg #(
      .STEP (2),
      .WIDTH(3),
      .RST  (`ImmSel_I)
  ) imm_sel_sr (
      .clk(clk),
      .rst(rst),
      .in (imm_sel_ctrl),
      .out(imm_sel)
  );

  wire br_un_branch;
  ShiftReg #(
      .STEP (2),
      .WIDTH(1),
      .RST  (`BrUn_SIGNED)
  ) br_un_sr (
      .clk(clk),
      .rst(rst),
      .in (br_un_ctrl),
      .out(br_un_branch)
  );

  wire asel;
  ShiftReg #(
      .STEP (2),
      .WIDTH(1),
      .RST  (`ASel_REG)
  ) asel_sr (
      .clk(clk),
      .rst(rst),
      .in (asel_ctrl),
      .out(asel)
  );

  wire bsel;
  ShiftReg #(
      .STEP (2),
      .WIDTH(1),
      .RST  (`BSel_REG)
  ) bsel_sr (
      .clk(clk),
      .rst(rst),
      .in (bsel_ctrl),
      .out(bsel)
  );

  wire [3:0] alu_sel;
  ShiftReg #(
      .STEP (2),
      .WIDTH(4),
      .RST  (`ALUSel_ADD)
  ) alu_sel_sr (
      .clk(clk),
      .rst(rst),
      .in (alu_sel_ctrl),
      .out(alu_sel)
  );

  ShiftReg #(
      .STEP (3),
      .WIDTH(2),
      .RST  (`WBSel_ALU)
  ) wb_sel_sr (
      .clk(clk),
      .rst(rst),
      .in (wb_sel_ctrl),
      .out(wb_sel_forward)
  );

  wire [2:0] data_sel_ctrl;
  assign data_sel_ctrl = inst[14:12];
  wire [2:0] data_sel_store;
  wire [2:0] data_sel_load;
  ShiftReg #(
      .STEP (2),
      .WIDTH(3),
      .RST  (`funct3_W)
  ) data_sel_store_sr (
      .clk(clk),
      .rst(rst),
      .in (data_sel_ctrl),
      .out(data_sel_store)
  );
  ShiftReg #(
      .STEP (2),
      .WIDTH(3),
      .RST  (`funct3_W)
  ) data_sel_load_sr (
      .clk(clk),
      .rst(rst),
      .in (data_sel_store),
      .out(data_sel_load)
  );

  wire [24:0] imm_src;
  ShiftReg #(
      .STEP (2),
      .WIDTH(25),
      .RST  (25'b0)
  ) imm_src_sr (
      .clk(clk),
      .rst(rst),
      .in (inst[31:7]),
      .out(imm_src)
  );

  /*
   * step 2: read from registers
   */
  wire [31:0] wb;
  wire [31:0] data_a2;
  wire [31:0] data_b2;
  regs my_regs (
      .clk(~clk),
      .rst(rst),
      .AddrA(addr_a2),
      .AddrB(addr_b2),
      .AddrD(addr_d5),
      .RegWEn(reg_w_en),
      .DataD(wb),
      .DataA(data_a2),
      .DataB(data_b2),
      .sp(sp)
  );

  wire [31:0] data_a3_forward;
  wire [31:0] data_a3;
  ShiftReg #(
      .STEP (1),
      .WIDTH(32),
      .RST  (32'h00000000)
  ) data_a_sr (
      .clk(clk),
      .rst(rst),
      .in (data_a2),
      .out(data_a3)
  );

  wire [31:0] data_b3_forward;
  wire [31:0] data_b3;
  ShiftReg #(
      .STEP (1),
      .WIDTH(32),
      .RST  (32'h00000000)
  ) data_b_sr (
      .clk(clk),
      .rst(rst),
      .in (data_b2),
      .out(data_b3)
  );

  /*
   * step 3: compute and compare
   */
  wire br_eq;
  wire br_lt;
  BranchComp my_bc (
      .DataA(data_a3_forward),
      .DataB(data_b3_forward),
      .BrUn (br_un_branch),
      .BrEQ (br_eq),
      .BrLT (br_lt)
  );

  wire [31:0] imm;
  ImmGen my_ig (
      .inst_imm(imm_src),
      .ImmSel(imm_sel),
      .imm(imm)
  );

  /*
   * Forward for data hazard
   */
  wire [31:0] alu_in1;
  Forward af (
      .Addr(addr_a3),
      .AddrD4(addr_d4),
      .RDValid4(rd_valid[2]),
      .AddrD5(addr_d5),
      .RDValid5(rd_valid[3]),
      .WBSel4(wb_sel_forward[0]),
      .WBSel5(wb_sel[0]),
      .DataALU4(addr_data),
      .DataALU5(alu_out_wb),
      .DataMem4(l_data_selected),
      .DataMem5(l_data_reg),
      .DataIn(data_a3),
      .DataOut(data_a3_forward)
  );
  assign alu_in1 = (asel == `ASel_PC) ? pc_alu : data_a3_forward;
  wire [31:0] alu_in2;
  Forward bf (
      .Addr(addr_b3),
      .AddrD4(addr_d4),
      .RDValid4(rd_valid[2]),
      .AddrD5(addr_d5),
      .RDValid5(rd_valid[3]),
      .WBSel4(wb_sel_forward[0]),
      .WBSel5(wb_sel[0]),
      .DataALU4(addr_data),
      .DataALU5(alu_out_wb),
      .DataMem4(l_data_selected),
      .DataMem5(l_data_reg),
      .DataIn(data_b3),
      .DataOut(data_b3_forward)
  );
  assign alu_in2 = (bsel == `BSel_REG) ? data_b3_forward : imm;
  alu my_alu (
      .op1(alu_in1),
      .op2(alu_in2),
      .ALUSel(alu_sel),
      .res(alu_out)
  );

  DataSel my_store_ds (
      .DataIn (data_b3_forward),
      .DataSel(data_sel_store),
      .DataOut(s_data_selected)
  );

  BranchController my_bctrl (
      .isB(isB),
      .BrEQ(br_eq),
      .BrLT(br_lt),
      .PCSel_In(pc_sel_branch),
      .PCSel_Out(pc_sel),
      .Clear(clr)
  );

  /*
   * step 4: interact with data memory
   */

  /*
   * step 5: register write back
   */
  DataSel my_load_ds (
      .DataIn (l_data),
      .DataSel(data_sel_load),
      .DataOut(l_data_selected)
  );
  writeback my_wb (
      .rd(alu_out_wb),
      .mem(l_data_reg),
      .pc(pc_wb),
      .WBSel(wb_sel),
      .wb(wb)
  );
endmodule
