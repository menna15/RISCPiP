### :desktop_computer: RISCPiP
RISC 5-stage 16-bit piplined processor with harvard architecture. And assembler to decode instructions to machine code.

### 📋 Instruction Set
| One Operand Instructions | Two Operand Instructions  |  Memory Instructions |  Branch Instructions |
|---|---|---|---|
| NOP  |  MOV Rsrc, Rdst |  PUSH Rsrc |  JZ Rdst |
| HLT  | ADD Rdst, Rsrc1, Rsrc2  |  POP Rdst |  JC Rdst |
|  SETC |SUB Rdst, Rsrc1, Rsrc2   | LDM Rdst, Imm  | JN Rdst  |
|  NOT Rdst| AND Rdst, Rsrc1, Rsrc2  | LDD Rdst, offset(Rsrc)  | JMP Rdst  |
|  INC Rdst|  IADD Rdst, Rsrc1, Imm | STD Rsrc1, offset(Rsrc2)  | CALL Rdst  |
|  OUT Rsrc | -  | -  | RET  (for call)|
|  IN Rdst |   - | -  |  INT index |
| - |  - | -  |  RTI (for interrupt)|

### :fountain_pen: Instruction
| 5-bits Opcode | 3-bit src1 register address |  3-bit src2 register address |  3-bit dst register address | 2-bit (not yet used) |
|---            |---                          |---                           |---                          |---                   |

### :fountain_pen: Instructions' Document
more detailed document for decoding the instructions [click](https://github.com/menna15/RISCPiP/blob/main/CMP301_Fall_2021_Project.pdf)

### :art: Schema
![labeled_Schema](https://user-images.githubusercontent.com/49396399/153286042-c361888a-12d7-493c-ac52-9a7576ab7c2f.png)


