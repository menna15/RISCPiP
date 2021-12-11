---------------------------------------------entity's decleration ------------------------------

Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--my_adder entity ( full adder 1 bit )
entity my_adder is
PORT( a,b,cin : in std_logic;
s,cout : out std_logic); 
end my_adder;

Library ieee;
use ieee.std_logic_1164.all;

--Full_adder entity ( full adder 16 bits )
entity Full_adder is   
PORT(a,b:IN std_logic_vector(15 downto 0);
cin : IN std_logic;
s:OUT std_logic_vector(15 downto 0);
carry_flag: out std_logic);
end entity;

Library ieee;
use ieee.std_logic_1164.all;

--ALUStage entity 
entity ALUProject is   
PORT(a,b:in std_logic_vector(15 downto 0);
EX : in std_logic_vector(3 downto 0);
F:out std_logic_vector(15 downto 0);
C_Z_N_flags: out std_logic_vector(2 downto 0);
flags_register_enable: out std_logic_vector(2 downto 0));
end entity;

---------------------------------------------entity's architecture ------------------------------

--my_adder architecture 
architecture a_my_adder of my_adder is
begin  
s <= a XOR b XOR cin;
cout <= (a AND b) or (cin AND (a XOR b));
end a_my_adder;



--Full_adder architecture 
architecture a_Full_adder of Full_adder is

--declare components 
component my_adder is 
port( a,b,cin : in std_logic;
s,cout : out std_logic); 
end component;


--declare wires
Signal Carries: std_logic_vector(16 downto 0);

--start combining
begin 

Carries(0)<=cin ;

loop1: for i in 0 TO 15 generate
fx: my_adder PORT MAP(a(i),b(i),Carries(i),s(i),Carries(i+1));
carry_flag<=Carries(16);
end generate ;


end a_Full_adder;


Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--partA architecture 
architecture ALUProject_arc of ALUProject is

--declare components 
component Full_adder is
PORT(a,b:IN std_logic_vector(15 downto 0);
cin : IN std_logic;
s:OUT std_logic_vector(15 downto 0);
carry_flag: out std_logic);
end component;



--declare signals 
Signal B_wire,A_wire,F_wire:std_logic_vector(15 downto 0);
Signal Cin_wire,cout :std_logic;

begin 


A_wire<= not a  when EX(3 downto 0)="0001" else
a and b when EX(3 downto 0)="0110" else 
a;


B_wire<=x"0000" when EX(3 downto 0)="0001" or EX(3 downto 0)="0110" or EX(3 downto 0)="1000" else 
std_logic_vector(signed(not b)+1) when EX(3 downto 0)="0101" else
x"0001" when EX(3 downto 0)="0010" else
b;

Cin_wire<='0';



-------------------------------------------------SET FLAGS REGISTERS ENABLE---------------------------------------------
--we put the condition of or EX(5) to enble registers in case we will take the flags from stack 
flags_register_enable(0)<='1' when EX="0000" OR EX="0010" or EX="0011" or EX="0101" or EX="0111" or EX="1100" else '0';
flags_register_enable(1)<='1' when EX="0001" or EX="0010" or EX="0011" or EX="0101" or EX="0110" or EX="0111" or EX="1100" else '0';
flags_register_enable(2)<='1' when EX="0001" or EX="0010" or EX="0011" or EX="0101" or EX="0110" or EX="0111" or EX="1100" else '0';

F_adder:Full_adder PORT MAP (A_wire,B_wire,Cin_wire,F_wire,cout);

F<=F_wire;
---------------------------------------------------------SET FLAGS------------------------------------------------------
--one case we won't get the carry from full adder when operation is SETC 
C_Z_N_flags(0)<='1' when EX="0000" else cout;
C_Z_N_flags(1)<='1' when F_wire=x"0000"  else '0';
C_Z_N_flags(2) <='1' when signed(F_wire)<0  else '0';

end architecture ;
