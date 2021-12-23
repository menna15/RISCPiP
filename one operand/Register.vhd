
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Declare register entity

ENTITY reg IS
    GENERIC (word_length : INTEGER := 10);
    PORT (
        d : IN STD_LOGIC_VECTOR (word_length - 1 DOWNTO 0);
        clk, reset, en : IN STD_LOGIC;
        q : OUT STD_LOGIC_VECTOR (word_length - 1 DOWNTO 0));
END ENTITY;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Declare register entity

ENTITY reg_fall_edge IS
    PORT (
        d : IN STD_LOGIC;
        clk, reset, en : IN STD_LOGIC;
        q : OUT STD_LOGIC);
END ENTITY;
--register Architecture 

ARCHITECTURE reg_arc OF reg IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            q <= (OTHERS => '0');
        ELSIF rising_edge(clk) AND en = '1' THEN
            q <= d;
        END IF;
    END PROCESS;
END ARCHITECTURE;
--register work on falling edge Architecture 

ARCHITECTURE reg_fall_edge_arc OF reg_fall_edge IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            q <= '0';
        ELSIF falling_edge(clk) AND en = '1' THEN
            q <= d;
        END IF;
    END PROCESS;
END ARCHITECTURE;