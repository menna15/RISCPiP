LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY
	decoder IS
	PORT (
		selector : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- select register R0:R7
		reset : IN STD_LOGIC;
		output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --out 8 signal to opene the register that selected
END ENTITY decoder;

ARCHITECTURE
	decoder_a OF decoder IS

BEGIN
	PROCESS (selector, reset)
	BEGIN
		IF (reset = '1') THEN
			output <= "00000000";
		ELSE
			CASE selector IS
				WHEN "000" => output <= "00000001";
				WHEN "001" => output <= "00000010";
				WHEN "010" => output <= "00000100";
				WHEN "011" => output <= "00001000";
				WHEN "100" => output <= "00010000";
				WHEN "101" => output <= "00100000";
				WHEN "110" => output <= "01000000";
				WHEN "111" => output <= "10000000";
				WHEN OTHERS => output <= "00000000";
			END CASE;
		END IF;
	END PROCESS;
END decoder_a;