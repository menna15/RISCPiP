LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY FetchStage IS
       PORT (
              clk, reset : IN STD_LOGIC;
              instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END FetchStage;

ARCHITECTURE FS_Arch OF FetchStage IS
       ----------------Components--------------------
       ----PC Reg 
       COMPONENT PCounter IS
              PORT (
                     DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                     clk, reset : IN STD_LOGIC;
                     DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
       END COMPONENT;
       ----------

       -----PC Adder
       COMPONENT PC_adder IS
              PORT (
                     A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                     F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
       END COMPONENT;
       -------------
       ---Instruction memory
       COMPONENT InstMEM IS
              PORT (
                     clk : IN STD_LOGIC;
                     PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                     FetchedInstruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
       END COMPONENT;
       -----------------
       SIGNAL AdderIn, AdderOut, PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL inst : STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN
       AdderIn <= PC;
       PCReg : PCounter PORT MAP(AdderOut, clk, reset, PC);
       PCAdder : PC_adder PORT MAP(AdderIn, AdderOut);
       memory : InstMEM PORT MAP(clk, PC, inst);
       instruction <= inst;
END FS_Arch;