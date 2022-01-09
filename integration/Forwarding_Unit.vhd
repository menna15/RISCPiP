LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
------------------Forwarding Unit -------------------------
ENTITY FU IS
  PORT (
    R_src1_addr, R_scr2_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    clk, Imm_Signal : IN STD_LOGIC;
    WR_Mem_WB, WR_Ex_Mem : IN STD_LOGIC;
    R_dest_Mem_WB, R_dest_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    Sel1, Sel2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));

END ENTITY;

ARCHITECTURE FU_Arc OF FU IS
  SIGNAL selector_signal1, selector_signal2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
  Sel1 <= selector_signal1;
  Sel2 <= selector_signal2;
  PROCESS (clk)
  BEGIN
    IF (rising_edge (Clk)) THEN
      IF (Imm_Signal = '1') THEN
        selector_signal2 <= "11";
      ELSIF (R_dest_Mem_WB = R_scr2_addr AND WR_Mem_WB = '1') THEN
        selector_signal2 <= "01";
      ELSIF (R_dest_Ex_Mem = R_scr2_addr AND WR_Ex_Mem = '1') THEN
        selector_signal2 <= "10";
      ELSE
        selector_signal2 <= "00";
      END IF;
      IF (R_dest_Mem_WB = R_src1_addr AND WR_Mem_WB = '1') THEN
        selector_signal1 <= "01";
      ELSIF (R_dest_Ex_Mem = R_src1_addr AND WR_Ex_Mem = '1') THEN
        selector_signal1 <= "10";
      ELSE
        selector_signal1 <= "00";
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE;