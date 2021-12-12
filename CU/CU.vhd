library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is                    
    Port (   
        ----- inputs ---------
        opcode          : in std_logic_vector(4 downto 0);
        immediate_value : in std_logic ;  -- 1 bit signal comes from fetch stage --
        exception_flag  : in std_logic_vector(1 downto 0) ;
        -- interrupt & reset --
        reset     : in std_logic;
        interrupt : in std_logic;
        ---- outputs ---------
        memRead  : out std_logic;
        memWrite : out std_logic;
        inPort   : out std_logic;
        outPort  : out std_logic;

        regFileWrite  : out std_logic;                      -- register file write enable --
        imm_value     : out std_logic;                      -- 1 bit signals outs to fetch buffer --
        PC_selector   : out std_logic_vector (1 downto 0);
        pop_push      : out std_logic_vector (1 downto 0);  -- if 0 (~pop & ~ push) if 1 (pop) if 2 (push) --
        alu_selector  : out std_logic_vector (3 DOWNTO 0);  -- for selecting alu operation --

        exception_selector : out std_logic;



        );               
end control_unit;

architecture contolUnit of control_unit is

    signal operation : integer range 0 to 24;
    -- one operand operations --
    constant NOP     : integer := 0;
    constant HLT     : integer := 1;
    constant SETC    : integer := 2;
    constant NOT_OP  : integer := 3;
    constant INC     : integer := 4;
    constant OUT_OP  : integer := 5;
    constant IN_OP   : integer := 6;
    -- two operand operations --
    constant MOV       : integer := 7;
    constant ADD       : integer := 8;
    constant SUB       : integer := 9;
    constant AND_OP    : integer := 10;
    constant IADD      : integer := 11;
    -- memory operations --
    constant PUSH   : integer := 12;
    constant POP    : integer := 13;
    constant LDM    : integer := 14;
    constant LDD    : integer := 15;
    constant STD    : integer := 16;
    -- branch and change of control operations --
    constant JZ    : integer := 17;
    constant JN    : integer := 18;
    constant JC    : integer := 19;
    constant JMP   : integer := 20;
    constant CALL  : integer := 21;
    constant RET   : integer := 22;
    constant INT   : integer := 23;
    constant RTI   : integer := 24;
    
begin
    
    operation <= to_integer(unsigned(opcode));
    

    memRead  <= '1' when (operation = LDD or operation = POP ) else '0' ;
    memWrite <= '1' when (operation = PUSH or operation = STD) else '0' ;
    inPort   <= '1' when (operation = IN_OP)  else '0';
    outPort  <= '1' when (operation = OUT_OP) else '0';

    regFileWrite <= '1' when (operation = NOT_OP or operation = INC or operation = IN_OP or operation = MOV or operation = ADD
     or operation = SUB or operation = AND_OP or operation = IADD or operation = LDM or operation = POP or operation = LDD) else '0';

    imm_value   <= immediate_value ;

    PC_selector <= "01" when (exception_flag ="01" or exception_flag = "10") else
        "10"   when (operation = RET or operation = RTI) else
        "11"   when (operation = CALL or operation = JMP) else
        "00";

    -- if pop 1 , push 2 , else 0 --
    pop_push   <= "01" when (operation = POP) else 
        "10"  when (operation = PUSH) else "00";

    alu_selector <= "0000" when (operation = SETC) else
        "0001" when (operation = NOT_OP) else
        "0010" when (operation = INC)    else
        "0011" when (operation = ADD)    else
        "0100" when (operation = LDD or operation = STD) else
        "0101" when (operation = AND_OP) else
        "0110" when (operation = IADD)   else
        "0111" when (operation = IN_OP)  else
        "1000" when (operation = JC)     else
        "1001" when (operation = JZ)     else
        "1010" when (operation = JN)     else
        "1011" when (operation = RET or operation = RTI) else
        "1100";

    exception_selector <= "0" when (exception_flag = "01") else
        "1" when (exception_flag = "10") else '0'; -- else could be 0 or 1 since the next mux will not choose the value if the exception flag = 00 --
            
    
    
end architecture;
