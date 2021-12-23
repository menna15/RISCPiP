LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY InstMEM IS
  PORT (
    clk : IN STD_LOGIC;
    PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    FetchedInstruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END InstMEM;

ARCHITECTURE IMArc OF InstMEM IS
  TYPE ram_type IS ARRAY(0 TO 1048575) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ram : ram_type;
BEGIN
  PROCESS (clk)
  BEGIN
    IF (falling_edge(clk) AND to_integer(unsigned(PC)) < 1048576) THEN
      FetchedInstruction <= ram(to_integer(unsigned(PC)));
    END IF;
  END PROCESS;
END IMArc;