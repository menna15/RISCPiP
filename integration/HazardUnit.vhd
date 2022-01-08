library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- for detect load use case --
entity HazardUnit is
    port (
        Rsrc1,Rsrc2   : in std_logic_vector (2 downto 0);   -- Rsrc1,Rsrc2 from decode/ex buffer --
        memory_signals: in std_logic_vector(3 downto 0);    --  from decode/ex buffer was pop operation or not --
        Rdest_address : in std_logic_vector(2 downto 0);    -- Rdest address from Execute/Mmemory  buffer --
        load_use      : out std_logic                       -- if 1 load use case detected else 0 --

    );
    end HazardUnit; 
    -- Op code From  0  to  4 , Rsrc1 address  From  5  to  7 , Rsrc2 address From  8  to  10 --
architecture Hazard_architecture of HazardUnit is
begin

    load_use <= '1' when (memory_signals(1) = '1' and memory_signals(3) = '1' and ((Rdest_address = Rsrc1) or (Rdest_address = Rsrc2))) else
        '0';

    END Hazard_architecture; 