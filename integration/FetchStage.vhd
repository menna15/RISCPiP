LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY FetchStage IS
       PORT (
              -------------INPUTS--------------
              clk, reset,Do32 : IN STD_LOGIC;
              freeze_pc:IN STD_LOGIC;
	      Int_signal:IN STD_LOGIC;
              pc_selector: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
              index: IN STD_LOGIC_vECTOR(15 DOWNTO 0);
              pc_from_stack: IN STD_LOGIC_vECTOR(31 DOWNTO 0);
              pc_from_alu: IN STD_LOGIC_vECTOR(31 DOWNTO 0);
              --Signal if there is a Exp1 or Exp2 or Interupt or Reset
              Address_signal : IN STD_LOGIC_vECTOR(1 DOWNTO 0);
              ------------OUTPUTS--------------
	      pc_to_alu: OUT STD_LOGIC_vECTOR(31 DOWNTO 0);
              instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END FetchStage;

ARCHITECTURE FS_Arch OF FetchStage IS
       ----------------Components--------------------
       ----PC Reg 
       COMPONENT PCounter IS
              PORT (
                     DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                     clk, reset,enable : IN STD_LOGIC;
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
                     clk,Do32 : IN STD_LOGIC;
                     PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
                     FetchedInstruction1,FetchedInstruction2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
       END COMPONENT;
       -----------------
       ----FULL ADDER
       COMPONENT Full_adder IS
       GENERIC (size : INTEGER := 32); 
       PORT (
           a, b : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
           cin : IN STD_LOGIC;
           s : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0);
           carry_flag : OUT STD_LOGIC);
       END COMPONENT;
       ----------
       -----------------
        ----MUX 4x2
        COMPONENT mux4 IS
        GENERIC (size : INTEGER := 32);
        PORT (
            in0, in1, in2, in3 : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
            sel0, sel1 : IN STD_LOGIC;
            out1 : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0));
        END COMPONENT;
        ----------
 
        ----MUX 2X1
        COMPONENT mux2 IS
        GENERIC (size : INTEGER := 10);
        PORT (
             in0, in1 : IN STD_LOGIC_VECTOR(size - 1 DOWNTO 0);
             sel : IN STD_LOGIC;
             out1 : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0));
        END COMPONENT;

       
       SIGNAL inst1,inst2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
       SIGNAL Adder_Mux1_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL Adder_Mux2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL Adder_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL pre_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL PC_value : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL Fetched_Address : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL Carry_Flag: STD_LOGIC;
       SIGNAL Memory_mux_out:  STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL memory_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL PC_Enable: STD_LOGIC_VECTOR(31 DOWNTO 0);
       SIGNAL index_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);

       
BEGIN
       memory_out <=inst2&inst1;
       index_extended<="0000000000000000" & index;
       PC_Enable<= "0000000000000000000000000000000" & (not freeze_pc);
       PCReg : PCounter PORT MAP(PC_value, clk, reset,'1', pre_pc);
       memory : InstMEM PORT MAP(clk,Do32,Memory_mux_out, inst1,inst2);
       Adder_Mux1 : mux2 GENERIC MAP(size => 32) PORT MAP(PC_Enable, std_logic_vector(to_unsigned(6,32)), Int_signal ,Adder_Mux1_out );
       Adder_Mux2 : mux2 GENERIC MAP(size => 32) PORT MAP(pre_pc, index_extended, Int_signal ,Adder_Mux2_out );
       PC_FullAdder: Full_adder GENERIC MAP(size => 32) PORT MAP(Adder_Mux1_out ,Adder_Mux2_out, '0' ,Adder_out, Carry_Flag);
       Fetched_Address_M: Mux4  GENERIC MAP(size => 32) PORT MAP(std_logic_vector(to_unsigned(0,32)),std_logic_vector(to_unsigned(2,32)),std_logic_vector(to_unsigned(4,32)),Adder_out, Address_signal(0), Address_signal(1),Fetched_Address);
       Memory_Mux2 : mux2 GENERIC MAP(size => 32) PORT MAP( pre_pc,Fetched_Address,Do32 ,Memory_mux_out );
       --inst should be data out from the memory 
       PC_Mux: Mux4  GENERIC MAP(size => 32) PORT MAP(Adder_out,memory_out, pc_from_stack, pc_from_alu, pc_selector(0), pc_selector(1),PC_value );
       instruction <= inst1;
       pc_to_alu<= pre_pc;
END FS_Arch;