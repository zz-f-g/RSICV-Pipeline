`define PC_START_ADDR 32'h00010054
`define PC_END_ADDR 32'h00010ffc
`define ARRAY_ADDR 32'h00010018
/* instructions */
`define opcode_R 5'b01100
`define opcode_I 5'b00100
`define funct3_ADD_SUB 3'b000
`define funct3_SLL 3'b001
`define funct3_SLT 3'b010
`define funct3_SLTU 3'b011
`define funct3_XOR 3'b100
`define funct3_SRL_SRA 3'b101
`define funct3_OR 3'b110
`define funct3_AND 3'b111

`define opcode_I_LOAD 5'b00000
`define opcode_S 5'b01000
`define funct3_B 3'b000
`define funct3_H 3'b001
`define funct3_W 3'b010
`define funct3_BU 3'b100
`define funct3_HU 3'b101

`define opcode_I_JALR 5'b11001
`define funct3_JALR 3'b000

`define opcode_B 5'b11000
`define funct3_BEQ 3'b000
`define funct3_BNE 3'b001
`define funct3_BLT 3'b100
`define funct3_BGT 3'b101
`define funct3_BLTU 3'b110
`define funct3_BGEU 3'b111
`define funct3_notBJ 3'b010
`define funct3_J 3'b011

`define opcode_J_JAL 5'b11011

`define opcode_U_LUI 5'b01101

`define opcode_U_AUIPC 5'b00101

/* compare module */
`define BrEQ_BEQ 1'b1
`define BrEQ_BNE 1'b0

`define BrLT_BLT 1'b1
`define BrLT_BGE 1'b0

`define BrUn_UNSIGNED 1'b1
`define BrUn_SIGNED 1'b0


/* alu module */
`define ASel_REG 1'b0
`define ASel_PC 1'b1

`define BSel_REG 1'b0
`define BSel_Imm 1'b1

`define ALUSel_ADD 4'h0
`define ALUSel_SUB 4'h1
`define ALUSel_XOR 4'h2
`define ALUSel_OR 4'h3
`define ALUSel_AND 4'h4
`define ALUSel_SLL 4'h5
`define ALUSel_SRL 4'h6
`define ALUSel_SRA 4'h7
`define ALUSel_SLT 4'h9
`define ALUSel_SLTU 4'ha
`define ALUSel_B 4'h8

/* other mod */
`define PCSel_4 1'b0
`define PCSel_ALU 1'b1

`define ImmSel_I 3'b000
`define ImmSel_S 3'b001
`define ImmSel_B 3'b010
`define ImmSel_J 3'b011
`define ImmSel_U1 3'b100
`define ImmSel_U2 3'b101

`define MemRW_S 1'b1
`define MemRW_L 1'b0

`define WBSel_Mem 2'b00
`define WBSel_ALU 2'b01
`define WBSel_PC 2'b10
