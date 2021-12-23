LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
------------------PC Register-------------------------
ENTITY PCounter IS
  PORT (
    DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk, reset : IN STD_LOGIC;
    DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END PCounter;

ARCHITECTURE PCounterArc OF PCounter IS
BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF (reset = '1' AND rising_edge(clk)) THEN
      DataOut <= STD_LOGIC_VECTOR(to_unsigned(0, 32));
    ELSIF (rising_edge(clk)) THEN
      DataOut <= DataIn;
    END IF;
  END PROCESS;
END PCounterArc;