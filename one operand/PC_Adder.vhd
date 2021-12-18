------------------ADDER-------------------------
Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;
ENTITY PCadder IS
	PORT (a,b,cin : IN  std_logic;
              s, cout : OUT std_logic );
END PCadder;

ARCHITECTURE PCadder_Arc OF PCadder IS
BEGIN
		
  s <= a XOR b XOR cin;
  cout <= (a AND b) OR (cin AND (a XOR b));
		
END PCAdder_Arc;
------------------------------------------------------


------------Adder for Pointer Counter----------
Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;
entity PC_adder is 
port ( A: in std_logic_vector(31 downto 0);
       F : out std_logic_vector(31 downto 0));
end  PC_adder ;
----------------------------------------------

----------------Adder---------------------
ARCHITECTURE archPC OF PC_adder IS
component  PCadder is   --Component for adder
	PORT (A,B,cin : IN  std_logic;
              s, cout : OUT std_logic );
end component;
SIGNAL temp : std_logic_vector(32 DOWNTO 0);
SIGNAL r1,B_tobe: std_logic_vector(31 DOWNTO 0);
BEGIN

B_tobe <=(0=>'1' ,others=> '0' ); --add 1.

temp(0)<='0';

loop1: FOR i IN 0 TO 31 GENERATE
        fx1: PCadder PORT MAP(A(i),B_tobe(i),temp(i),r1(i),temp(i+1));
END GENERATE;
F<= r1;
END archPC;
