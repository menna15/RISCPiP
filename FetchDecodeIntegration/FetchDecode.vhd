Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;
entity FetchDecode is 
port (
reset,clk, flush_signal, stall_signal, immediate_signal : in std_logic);
end FetchDecode ;

Architecture FE_DE_Arch of FetchDecode is 
-------------Components-------------
----Fetch stage component
Component FetchStage is 
port(
clk,reset : in std_logic ;
instruction : out std_logic_vector(15 DOWNTO 0));
end component;
-------------------------
----Fetch-decode buffer
Component fetch_decode_buffer IS
PORT (  instruction : IN std_logic_vector(15 DOWNTO 0); -- fetched instruction 16 bit
	clk, flush_signal, stall_signal, immediate_signal : IN std_logic;
	opcode : OUT std_logic_vector(4 DOWNTO 0); --opcode to controle unit
	reg_src_1_address, reg_src_2_address, reg_dst_address : OUT std_logic_vector(2 DOWNTO 0); --registers address
	int_index : OUT std_logic_vector(10 DOWNTO 0); --index for interrupt instruction
	out_immediate_signal : OUT std_logic);
end component;
-----------------------
------decoder component
Component decoder IS
PORT (  selector: IN std_logic_vector(2 DOWNTO 0); -- select register R0:R7
	reset: IN std_logic;
	output : OUT std_logic_vector(7 DOWNTO 0)); --out 8 signal to opene the register that selected
end component;
-----------------------
----------Signals----------
Signal inst : std_logic_vector(15 downto 0) ;
Signal opc : std_logic_vector(4 DOWNTO 0);
Signal src1, src2,dst : std_logic_vector(2 DOWNTO 0);
Signal intIndex : std_logic_vector(10 DOWNTO 0); 
Signal immSignal :  std_logic ;
Signal S1 , S2, Dest : std_logic_vector(7 DOWNTO 0) ;
----------------------------

begin 

myfetch  : FetchStage port map(clk,reset,inst);
FeDebfr : fetch_decode_buffer port map(inst,clk,flush_signal, stall_signal, immediate_signal,opc,src1,src2,dst,intIndex,immSignal);
mydecodeS1 : decoder port map(src1,reset,S1);
mydecodeS2 : decoder port map(src2,reset,S2);
mydecodeDest : decoder port map(dst,reset,Dest);

end FE_DE_Arch;
