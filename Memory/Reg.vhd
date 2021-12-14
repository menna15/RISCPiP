
Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;

-----------------REG ENTITY----------------
Entity REG is 
port( D : in std_logic_vector(31 downto 0);
      en,clk,reset : in std_logic ;
      Q : out std_logic_vector(31 downto 0));

END REG ;


ARCHITECTURE RegArc of REG is
BEGIN
process(clk,reset)
begin
if(reset='1') then
       Q<=std_logic_vector(to_unsigned(1048575,32));
   elsif (en = '1' and rising_edge(clk)) then
       Q<=D ;
end if;

end process;
END RegArc ;