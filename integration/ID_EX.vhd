LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--Declare ID_EX entity
ENTITY ID_EX IS
    PORT (
        -------------declare inputs-------------

        M : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	R_src1_address, R_src2_address, R_dest_address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        WR : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        EX : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        in_port, R_src1, R_src2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        PC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        clk, reset, en : IN STD_LOGIC;

        -------------declare outputs-------------

        M_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	R_src1_address_out, R_src2_address_out, R_dest_address_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        WR_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        EX_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        in_port_out, R_src1_out, R_src2_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        PC_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));

END ENTITY;

--ID_EX Architecture 

ARCHITECTURE ID_EX_arc OF ID_EX IS

    --declare components

    COMPONENT reg IS
        GENERIC (word_length : INTEGER := 10);
        PORT (
            d : IN STD_LOGIC_VECTOR (word_length - 1 DOWNTO 0);
            clk, reset, en : IN STD_LOGIC;
            q : OUT STD_LOGIC_VECTOR (word_length - 1 DOWNTO 0));
    END COMPONENT;
BEGIN

    reg_WR : reg GENERIC MAP(word_length => 1) PORT MAP(WR, clk, reset, en, WR_out);
    reg_M : reg GENERIC MAP(word_length => 4) PORT MAP(M, clk, reset, en, M_out);
    reg_EX : reg GENERIC MAP(word_length => 5) PORT MAP(EX, clk, reset, en, EX_out);
    reg_IN_port : reg GENERIC MAP(word_length => 16) PORT MAP(IN_port, clk, reset, en, IN_port_out);
    reg_R_scr1 : reg GENERIC MAP(word_length => 16) PORT MAP(R_src1, clk, reset, en, R_src1_out);
    reg_R_scr2 : reg GENERIC MAP(word_length => 16) PORT MAP(R_src2, clk, reset, en, R_src2_out);
    reg_R_scr1_address : reg GENERIC MAP(word_length => 3) PORT MAP(R_src1_address, clk, reset, en, R_src1_address_out);
    reg_R_scr2_address : reg GENERIC MAP(word_length => 3) PORT MAP(R_src2_address, clk, reset, en, R_src2_address_out);
    reg_R_dest_address : reg GENERIC MAP(word_length => 3) PORT MAP(R_dest_address, clk, reset, en, R_dest_address_out);
    reg_PC : reg GENERIC MAP(word_length => 32) PORT MAP(PC, clk, reset, en, PC_out);

END ARCHITECTURE;