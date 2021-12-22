--------------------------------------------------------DECLARE ENTITIES---------------------------------
Library ieee;
use ieee.std_logic_1164.all;

--ALU stage entity
entity  ALUStage is 
PORT(
-------------------------------INPUTS-------------------------

--Muxes inputs

IN_port,R_src1,R_src2,ALU_TO_ALU,MEM_TO_ALU,IMM_value:in std_logic_vector(15 downto 0);

--EX & M & WR signals

EX :in std_logic_vector(3 downto 0);
M:in std_logic_vector(2 downto 0);
WR:in std_logic_vector(0 downto 0);
PC :in std_logic_vector(31 downto 0);

--additional buffers for hazard detection unit

R_src1_address,R_src2_address,R_dest_address :in std_logic_vector(2 downto 0);

--input from forwarding unit

forwarding_unit_selector:in std_logic_vector(1 downto 0);

--for registers in this stage

clk,reset,en:in std_logic;

--flags from stack in case ret operation 
C_Z_N_flags_from_stack:in std_logic_vector(2 downto 0);

-------------------------------OUTPUTS-------------------------

M_out:out std_logic_vector(2 downto 0);
WR_out:out std_logic_vector(0 downto 0);
R_dest_address_out:out std_logic_vector(2 downto 0);
ALU_out,R_src1_out: out std_logic_vector(15 downto 0);
PC_flages: out std_logic_vector(34 downto 0);
branch_signal:out std_logic); 
end entity;

--------------------------------------------------------DECLARE ARCHETECTURE--------------------------------------
architecture ALUStage_arc of ALUStage is 

--declare components

--ID/EX buffers
component ID_EX is
port (
-------------declare inputs-------------

WR:in std_logic_vector (0 downto 0);
M,R_src1_address,R_src2_address,R_dest_address:in std_logic_vector (2 downto 0);
EX:in std_logic_vector (3 downto 0);
in_port,R_src1,R_src2:in std_logic_vector (15 downto 0);
PC:in std_logic_vector (31 downto 0);
clk,reset,en:in std_logic;
-------------declare outputs-------------

WR_out:out std_logic_vector (0 downto 0);
M_out,R_src1_address_out,R_src2_address_out,R_dest_address_out:out std_logic_vector (2 downto 0);
EX_out:out std_logic_vector (3 downto 0);
in_port_out,R_src1_out,R_src2_out:out std_logic_vector (15 downto 0);
PC_out:out std_logic_vector (31 downto 0));
end component ;

--MUX4 components
component mux4 is
port (in0,in1,in2,in3:in std_logic_vector(15 downto 0);
sel0,sel1:in std_logic;
out1:out std_logic_vector(15 downto 0));
end component;

--Mux2 component
component mux2 is
generic (size : integer := 10);
port (in0,in1:in std_logic_vector(size-1 downto 0);
sel:in std_logic;
out1:out std_logic_vector(size-1 downto 0));
end component;

--ALU component
component ALUProject is   
PORT(a,b:in std_logic_vector(15 downto 0);
EX : in std_logic_vector(3 downto 0);
F:out std_logic_vector(15 downto 0);
C_Z_N_flags: out std_logic_vector(2 downto 0);
flags_register_enable: out std_logic_vector(2 downto 0));
end component;

component reg_fall_edge is 
port (d:in std_logic;
clk,reset,en:in std_logic;
q:out std_logic);
end component;


--declare signals

---------------------------------------SMALL HINT !!!-----------------------------------
 --R_scr1_address_wire,R_scr2_address_wire should be inputs for the data hazards and aoutputs from ID/FI
 --MUX_op4_wire---->is a useless wire
----------------------------------------------------------------------------------------

Signal IN_port_wire,R_src1_wire,R_src2_wire,ALU_TO_ALU_wire,MEM_TO_ALU_wire:std_logic_vector(15 downto 0);
Signal MUX_2_out_wire,ALU_1_OP_wire,ALU_2_OP_wire:std_logic_vector(15 downto 0);
Signal WR_wire: std_logic_vector(0 downto 0);
Signal M_wire,R_src1_address_wire,R_src2_address_wire,R_dest_address_wire: std_logic_vector(2 downto 0);
Signal EX_wire:std_logic_vector(3 downto 0);
Signal ret_signal,inport_signal:std_logic;
Signal PC_wire:std_logic_vector(31 downto 0);
Signal C_Z_N_flags_IN_wire,C_Z_N_flags_OUT_wire,flags_reg_enable_wire,OUT_from_flags_reg_wire:std_logic_vector(2 downto 0);

------------------------------START COMBINE THE COMPONENTS------------------
begin
ID_FI: ID_EX port map (WR,M,R_src1_address,R_src2_address,R_dest_address,EX,in_port,R_src1,R_src2,PC,clk,reset,en,
WR_wire,M_wire,R_src1_address_wire,R_src2_address_wire,R_dest_address_wire,EX_wire,IN_port_wire,R_src1_wire,R_src2_wire,PC_wire);

--set ret_signal and inport depend on the EX code
inport_signal<= '0' when EX="1000" else '1';
ret_signal<= '0' when EX="1100" else '1';


Mux2_ALU_OP_1: mux2 generic map(size => 16) port map (IN_port_wire,R_src1_wire,inport_signal,MUX_2_out_wire);
Mux2_flags: mux2 generic map(size => 3) port map (C_Z_N_flags_from_stack,C_Z_N_flags_IN_wire,ret_signal,C_Z_N_flags_OUT_wire);
Mux4_OP_1: mux4 port map (MUX_2_out_wire,MEM_TO_ALU_wire,ALU_TO_ALU_wire,MUX_2_out_wire,forwarding_unit_selector(0),forwarding_unit_selector(1),ALU_1_OP_wire);
Mux4_OP_2: mux4 port map (R_src2_wire,MEM_TO_ALU_wire,ALU_TO_ALU_wire,IMM_value,forwarding_unit_selector(0),forwarding_unit_selector(1),ALU_2_OP_wire);

ALU:ALUProject port map(ALU_1_OP_wire,ALU_2_OP_wire,EX_wire,ALU_out,C_Z_N_flags_IN_wire,flags_reg_enable_wire);

--flag registers
carry_reg:reg_fall_edge  port map(C_Z_N_flags_OUT_wire(0),clk,reset,flags_reg_enable_wire(0),OUT_from_flags_reg_wire(0));
zero_reg:reg_fall_edge  port map(C_Z_N_flags_OUT_wire(1),clk,reset,flags_reg_enable_wire(1),OUT_from_flags_reg_wire(1));
negative_reg:reg_fall_edge  port map(C_Z_N_flags_OUT_wire(2),clk,reset,flags_reg_enable_wire(2),OUT_from_flags_reg_wire(2)); 

--handle branching
branch_signal<= '1' when (EX="1001" and OUT_from_flags_reg_wire(0)='1') or (EX="1010" and OUT_from_flags_reg_wire(1)='1') or (EX="1011" and OUT_from_flags_reg_wire(2)='1') else '0' ;

--concatenate PC with Flages for the next stage

PC_flages <= PC & OUT_from_flags_reg_wire;
M_out<=M_wire;
WR_out<=WR_wire;
R_dest_address_out<=R_dest_address_wire;
R_src1_out<=R_src1_wire;

end architecture;


