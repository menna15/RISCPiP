library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is                    
    Port (   
        ----- inputs ---------
        clk             : in std_logic;
        opcode          : in std_logic_vector(4 downto 0);
        immediate_value : in std_logic ;  -- 1 bit signal comes from fetch stage --
        exception_flag  : in std_logic_vector(1 downto 0) ;
        -- reset --
        reset_in     : in std_logic;  -- from Processor --
        reset_out    : out std_logic; -- to the buffers in all stages --
        ---- outputs ---------
        memRead       : out std_logic;
        memWrite      : out std_logic;
        inPort        : out std_logic;
        outPort       : out std_logic;
        interrupt     : out std_logic;                           -- interrupt signal to the mux in the fetch stage --
        do_32_memory  : out std_logic;                           -- signal to the memory to decide if it will read 32 bits or 16 bits --
        do_32_fetch   : out std_logic;                           -- signal to the fetch to decide if it will read 32 bits or 16 bits --
        fetch_flush   : out std_logic; 
        decode_flush  : out std_logic; 
        memory_flush  : out std_logic; 
        WB_flush      : out std_logic; 
        regFileWrite  : out std_logic;                      -- register file write enable --
        imm_value     : out std_logic;                      -- 1 bit signals outs to fetch buffer --
        PC_selector   : out std_logic_vector (2 downto 0);
        stack_memory  : out std_logic;                      -- if 1 stack operations if 0 memory operations --
        alu_selector  : out std_logic_vector (3 DOWNTO 0);  -- for selecting alu operation --

        exception_selector : out std_logic



        );               
end control_unit;

architecture contolUnit of control_unit is

    signal operation   : integer range 0 to 24;
    signal temp_counter: std_logic := '0';

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
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_in = '1' then
                 temp_counter <= '1';
            else temp_counter <= '0';
            end if;
        end if;
    end process;
    
    operation <= to_integer(unsigned(opcode));
    

    memRead  <= '1' when (operation = LDD or operation = POP ) else '0' ;
    memWrite <= '1' when (operation = PUSH or operation = STD) else '0' ;
    inPort   <= '1' when (operation = IN_OP)  else '0';
    outPort  <= '1' when (operation = OUT_OP) else '0';

    regFileWrite <= '1' when (operation = NOT_OP or operation = INC or operation = IN_OP or operation = MOV or operation = ADD
     or operation = SUB or operation = AND_OP or operation = IADD or operation = LDM or operation = POP or operation = LDD) else '0';

    imm_value   <= immediate_value ;

    PC_selector <= "001" when reset_in ='1' and temp_counter = '0' else
        "010" when (exception_flag ="01" or exception_flag = "10") else
        "011" when (operation = RET or operation = RTI) else    -- get pc from the stack --
        "100" when (operation = CALL or operation = JMP) else   -- get pc from decode --
        "101" when (temp_counter = '1') else   -- get pc from decode --
        "000";

    -- if 1 stack operation , if 0 memory operation --
    stack_memory   <= '0' when (operation = RET or operation = RTI or operation= CALL or operation = INT or operation = POP or operation= PUSH) else 
    '1'  when (operation = LDD or operation = LDM or operation = STD);



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

        exception_selector <= '0' when (exception_flag = "01") else
            '1' when (exception_flag = "10") else '0'; -- else could be 0 or 1 since the next mux will not choose the value if the exception flag = 00 --
        
        do_32_memory <= '1' when (operation = CALL or operation = INT or operation = RET or operation = RTI) else '0';
        do_32_fetch  <= '1' when (operation = INT or exception_flag = "01" or exception_flag = "10" or reset_in = '1') else '0';
        fetch_flush  <= '1' when (reset_in = '1' or temp_counter = '1') else '0';
        decode_flush <= '1' when (reset_in = '1') else '0';
        memory_flush <= '1' when (reset_in = '1') else '0';
        WB_flush     <= '1' when (reset_in = '1') else '0';
        interrupt    <= '1' when (operation = INT) else '0';
            
    
    
    
end architecture;
