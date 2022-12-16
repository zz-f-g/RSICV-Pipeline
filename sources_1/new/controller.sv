`include "controller_code.vh"

module controller (
    input [31:0] inst,
    output reg [3:0] isB,
    output reg PCSel,
    output reg [2:0] ImmSel,
    output reg BrUn,
    output reg ASel,
    output reg BSel,
    output reg [3:0] ALUSel,
    output reg MemRW,
    output reg RegWen,
    output reg [1:0] WBSel,
    output reg RDValid
);
  wire [4:0] opcode = inst[6:2];
  wire [2:0] funct3 = inst[14:12];
  wire funct7 = inst[30];

  always @(*) begin
    if (inst[1:0] == 2'b11) begin
      isB[3] = 1'b1;
      case (opcode)
        `opcode_R: begin
          isB[2:0] = `funct3_notBJ;
          PCSel = `PCSel_4;
          ImmSel = 3'bzzz;
          BrUn = 1'bz;
          ASel = `ASel_REG;
          BSel = `BSel_REG;
          case (funct3)
            `funct3_ADD_SUB: ALUSel = (funct7 == 1'b1) ? `ALUSel_SUB : `ALUSel_ADD;
            `funct3_AND: ALUSel = `ALUSel_AND;
            `funct3_OR: ALUSel = `ALUSel_OR;
            `funct3_XOR: ALUSel = `ALUSel_XOR;
            `funct3_SLL: ALUSel = `ALUSel_SLL;
            `funct3_SLT: ALUSel = `ALUSel_SLT;
            `funct3_SLTU: ALUSel = `ALUSel_SLTU;
            `funct3_SRL_SRA: ALUSel = (funct7 == 1'b1) ? `ALUSel_SRA : `ALUSel_SRL;
          endcase
          MemRW  = `MemRW_L;
          RegWen = 1;
          WBSel  = `WBSel_ALU;
          RDValid = 1;
        end
        `opcode_I: begin
          isB[2:0] = `funct3_notBJ;
          PCSel = `PCSel_4;
          ImmSel = `ImmSel_I;
          BrUn = 1'bz;
          ASel = `ASel_REG;
          BSel = `BSel_Imm;
          case (funct3)
            `funct3_ADD_SUB: ALUSel = `ALUSel_ADD;
            `funct3_AND: ALUSel = `ALUSel_AND;
            `funct3_OR: ALUSel = `ALUSel_OR;
            `funct3_XOR: ALUSel = `ALUSel_XOR;
            `funct3_SLL: ALUSel = `ALUSel_SLL;
            `funct3_SLT: ALUSel = `ALUSel_SLT;
            `funct3_SLTU: ALUSel = `ALUSel_SLTU;
            `funct3_SRL_SRA: ALUSel = (funct7 == 1'b1) ? `ALUSel_SRA : `ALUSel_SRL;
          endcase
          MemRW  = `MemRW_L;
          RegWen = 1;
          WBSel  = `WBSel_ALU;
          RDValid = 1;
        end
        `opcode_B: begin
          isB[2:0] = funct3;
          PCSel = `PCSel_4;
          ImmSel = `ImmSel_B;
          case (funct3)
            `funct3_BLTU, `funct3_BGEU: BrUn = `BrUn_UNSIGNED;
            default: BrUn = `BrUn_SIGNED;
          endcase
          ASel   = `ASel_PC;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          MemRW  = `MemRW_L;
          RegWen = 0;
          WBSel  = `WBSel_ALU;
          RDValid = 0;
        end
        `opcode_I_LOAD: begin
          isB[2:0]    = `funct3_notBJ;
          PCSel  = `PCSel_4;
          ImmSel = `ImmSel_I;
          BrUn   = 1'bz;
          ASel   = `ASel_REG;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          MemRW  = `MemRW_L;
          case (funct3)
            `funct3_B, `funct3_H, `funct3_W, `funct3_BU, `funct3_HU: RegWen = 1;
            default: RegWen = 0;
          endcase
          WBSel = `WBSel_Mem;
          RDValid = 1;
        end
        `opcode_S: begin
          isB[2:0]    = `funct3_notBJ;
          PCSel  = `PCSel_4;
          ImmSel = `ImmSel_S;
          BrUn   = 1'bz;
          ASel   = `ASel_REG;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          case (funct3)
            `funct3_B, `funct3_H, `funct3_W: MemRW = `MemRW_S;
            default: MemRW = `MemRW_L;
          endcase
          RegWen = 0;
          WBSel  = `WBSel_Mem;
          RDValid = 0;
        end
        `opcode_I_JALR: begin
          isB[2:0]    = `funct3_J;
          PCSel  = `PCSel_ALU;
          ImmSel = `ImmSel_I;
          BrUn   = 1'bz;
          ASel   = `ASel_REG;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          MemRW  = `MemRW_L;
          case (funct3)
            `funct3_JALR: RegWen = 1;
            default: RegWen = 0;
          endcase
          WBSel = `WBSel_PC;
          RDValid = 1;
        end
        `opcode_J_JAL: begin
          isB[2:0]    = `funct3_J;
          PCSel  = `PCSel_ALU;
          ImmSel = `ImmSel_J;
          BrUn   = 1'bz;
          ASel   = `ASel_PC;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          MemRW  = `MemRW_L;
          RegWen = 1;
          WBSel  = `WBSel_PC;
          RDValid = 1;
        end
        `opcode_U_LUI: begin
          isB    = `funct3_notBJ;
          PCSel  = `PCSel_4;
          ImmSel = `ImmSel_U1;  // `ImmSel_U2
          BrUn   = 1'bz;
          ASel   = `ASel_PC;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_B;
          MemRW  = `MemRW_L;
          RegWen = 1;
          WBSel  = `WBSel_ALU;
          RDValid = 1;
        end
        `opcode_U_AUIPC: begin
          isB    = `funct3_notBJ;
          PCSel  = `PCSel_4;
          ImmSel = `ImmSel_U1;  // `ImmSel_U2
          BrUn   = 1'bz;
          ASel   = `ASel_PC;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          MemRW  = `MemRW_L;
          RegWen = 1;
          WBSel  = `WBSel_ALU;
          RDValid = 1;
        end
        default: begin
          isB[2:0]    = `funct3_notBJ;
          PCSel  = `PCSel_4;
          ImmSel = `ImmSel_I;
          BrUn   = 1'bz;
          ASel   = `ASel_PC;
          BSel   = `BSel_Imm;
          ALUSel = `ALUSel_ADD;
          MemRW  = `MemRW_L;
          RegWen = 0;
          WBSel  = `WBSel_ALU;
          RDValid = 0;
        end
      endcase
    end else begin
      isB[3]    = 1'b0;
      isB[2:0] = `funct3_notBJ;
      PCSel  = `PCSel_4;
      ImmSel = `ImmSel_I;
      BrUn   = 1'bz;
      ASel   = `ASel_PC;
      BSel   = `BSel_Imm;
      ALUSel = `ALUSel_ADD;
      MemRW  = `MemRW_L;
      RegWen = 0;
      WBSel  = `WBSel_ALU;
      RDValid = 1'b0;
    end
  end
endmodule
