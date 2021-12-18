Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;
------------------PC Register-------------------------
Entity PCounter is 
port(
DataIn : in std_logic_vector(31 downto 0);
clk,reset : in std_logic ;
DataOut : out std_logic_vector(31 downto 0));
end PCounter ;

architecture PCounterArc of PCounter is
begin
process(clk,reset)
begin
if(reset='1' and falling_edge(clk)) then
  DataOut<=std_logic_vector(to_unsigned(0,32));
elsif(falling_edge(clk)) then
   DataOut<=DataIn;
end if;
end process ;
end PCounterArc ;
