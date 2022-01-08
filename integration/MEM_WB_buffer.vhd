LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY
	memory_write_back_buffer IS
	GENERIC (n : INTEGER := 16);
	PORT (
		ALU_out, memory_out : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- data out from alu and memory 16 bit
		clk, write_back_signal, load_from_memory_signal : IN STD_LOGIC; --load_from_memory_signal => is signal that if the instruction load data from memory or not
		reg_dst_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		reg_dst_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		write_back_data_out : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		write_back_signal_out : OUT STD_LOGIC);
END ENTITY memory_write_back_buffer;

ARCHITECTURE
	memory_write_back_buffer_a OF memory_write_back_buffer IS

BEGIN
	PROCESS (Clk)
	BEGIN
		IF (rising_edge (Clk)) THEN
			reg_dst_address_out <= reg_dst_address;
			write_back_signal_out <= write_back_signal;
			IF (load_from_memory_signal = '1') THEN
				write_back_data_out <= memory_out;
			ELSE
				write_back_data_out <= ALU_out;
			END IF;
		END IF;
	END PROCESS;
END memory_write_back_buffer_a;