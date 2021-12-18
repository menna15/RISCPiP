Library ieee;
use ieee.std_logic_1164.all;

ENTITY
memory_write_back_buffer IS
GENERIC
(n : integer := 16);
PORT (  ALU_out, memory_out : IN std_logic_vector(n-1 DOWNTO 0); -- data out from alu and memory 16 bit
	clk, write_back_signal, load_from_memory_signal : IN std_logic; --load_from_memory_signal => is signal that if the instruction load data from memory or not
	reg_dst_address : IN std_logic_vector(2 DOWNTO 0);
	reg_dst_address_out : OUT std_logic_vector(2 DOWNTO 0);
	write_back_data_out : OUT std_logic_vector(n-1 DOWNTO 0);
	write_back_signal_out : OUT std_logic);
END ENTITY memory_write_back_buffer;

ARCHITECTURE
memory_write_back_buffer_a OF memory_write_back_buffer IS

BEGIN
	PROCESS(Clk)
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