Library ieee;
use ieee.std_logic_1164.all;
use  IEEE.numeric_std.all;

Entity MEM is 
port(
MEM_Read,MEM_Write,                                    --Read& Write enables
Do32,                                                  --Signal to determine if the operation reads/writes 16 or 32 bits
clk,
StackSignal: in std_logic ;                            --Signal to determine is it a stack operation or memory
Address : in std_logic_vector(31 downto 0);   
DataIn1,DataIn2 : in std_logic_vector(15 downto 0);    --DataIn1 carries data to be read if it is a 16-bit operation , DataIn1&DataIn2 when it is a 32-bi.
DataOut1,DataOut2 : out std_logic_vector(15 downto 0); --DataOut1 carries data to be written if it is a 16-bit operation ,DataOut1&DataOut2 when it is a 32-bi.
ExceptionFlag : out std_logic_vector(1 downto 0));     --
end MEM ;

architecture MEMArc of MEM is
TYPE ram_type IS ARRAY(0 TO 1048575) of std_logic_vector(15 DOWNTO 0);
SIGNAL ram : ram_type ;
begin
process(clk)
begin                                                                              --Throughs an exception when:
if(rising_edge(clk) and  to_integer(unsigned(Address)) > 65280 and StackSignal='0')then --Address out of memory range. 
ExceptionFlag<="01";
elsif (rising_edge(clk) and to_integer(unsigned(Address)) > 1048575 and StackSignal='1' and MEM_Read ='1')then --Pop an empty stack.
ExceptionFlag<="10";
else 
   ExceptionFlag<="00";
   if(rising_edge(clk) and MEM_Write='1' and Do32 ='0') then 
   ram(to_integer(unsigned(Address)))<=DataIn1;
   
  elsif(rising_edge(clk) and MEM_Write='1' and Do32 ='1') then
   ram(to_integer(unsigned(Address)))<=DataIn1;         --Push first 16-bit data in the lower address in stack   | DataIn2 | Address-1
   ram(to_integer(unsigned(Address))-1)<=DataIn2;       --Push second 16-bit data in the upper address in stack  | DataIn1 | Address
   end if;                                                 --                                                    |_________|

   if (rising_edge(clk) and MEM_Read='1' and Do32 ='0' ) then 
     DataOut1<=ram(to_integer(unsigned(Address)));
  elsif (rising_edge(clk) and MEM_Read='1' and Do32 ='1') then
    DataOut1<=ram(to_integer(unsigned(Address))) ;   --Pop data in the lower address in stack to be DataOut1   | DataOut2 | Address-1
    DataOut2<=ram(to_integer(unsigned(Address))-1);  --Pop data in the Upper address in stack to be DataOut2   | DataOut1 | Adderss
  end if;                                              --                                                      |__________|     
end if;     
end process ;
end MEMArc ;
