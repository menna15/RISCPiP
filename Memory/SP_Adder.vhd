
------------------ADDER-------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
ENTITY SPadder IS
	PORT (a,b,cin : IN  std_logic;
              s, cout : OUT std_logic );
END SPadder;

ARCHITECTURE SPadder_Arc OF SPadder IS
BEGIN
		
  s <= a XOR b XOR cin;
  cout <= (a AND b) OR (cin AND (a XOR b));
		
END SPAdder_Arc;
------------------------------------------------------


------------Adder for Stack Pointer----------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
entity SP_adder is 
port ( A: in std_logic_vector(31 downto 0);
       PopPush : std_logic_vector(1 downto 0);
       Do32 : std_logic;
       F : out std_logic_vector(31 downto 0));
end  SP_adder ;
----------------------------------------------

----------------2/-2 Adder---------------------
ARCHITECTURE arch1 OF SP_adder IS
component  SPadder is   --Component for adder
	PORT (A,B,cin : IN  std_logic;
              s, cout : OUT std_logic );
end component;
SIGNAL temp : std_logic_vector(32 DOWNTO 0);
SIGNAL r1,B_tobe: std_logic_vector(31 DOWNTO 0);
BEGIN

B_tobe <=(1 => '1' ,others=> '0' ) when (PopPush = "01" and Do32 = '1') --add 2 when popping 32 bits.
    else (0 => '1' ,others=> '0' ) when (PopPush = "01" and Do32 = '0') --add 1 //      //     //.
    else (0 => '0' ,others=> '1' ) when (PopPush = "10" and Do32 = '1') --subtract 2 when pushing 32 bits.
    else (others=> '1') when (PopPush = "10" and Do32 = '0')            --subtract 1  //     //     //.
    else (others=>'0');

temp(0)<='0';

loop1: FOR i IN 0 TO 31 GENERATE
        fx1: SPAdder PORT MAP(A(i),B_tobe(i),temp(i),r1(i),temp(i+1));
END GENERATE;
F<= r1;
END arch1;