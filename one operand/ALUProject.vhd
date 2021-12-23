---------------------------------------------entity's decleration ------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--my_adder entity ( full adder 1 bit )
ENTITY my_adder IS
    PORT (
        a, b, cin : IN STD_LOGIC;
        s, cout : OUT STD_LOGIC);
END my_adder;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Full_adder entity ( full adder 16 bits )
ENTITY Full_adder IS
    PORT (
        a, b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        cin : IN STD_LOGIC;
        s : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        carry_flag : OUT STD_LOGIC);
END ENTITY;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--ALUStage entity 
ENTITY ALUProject IS
    PORT (
        a, b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        EX : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        F : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        C_Z_N_flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        flags_register_enable : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ENTITY;

---------------------------------------------entity's architecture ------------------------------

--my_adder architecture 
ARCHITECTURE a_my_adder OF my_adder IS
BEGIN
    s <= a XOR b XOR cin;
    cout <= (a AND b) OR (cin AND (a XOR b));
END a_my_adder;

--Full_adder architecture 
ARCHITECTURE a_Full_adder OF Full_adder IS

    --declare components 
    COMPONENT my_adder IS
        PORT (
            a, b, cin : IN STD_LOGIC;
            s, cout : OUT STD_LOGIC);
    END COMPONENT;
    --declare wires
    SIGNAL Carries : STD_LOGIC_VECTOR(16 DOWNTO 0);

    --start combining
BEGIN

    Carries(0) <= cin;

    loop1 : FOR i IN 0 TO 15 GENERATE
        fx : my_adder PORT MAP(a(i), b(i), Carries(i), s(i), Carries(i + 1));
        carry_flag <= Carries(16);
    END GENERATE;
END a_Full_adder;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--partA architecture 
ARCHITECTURE ALUProject_arc OF ALUProject IS

    --declare components 
    COMPONENT Full_adder IS
        PORT (
            a, b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cin : IN STD_LOGIC;
            s : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            carry_flag : OUT STD_LOGIC);
    END COMPONENT;

    --declare signals 
    SIGNAL B_wire, A_wire, F_wire : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL Cin_wire, cout : STD_LOGIC;

BEGIN
    A_wire <= NOT a WHEN EX(3 DOWNTO 0) = "0001" ELSE
        a AND b WHEN EX(3 DOWNTO 0) = "0110" ELSE
        a;
    B_wire <= x"0000" WHEN EX(3 DOWNTO 0) = "0001" OR EX(3 DOWNTO 0) = "0110" OR EX(3 DOWNTO 0) = "1000" ELSE
        STD_LOGIC_VECTOR(signed(NOT b) + 1) WHEN EX(3 DOWNTO 0) = "0101" ELSE
        x"0001" WHEN EX(3 DOWNTO 0) = "0010" ELSE
        b;

    Cin_wire <= '0';

    -------------------------------------------------SET FLAGS REGISTERS ENABLE---------------------------------------------
    --we put the condition of or EX(5) to enble registers in case we will take the flags from stack 
    flags_register_enable(0) <= '1' WHEN EX = "0000" OR EX = "0010" OR EX = "0011" OR EX = "0101" OR EX = "0111" OR EX = "1100" ELSE
    '0';
    flags_register_enable(1) <= '1' WHEN EX = "0001" OR EX = "0010" OR EX = "0011" OR EX = "0101" OR EX = "0110" OR EX = "0111" OR EX = "1100" ELSE
    '0';
    flags_register_enable(2) <= '1' WHEN EX = "0001" OR EX = "0010" OR EX = "0011" OR EX = "0101" OR EX = "0110" OR EX = "0111" OR EX = "1100" ELSE
    '0';

    F_adder : Full_adder PORT MAP(A_wire, B_wire, Cin_wire, F_wire, cout);

    F <= F_wire;
    ---------------------------------------------------------SET FLAGS------------------------------------------------------
    --one case we won't get the carry from full adder when operation is SETC 
    C_Z_N_flags(0) <= '1' WHEN EX = "0000" ELSE
    cout;
    C_Z_N_flags(1) <= '1' WHEN F_wire = x"0000" ELSE
    '0';
    C_Z_N_flags(2) <= '1' WHEN signed(F_wire) < 0 ELSE
    '0';

END ARCHITECTURE;