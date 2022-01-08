LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
------------------PC Register-------------------------
ENTITY PCounter IS
  PORT (
    DataIn : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk, reset,enable : IN STD_LOGIC;
    DataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END PCounter;

ARCHITECTURE PCounterArc OF PCounter IS
BEGIN
  PROCESS (clk, reset)
  BEGIN
    IF (rising_edge(clk) AND enable='1') THEN
      DataOut <= DataIn;
    END IF;
  END PROCESS;
END PCounterArc;