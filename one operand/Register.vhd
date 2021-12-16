
Library ieee;
use ieee.std_logic_1164.all;

--Declare register entity
 
entity reg is 
generic (word_length : integer := 10); 
port (d:in std_logic_vector (word_length-1 downto 0);
clk,reset,en:in std_logic;
q:out std_logic_vector (word_length-1 downto 0));
end entity ;

Library ieee;
use ieee.std_logic_1164.all;

--Declare register entity
 
entity reg_fall_edge is 
port (d:in std_logic;
clk,reset,en:in std_logic;
q:out std_logic);
end entity ;


--register Architecture 

architecture reg_arc of reg is 
begin 
process(clk,reset)
begin
if(reset = '1') then
    q <=(others =>'0');
elsif rising_edge(clk) and en='1'  then    
     q <= d;
end if;
end process;
end architecture ;


--register work on falling edge Architecture 

architecture reg_fall_edge_arc of reg_fall_edge is 
begin 
process(clk,reset)
begin
if(reset = '1') then
    q <='0';
elsif falling_edge(clk) and en='1'  then    
     q <= d;
end if;
end process;
end architecture ;


