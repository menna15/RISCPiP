LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Mux4 with input 16 bit entity
ENTITY mux4 IS
    GENERIC (size : INTEGER := 16);
    PORT (
        in0, in1, in2, in3 : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
        sel0, sel1 : IN STD_LOGIC;
        out1 : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0));
END ENTITY;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Mux2 with input 16 bit entity
ENTITY mux2 IS
    GENERIC (size : INTEGER := 16);
    PORT (
        in0, in1 : IN STD_LOGIC_VECTOR(size - 1 DOWNTO 0);
        sel : IN STD_LOGIC;
        out1 : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0));

END ENTITY;
-----------------------------------------------ARCHETECTURE--------------------------------------------

--mux4 architecture using dataflow model implementation
ARCHITECTURE mux4_arc OF mux4 IS
BEGIN
    out1 <= in0 WHEN sel0 = '0' AND sel1 = '0'
        ELSE
        in1 WHEN sel0 = '1' AND sel1 = '0'
        ELSE
        in2 WHEN sel0 = '0' AND sel1 = '1'
        ELSE
        in3;
END ARCHITECTURE;

--mux2 architecture using dataflow model implementation
ARCHITECTURE mux2_arc OF mux2 IS
BEGIN
    out1 <= in0 WHEN sel = '0' ELSE
        in1;
END ARCHITECTURE;