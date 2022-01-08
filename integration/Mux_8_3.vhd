LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
------------------MUX 8X3-------------------------
ENTITY Mux8 IS
  GENERIC (size : INTEGER := 32);
  PORT (
    in0, in1, in2, in3, in4, in5, in6, in7 : IN STD_LOGIC_VECTOR(size - 1 DOWNTO 0);
    sel : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    out1 : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0));
END Mux8 ;

ARCHITECTURE MUX8_Arc OF Mux8  IS
BEGIN
out1<= in0 when sel="000" else
    in1 when sel="001" else
    in2 when sel="010" else
    in3 when sel="011" else
    in4 when sel="100" else
    in5 when sel="101" else
    in6 when sel="011" else
    in7;
END MUX8_Arc;