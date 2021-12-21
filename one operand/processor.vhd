library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity processor is                    
    Port (   
          clk   : std_logic;
          reset : std_logic;
          exception_flag   : std_logic_vector(1 downto 0); -- added as input untill memory stage be ready then will be taken as input from it --
          inPort           : std_logic_vector(15 downto 0); -- added as input untill decode stage be ready then will be taken as input from it --
  
          ALU_TO_ALU,MEM_TO_ALU :std_logic_vector(15 downto 0); -- added as input untill forwarding unit be ready then will be taken as input from buffers --
          PC  : std_logic_vector(31 downto 0);                  -- added as input untill fetch stage be ready then will be taken as input from it - / -- it will still input till next phase 
          
	  forwarding_unit_selector:in std_logic_vector(1 downto 0); -- added as input untill forwarding unit be ready then will be taken as input from it --
          C_Z_N_flags_from_stack  :in std_logic_vector(2 downto 0) -- added as input untill memory stage be ready then will be taken as input from it --
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
----Fetch stage component
component FetchStage is 
	port(
	clk,reset : in std_logic ;
	instruction : out std_logic_vector(15 DOWNTO 0));
end component;
-------------------------
----Decode stage component
component DecodeStage is 
port (	reset, clk, flush_signal, stall_signal, imm_value, write_signal : IN std_logic;
	inst : IN std_logic_vector(15 DOWNTO 0);
	write_back_data : IN std_logic_vector(15 DOWNTO 0);
	output_src_1, output_src_2 : out std_logic_vector(15 DOWNTO 0);
	opcode : OUT std_logic_vector(4 DOWNTO 0); --opcode to controle unit
	reg_src_1_address, reg_src_2_address, reg_dst_address : OUT std_logic_vector(2 DOWNTO 0); --registers address
	int_index : OUT std_logic_vector(10 DOWNTO 0); --index for interrupt instruction
	out_instruction : OUT std_logic_vector(15 DOWNTO 0); -- immediate value
	out_immediate_signal : OUT std_logic);
end Component;
-------------------------
----ALU stage component
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
-------------------------
----write back stage component
component memory_write_back_buffer IS
GENERIC
(n : integer := 16);
PORT (  ALU_out, memory_out : IN std_logic_vector(n-1 DOWNTO 0); -- data come from alu and memory 16 bit
	clk, write_back_signal, load_from_memory_signal : IN std_logic; --load_from_memory_signal => is signal that if the instruction load data from memory or not
	reg_dst_address : IN std_logic_vector(2 DOWNTO 0);
	reg_dst_address_out : OUT std_logic_vector(2 DOWNTO 0);
	write_back_data_out : OUT std_logic_vector(n-1 DOWNTO 0);
	write_back_signal_out : OUT std_logic);
END component;
-------------------------

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

-- Fetch --

signal instruction 			: std_logic_vector(15 downto 0);

-- buffer --

signal Fetch_stall_signal		: std_logic; -- it should come from CU
signal opcode 				: std_logic_vector(4 DOWNTO 0); --opcode to controle unit
signal R_src1_address, R_src2_address, R_dest_address : std_logic_vector(2 DOWNTO 0); --registers address out from fetch buffer
signal int_index 			: std_logic_vector(10 DOWNTO 0); --index for interrupt instruction
signal IMM_value 			: std_logic_vector(15 DOWNTO 0); -- immediate value
signal immediate 			: std_logic;

-- Decode --

signal write_signal			: std_logic; -- it should come from write back stage
signal write_back_data 			: std_logic_vector(15 DOWNTO 0); -- it should come from write back stage
signal R_src1, R_src2 			: std_logic_vector(15 DOWNTO 0); -- data come from reg file 

-- ALU ---

signal M_out,WR_out,R_dest_address_out :std_logic_vector(2 downto 0);
signal ALU_out,R_src1_out              :std_logic_vector(15 downto 0);
signal PC_flages                       :std_logic_vector(34 downto 0);
signal branch_signal                   :std_logic;

-- Memory --

-- WB ------
-- to be continue
--signal ALU_out, memory_out : std_logic_vector(15 DOWNTO 0); -- data come from alu and memory 16 bit
--signal clk, write_back_signal, load_from_memory_signal : std_logic; --load_from_memory_signal => is signal that if the instruction load data from memory or not
--signal reg_dst_address : std_logic_vector(2 DOWNTO 0);
--signal reg_dst_address_out : std_logic_vector(2 DOWNTO 0);
--signal write_back_data_out : std_logic_vector(15 DOWNTO 0);
--signal write_back_signal_out : std_logic;
------------

begin

CU    : control_unit port map(clk,opcode,immediate,exception_flag,reset,reset_out_signal,memRead_signal,memWrite_signal,inPort_signal,
                              outPort_signal,interrupt_signal,do_32_memory_signal,do_32_fetch_signal,fetch_flush_signal,decode_flush_signal,
                              memory_flush_signal,WB_flush_signal,regFileWrite_signal,imm_value_signal,PC_selector_signal,stack_memory_signal,
                              alu_selector_signal,exception_selector);

Fetch : FetchStage port map(clk,reset,instruction); 
Decode: DecodeStage port map(reset, clk, fetch_flush_signal, Fetch_stall_signal, imm_value_signal, write_signal, instruction,
				write_back_data, R_src1, R_src2, opcode, R_src1_address, R_src2_address,
				R_dest_address, int_index, IMM_value, immediate);
--ALU : ALUStage     port map(inPort,R_src1,R_src2,ALU_TO_ALU,MEM_TO_ALU,IMM_value,alu_selector_signal,memRead_signal&memWrite_signal,regFileWrite_signal,PC,R_src1_address,R_src2_address,R_dest_address,forwarding_unit_selector,reset_out_signal,C_Z_N_flags_from_stack,M_out,WR_out,R_dest_address_out,ALU_out,R_src1_out,PC_flages,branch_signal);
end architecture;