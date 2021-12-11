Library ieee;
use ieee.std_logic_1164.all;

--Mux4 with input 16 bit entity
entity mux4 is
port (in0,in1,in2,in3:in std_logic_vector(15 downto 0);
sel0,sel1:in std_logic;
out1:out std_logic_vector(15 downto 0));
end entity;
Library ieee;
use ieee.std_logic_1164.all;

--Mux2 with input 16 bit entity
entity mux2 is
generic (size : integer := 10);
port (in0,in1:in std_logic_vector(size-1 downto 0);
sel:in std_logic;
out1:out std_logic_vector(size-1 downto 0));

end entity;


-----------------------------------------------ARCHETECTURE--------------------------------------------

--mux4 architecture using dataflow model implementation
architecture mux4_arc of  mux4 is 
begin 
out1<=in0 when sel0='0' and sel1='0'
else in1 when sel0='1' and sel1='0'
else in2 when sel0='0' and sel1='1'
else in3 ;
end architecture;

--mux2 architecture using dataflow model implementation
architecture mux2_arc of  mux2 is 
begin 
out1<=in0 when sel='0' else in1;
end architecture;



