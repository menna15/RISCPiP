library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- for detect load use case --
entity HazardUnit is
    port (
        clk           : in std_logic;
        Instruction   : in std_logic_vector (15 downto 0);-- instruction from fetch not (fetch / decode buffer) --
        load_flag     : in std_logic;                     -- load flag from control unit to decide if the previous instruction (which is in decode now ) was load operation or not --
        Rdest_address : in std_logic_vector(2 downto 0);  -- Rdest address from Decode/Execute buffer --
        load_use      : out std_logic                     -- if 1 load use case detected else 0 --

    );
    end HazardUnit; 
    -- Op code From  0  to  4 , Rsrc1 address  From  5  to  7 , Rsrc2 address From  8  to  10 --
architecture Hazard_architecture of HazardUnit is
begin
    process(clk)
    begin
        if falling_edge(clk) then
           load_use <= '1' when ((load_flag = '1') and ((Rdest_address = Instruction(7 downto 5)) or (Rdest_address = Instruction(10 DOWNTO 8)))) else '0';
           end if;
        end process;
    END Hazard_architecture; 