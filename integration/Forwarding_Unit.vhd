LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
------------------Forwarding Unit -------------------------
ENTITY FU IS
  PORT (
    R_src1_addr,R_scr2_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    Imm_Signal: IN STD_LOGIC;
    WR_Mem_WB, WR_Ex_Mem: IN STD_LOGIC;
    R_dest_Mem_WB,R_dest_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    Sel : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END ENTITY;

ARCHITECTURE FU_Arc OF FU IS
BEGIN
  Sel <= "11" when Imm_Signal='1' else
      "01" when (R_dest_Mem_WB=R_src1_addr or R_dest_Mem_WB=R_scr2_addr) and WR_Mem_WB= '1' else
      "10"   when (R_dest_Ex_Mem=R_src1_addr or R_dest_Ex_Mem=R_scr2_addr) and WR_Ex_Mem='1' else
      "00" ;
END ARCHITECTURE;