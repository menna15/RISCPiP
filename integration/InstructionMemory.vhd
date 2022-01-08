LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY InstMEM IS
  PORT (
    clk,Do32 : IN STD_LOGIC;
    PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    FetchedInstruction1,FetchedInstruction2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
);
END InstMEM;

ARCHITECTURE IMArc OF InstMEM IS
  TYPE ram_type IS ARRAY(0 TO 1048575) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL ram : ram_type;
BEGIN
  PROCESS (clk)
  BEGIN
    IF (falling_edge(clk) AND to_integer(unsigned(PC)) < 1048576 AND Do32 = '0') THEN
      FetchedInstruction1 <= ram(to_integer(unsigned(PC)));
    ELSIF(falling_edge(clk) AND to_integer(unsigned(PC)) < 1048576 AND Do32 = '1') THEN
      FetchedInstruction1 <= ram(to_integer(unsigned(PC)));
      FetchedInstruction2 <= ram(to_integer(unsigned(PC))+1);
    END IF;
  END PROCESS;
END IMArc;