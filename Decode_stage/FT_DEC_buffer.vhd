Library ieee;
use ieee.std_logic_1164.all;

ENTITY
fetch_decode_buffer IS
GENERIC
(n : integer := 16);
PORT (  instruction : IN std_logic_vector(n-1 DOWNTO 0); -- fetched instruction 16 bit
	clk, flush_signal, stall_signal, immediate_signal : IN std_logic;
	opcode : OUT std_logic_vector(4 DOWNTO 0); --opcode to controle unit
	reg_src_1_address, reg_src_2_address, reg_dst_address : OUT std_logic_vector(2 DOWNTO 0); --registers address
	int_index : OUT std_logic_vector(n-6 DOWNTO 0); --index for interrupt instruction
	out_immediate_signal : OUT std_logic);
END ENTITY fetch_decode_buffer;

ARCHITECTURE
fetch_decode_buffer_a OF fetch_decode_buffer IS

SIGNAL opcode_data : std_logic_vector(4 DOWNTO 0);
SIGNAL reg_src_1_address_data : std_logic_vector(2 DOWNTO 0);
SIGNAL reg_src_2_address_data : std_logic_vector(2 DOWNTO 0);
SIGNAL reg_dst_address_data : std_logic_vector(2 DOWNTO 0);
SIGNAL int_index_data : std_logic_vector(n-6 DOWNTO 0);
SIGNAL immediate_signal_data : std_logic;

BEGIN
	PROCESS(Clk)
	BEGIN
		IF (rising_edge (Clk) and flush_signal = '1') THEN
			opcode <= (opcode'RANGE => '0');
			reg_src_1_address <= (reg_src_1_address'RANGE => '0');
			reg_src_2_address <= (reg_src_2_address'RANGE => '0');
			reg_dst_address <= (reg_dst_address'RANGE => '0');
			int_index <= (int_index'RANGE => '0');
			out_immediate_signal <= '0';
-------------------------------- for save buffer data to use it in stall -------------------------
			opcode_data <= (opcode'RANGE => '0');
			reg_src_1_address_data <= (reg_src_1_address'RANGE => '0');
			reg_src_2_address_data <= (reg_src_2_address'RANGE => '0');
			reg_dst_address_data <= (reg_dst_address'RANGE => '0');
			int_index_data <= (int_index'RANGE => '0');
			immediate_signal_data <= '0';
		ELsIF (rising_edge (Clk) and stall_signal = '1') THEN
			opcode <= opcode_data;
			reg_src_1_address <= reg_src_1_address_data;
			reg_src_2_address <= reg_src_2_address_data;
			reg_dst_address <= reg_dst_address_data;
			int_index <= int_index_data;
			out_immediate_signal <= immediate_signal_data;
		ELsIF (rising_edge (Clk)) THEN
			opcode <= instruction(4 DOWNTO 0);
			reg_src_1_address <= instruction(7 DOWNTO 5);
			reg_src_2_address <= instruction(10 DOWNTO 8);
			reg_dst_address <= instruction(13 DOWNTO 11);
			int_index <= instruction(15 DOWNTO 5);
			out_immediate_signal <= immediate_signal;
-------------------------------- for save buffer data to use it in stall -------------------------
			opcode_data <= instruction(4 DOWNTO 0);
			reg_src_1_address_data <= instruction(7 DOWNTO 5);
			reg_src_2_address_data <= instruction(10 DOWNTO 8);
			reg_dst_address_data <= instruction(13 DOWNTO 11);
			int_index_data <= instruction(15 DOWNTO 5);
			immediate_signal_data <= immediate_signal;
		END IF;
	END PROCESS;
END fetch_decode_buffer_a;