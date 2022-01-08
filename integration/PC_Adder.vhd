------------------ADDER-------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY PCadder IS
  PORT (
    a, b, cin : IN STD_LOGIC;
    s, cout : OUT STD_LOGIC);
END PCadder;

ARCHITECTURE PCadder_Arc OF PCadder IS
BEGIN

  s <= a XOR b XOR cin;
  cout <= (a AND b) OR (cin AND (a XOR b));

END PCAdder_Arc;
------------------------------------------------------
------------Adder for Pointer Counter----------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY PC_adder IS
  PORT (
    A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END PC_adder;
----------------------------------------------

----------------Adder---------------------
ARCHITECTURE archPC OF PC_adder IS
  COMPONENT PCadder IS --Component for adder
    PORT (
      A, B, cin : IN STD_LOGIC;
      s, cout : OUT STD_LOGIC);
  END COMPONENT;
  SIGNAL temp : STD_LOGIC_VECTOR(32 DOWNTO 0);
  SIGNAL r1, B_tobe : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

  B_tobe <= (0 => '1', OTHERS => '0'); --add 1.

  temp(0) <= '0';

  loop1 : FOR i IN 0 TO 31 GENERATE
    fx1 : PCadder PORT MAP(A(i), B_tobe(i), temp(i), r1(i), temp(i + 1));
  END GENERATE;
  F <= r1;
END archPC;