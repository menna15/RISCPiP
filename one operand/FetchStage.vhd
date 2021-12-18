Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;
Entity FetchStage is 
port(
clk,reset : in std_logic ;
instruction : out std_logic_vector(15 DOWNTO 0));
end FetchStage;

Architecture FS_Arch of FetchStage is
----------------Components--------------------
----PC Reg 
component PCounter is 
port(
DataIn : in std_logic_vector(31 downto 0);
clk,reset : in std_logic ;
DataOut : out std_logic_vector(31 downto 0));
end component ;
----------

-----PC Adder
component PC_adder is 
port ( A: in std_logic_vector(31 downto 0);
       F : out std_logic_vector(31 downto 0));
end component ;
-------------
---Instruction memory
component InstMEM is 
port(                               
clk : in std_logic;               
PC : in std_logic_vector(31 downto 0);   
FetchedInstruction : out std_logic_vector(15 downto 0));
end component ;
-----------------
SIGNAL AdderIn,AdderOut,PC : std_logic_vector(31 downto 0);
Signal inst : std_logic_vector(15 downto 0);
begin
AdderIn<=PC; 
PCReg: PCounter port map(AdderOut,clk,reset,PC);
PCAdder : PC_adder port map(AdderIn,AdderOut);
memory : InstMEM port map(clk,PC,inst) ;
instruction<=inst;
end FS_Arch;
  
