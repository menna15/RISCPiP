LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY DecodeStage IS
	PORT (
		reset, clk, flush_signal, stall_signal, immediate_signal, write_signal : IN STD_LOGIC;
		inst : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		write_back_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		output_src_1, output_src_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		opcode : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); --opcode to controle unit
		reg_src_1_address, reg_src_2_address, reg_dst_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --registers address
		int_index : OUT STD_LOGIC_VECTOR(10 DOWNTO 0); --index for interrupt instruction
		out_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		out_immediate_signal : OUT STD_LOGIC);

END DecodeStage;

ARCHITECTURE DS_Arch OF DecodeStage IS
	-------------Components-------------
	----Fetch-decode buffer
	COMPONENT fetch_decode_buffer IS
		PORT (
			instruction : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- fetched instruction 16 bit
			clk, flush_signal, stall_signal, immediate_signal : IN STD_LOGIC;
			opcode : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); --opcode to controle unit
			reg_src_1_address, reg_src_2_address, reg_dst_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --registers address
			int_index : OUT STD_LOGIC_VECTOR(10 DOWNTO 0); --index for interrupt instruction
			out_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- immediate value
			out_immediate_signal : OUT STD_LOGIC);
	END COMPONENT;
	-----------------------
	------register file
	COMPONENT Reg_file IS
		PORT (
			src_1_selector, src_2_selector, dst_selector : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			dst_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			write_signal, clk, reset : IN STD_LOGIC;
			output_src_1, output_src_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;
	-----------------------
	------signals
	SIGNAL src1, src2, dst : STD_LOGIC_VECTOR(2 DOWNTO 0); --registers address
	-----------------------

BEGIN
	reg_src_1_address <= src1;
	reg_src_2_address <= src2;
	reg_dst_address <= dst;
	FeDebfr : fetch_decode_buffer PORT MAP(
		inst, clk, flush_signal, stall_signal, immediate_signal, opcode, src1,
		src2, dst, int_index, out_instruction, out_immediate_signal);
	myRegFile : Reg_file PORT MAP(src1, src2, dst, write_back_data, write_signal, clk, reset, output_src_1, output_src_2);
END DS_Arch;