Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;
entity FetchDecode is 
port (	reset, clk, flush_signal, stall_signal, immediate_signal, write_signal : IN std_logic;
	inst : IN std_logic_vector(15 downto 0);
	write_back_data : IN std_logic_vector(15 DOWNTO 0);
	output_src_1, output_src_2 : out std_logic_vector(15 DOWNTO 0);
	opcode : OUT std_logic_vector(4 DOWNTO 0); --opcode to controle unit
	reg_src_1_address, reg_src_2_address, reg_dst_address : OUT std_logic_vector(2 DOWNTO 0); --registers address
	int_index : OUT std_logic_vector(10 DOWNTO 0); --index for interrupt instruction
	out_immediate_signal : OUT std_logic);

end FetchDecode ;

Architecture FE_DE_Arch of FetchDecode is 
-------------Components-------------
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
------register file
Component Reg_file IS
PORT (  src_1_selector, src_2_selector, dst_selector 	: IN std_logic_vector(2 DOWNTO 0);
	dst_data					: IN std_logic_vector(15 DOWNTO 0);
	write_signal, clk, reset 			: IN std_logic;
	output_src_1, output_src_2 			: OUT std_logic_vector(15 DOWNTO 0));
end component;
-----------------------
------signals
signal src1, src2, dst : std_logic_vector(2 DOWNTO 0); --registers address
-----------------------

begin
	reg_src_1_address <= src1;
	reg_src_2_address <= src2;
	reg_dst_address <= dst;
	FeDebfr : fetch_decode_buffer port map(inst, clk, flush_signal, stall_signal, immediate_signal, opcode, src1,
						src2, dst, int_index, out_immediate_signal);
	myRegFile : Reg_file port map(src1, src2, dst, write_back_data, write_signal, clk, reset, output_src_1, output_src_2);
end FE_DE_Arch;
