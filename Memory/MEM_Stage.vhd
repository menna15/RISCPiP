Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;

Entity MEMStage is 
port(
MEM_Read,MEM_Write,                                    --Read& write enables
Reset,                                                 --Reset Signal to make SP = 2^20-1
Do32,                                                  --Signal to determine if the operation reads/writes 16 or 32 bits
clk,
StackSignal: in std_logic;                             --Signal to determine is it a stack operation or memory
DataIn1,DataIn2 : in std_logic_vector(15 downto 0);    --DataIn1 carries data to be read if it is a 16-bit operation , DataIn1&DataIn2 when it is a 32-bi.
ALU_out :in std_logic_vector(31 downto 0); 
DataOut1,DataOut2 : out std_logic_vector(15 downto 0); --DataOut1 carries data to be written if it is a 16-bit operation ,DataOut1&DataOut2 when it is a 32-bi.
ExceptionFlag : out std_logic_vector(1 downto 0));   
end MEMStage ;

architecture MEMStageArc of MEMStage is
---------------Components---------------

----StackPointer Register Compoonent-----
Component REG is 
port( D : in std_logic_vector(31 downto 0);
      en,clk,reset : in std_logic ;
      Q : out std_logic_vector(31 downto 0));

END COMPONENT ;
--------------StackPointer Adder-------------
COMPONENT SP_adder is 
port ( A: in std_logic_vector(31 downto 0);
       PopPush : std_logic_vector(1 downto 0);
       Do32 : std_logic ;
       F : out std_logic_vector(31 downto 0));
end  COMPONENT ;
---------------------MEMORY----------------------
COMPONENT MEM is 
port(
MEM_Read,MEM_Write,Do32,clk,StackSignal: in std_logic ;                           
Address : in std_logic_vector(31 downto 0);   
DataIn1,DataIn2 : in std_logic_vector(15 downto 0); 
DataOut1,DataOut2 : out std_logic_vector(15 downto 0);   
ExceptionFlag : out std_logic_vector(1 downto 0));  
end COMPONENT ;
--------------------------------------------------

---------------------Signals----------------------
SIGNAL DOut1,DOut2 : std_logic_vector(15 downto 0);
SIGNAL SP_OLD,SP_NEW,Address,AdderIn,AdderOut : std_logic_vector(31 downto 0);
SIGNAL AdderSignal,EXP : std_logic_vector(1 downto 0);
--------------------------------------------------
begin
AdderSignal<=  "01" when (StackSignal='1' and MEM_Read='1')
          else "10" when (StackSignal='1' and MEM_Write='1')
          else "00" ;

AdderIn<=SP_NEW;
AdderComp : SP_adder port map(AdderIn,AdderSignal,Do32,AdderOut);
SP : REG port map(AdderOut,StackSignal,clk,Reset,SP_NEW);

Address <= SP_OLD when (StackSignal = '1' and MEM_Write='1')
      else AdderOut when (StackSignal = '1' and MEM_Read='1')
      else ALU_out when StackSignal = '0' ;

Memory : MEM port map(MEM_Read,MEM_Write,Do32,clk,StackSignal,Address,DataIn1,DataIn2,DOut1,DOut2,EXP);
DataOut1<=DOut1;
DataOut2<=DOut2;
ExceptionFlag <= EXP;
process(CLK)
begin
if(falling_edge(CLK)) then
  SP_OLD<=SP_NEW;
  end if;
end process;
end MEMStageArc ;
