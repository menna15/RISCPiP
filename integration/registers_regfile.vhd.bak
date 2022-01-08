LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY
	reg_in_regfile IS
	GENERIC (n : INTEGER := 16);
	PORT (
		input : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		en, clk, reset : IN STD_LOGIC;
		output : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END ENTITY reg_in_regfile;

ARCHITECTURE
	reg_a OF reg_in_regfile IS

	SIGNAL data : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

BEGIN

	PROCESS (Clk)
	BEGIN

		IF reset = '1' THEN
			data <= (OTHERS => '0');
		ELSIF (falling_edge (Clk) AND en = '1') THEN
			data <= input;
		END IF;
	END PROCESS;
	output <= data;
END reg_a;