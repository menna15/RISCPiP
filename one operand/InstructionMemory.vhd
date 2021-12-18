Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;

Entity InstMEM is 
port(                               
clk : in std_logic;               
PC : in std_logic_vector(31 downto 0);   
FetchedInstruction : out std_logic_vector(15 downto 0));
end InstMEM ;

architecture IMArc of InstMEM is
TYPE ram_type IS ARRAY(0 TO 1048575) of std_logic_vector(15 DOWNTO 0);
SIGNAL ram : ram_type ;
begin
 process(clk)
  begin                                                                              
    if(falling_edge(clk) and to_integer(unsigned(PC)) < 1048576 )then 
      FetchedInstruction<=ram(to_integer(unsigned(PC)));
    end if;     
  end process ;
end IMArc ;
