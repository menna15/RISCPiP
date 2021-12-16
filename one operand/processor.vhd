library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity processor is                    
    Port (   
          clk   : std_logic;
          reset : std_logic;
          instruction : std_logic_vector(15 downto 0);
          immediate   : std_logic;  -- added as input untill fetch stage be ready then will be taken as input from it --
          exception_flag   : std_logic_vector(1 downto 0); -- added as input untill memory stage be ready then will be taken as input from it --
          inPort           : std_logic_vector(15 downto 0); -- added as input untill decode stage be ready then will be taken as input from it --
          R_src1,R_src2    : std_logic_vector(15 downto 0); -- added as input untill decode stage be ready then will be taken as input from it --
          
          ALU_TO_ALU,MEM_TO_ALU :std_logic_vector(15 downto 0); -- added as input untill forwarding unit be ready then will be taken as input from buffers --
          IMM_value             :std_logic_vector(15 downto 0); -- added as input untill fetch stage be ready then will be taken as input from it --
          
          PC  : std_logic_vector(31 downto 0);                  -- added as input untill fetch stage be ready then will be taken as input from it - 
          
          R_src1_address,R_src2_address,R_dest_address :in std_logic_vector(2 downto 0);  -- added as input untill decode stage be ready then will be taken as input from it --
          forwarding_unit_selector:in std_logic_vector(1 downto 0); -- added as input untill forwarding unit be ready then will be taken as input from it --
          C_Z_N_flags_from_stack  :in std_logic_vector(2 downto 0); -- added as input untill memory stage be ready then will be taken as input from it --
);                
end processor;

architecture processor_a of processor is

----------------------------------- Components --------------------------------
component control_unit is
	port (  
        ----- inputs ---------
        clk             : in std_logic;
        opcode          : in std_logic_vector(4 downto 0);
        immediate_value : in std_logic ;  -- 1 bit signal comes from fetch stage --
        exception_flag  : in std_logic_vector(1 downto 0) ;
        -- reset --
        reset_in     : in std_logic;  -- from Processor --
        reset_out    : out std_logic; -- to the buffers in all stages --
        ---- outputs ---------
        memRead       : out std_logic;
        memWrite      : out std_logic;
        inPort        : out std_logic;
        outPort       : out std_logic;
        interrupt     : out std_logic;                           -- interrupt signal to the mux in the fetch stage --
        do_32_memory  : out std_logic;                           -- signal to the memory to decide if it will read 32 bits or 16 bits --
        do_32_fetch   : out std_logic;                           -- signal to the fetch to decide if it will read 32 bits or 16 bits --
        fetch_flush   : out std_logic; 
        decode_flush  : out std_logic; 
        memory_flush  : out std_logic; 
        WB_flush      : out std_logic; 
        regFileWrite  : out std_logic;                      -- register file write enable --
        imm_value     : out std_logic;                      -- 1 bit signals outs to fetch buffer --
        PC_selector   : out std_logic_vector (2 downto 0);
        stack_memory  : out std_logic;                      -- if 0 stack operations if 1 memory operations --
        alu_selector  : out std_logic_vector (3 DOWNTO 0);  -- for selecting alu operation --

        exception_selector : out std_logic );

end component;

component ALUStage is
PORT(
--Muxes inputs
IN_port,R_src1,R_src2,ALU_TO_ALU,MEM_TO_ALU,IMM_value:in std_logic_vector(15 downto 0);

--EX & M & WR signals

EX     :in std_logic_vector(3 downto 0);
M,WR   :in std_logic_vector(2 downto 0);
PC     :in std_logic_vector(31 downto 0);

--additional buffers for hazard detection unit

R_src1_address,R_src2_address,R_dest_address :in std_logic_vector(2 downto 0);

--input from forwarding unit

forwarding_unit_selector        :in std_logic_vector(1 downto 0);

--for registers in this stage

clk,reset,en                    :in std_logic;

--flags from stack in case ret operation 
C_Z_N_flags_from_stack          :in std_logic_vector(2 downto 0);

M_out,WR_out,R_dest_address_out :out std_logic_vector(2 downto 0);
ALU_out,R_src1_out              :out std_logic_vector(15 downto 0);
PC_flages                       :out std_logic_vector(34 downto 0);
branch_signal                   :out std_logic); 
end component;


-------------------------------------------------- signals --------------------
-- control unit --
signal reset_out_signal     :std_logic; -- to the buffers in all stages --
signal memRead_signal       :std_logic;
signal memWrite_signal      :std_logic;
signal inPort_signal        :std_logic;
signal outPort_signal       :std_logic;
signal interrupt_signal     :std_logic;                           -- interrupt signal to the mux in the fetch stage --
signal do_32_memory_signal  :std_logic;                           -- signal to the memory to decide if it will read 32 bits or 16 bits --
signal do_32_fetch_signal   :std_logic;                           -- signal to the fetch to decide if it will read 32 bits or 16 bits --
signal fetch_flush_signal   :std_logic; 
signal decode_flush_signal  :std_logic; 
signal memory_flush_signal  :std_logic; 
signal WB_flush_signal      :std_logic; 
signal regFileWrite_signal  :std_logic;                      -- register file write enable --
signal imm_value_signal     :std_logic;                      -- 1 bit signals outs to fetch buffer --
signal PC_selector_signal   :std_logic_vector (2 downto 0);
signal stack_memory_signal  :std_logic;                      -- if 0 stack operations if 1 memory operations --
signal alu_selector_signal  :std_logic_vector (3 DOWNTO 0);  -- for selecting alu operation --

signal exception_selector :std_logic;

-- Decode --

-- ALU ---

signal M_out,WR_out,R_dest_address_out :std_logic_vector(2 downto 0);
signal ALU_out,R_src1_out              :std_logic_vector(15 downto 0);
signal PC_flages                       :std_logic_vector(34 downto 0);
signal branch_signal                   :std_logic;

-- Memory --

-- WB ------

begin

CU  : control_unit port map(clk,instruction(15 downto 11),immediate,exception_flag,reset);
        
ALU : ALUStage     port map(inPort,R_src1,R_src2,ALU_TO_ALU,MEM_TO_ALU,IMM_value,alu_selector_signal,memRead_signal&memWrite_signal,regFileWrite_signal,PC,R_src1_address,R_src2_address,R_dest_address,forwarding_unit_selector,reset_out_signal,C_Z_N_flags_from_stack,M_out,WR_out,R_dest_address_out,ALU_out,R_src1_out,PC_flages,branch_signal);
end architecture;