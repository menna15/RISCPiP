library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is

port(	
    clk  :  in std_logic;
    rst  :  in std_logic;
    count:  out std_logic_vector(7 downto 0)
);
end counter;

architecture behavioral of counter is		 	  

signal temp_counter: unsigned(7 downto 0);

begin

    process(clk,rst)
    begin
	if rst = '1' then
 	    temp_counter <= X"0A";
	elsif rising_edge(clk) then
	    temp_counter <= temp_counter - 1;
	end if;
    end process;
	
    count <= std_logic_vector(temp_counter);
end behavioral;