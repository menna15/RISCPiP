Library ieee;
use ieee.std_logic_1164.all;

ENTITY
reg IS
GENERIC
(n : integer := 16);
PORT (  input: IN std_logic_vector(n-1 DOWNTO 0);
	en, clk, reset : IN std_logic;
	output : OUT std_logic_vector(n-1 DOWNTO 0));
END ENTITY reg;

ARCHITECTURE
reg_a OF reg IS

SIGNAL data : std_logic_vector(n-1 DOWNTO 0);

BEGIN

	PROCESS(Clk)
	BEGIN
	
		IF reset = '1' THEN
			data <= (OTHERS =>'0');
		ELSIF (falling_edge (Clk) and en = '1') THEN
			data <= input;
		END IF;
	END PROCESS;
	output <= data;
END reg_a;
