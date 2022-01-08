library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is                    
    Port (   
  ----- inputs ---------
  clk             : in std_logic;
  opcode          : in std_logic_vector(4 downto 0); 
  immediate_value : in std_logic ;                    -- 1 bit signal comes from fetch stage --
  exception_flag  : in std_logic_vector(1 downto 0) ; -- input from memory to seclect if exception 1 or exception 2 or no exception happened --
  load_use        : in std_logic ;                    -- 1 bit signal comes from hazard detection unit to decide if stalling would happen or not --
  branch_signal   : in std_logic ; 
  -- reset --
  reset_in     : in std_logic;                        -- from Processor --
  ---- outputs ---------
  reset_out     : out std_logic;                       -- to the buffers in all stages --
  
  load_flag     : out std_logic;                       -- load flag is input to hazard unit to know if its load operation or not -- 
  registers_en  : out std_logic;                       -- registers enable will be 0 incase of load use (stall = 1 ) else 1.
  stall         : out std_logic;                       -- if load_use = 1 , stall signal will send to fetch/decode buffer to stall the instruction 
  pc_freeze     : out std_logic;                       -- freeze Pc incase of load use case.
  
  memRead       : out std_logic;
  memWrite      : out std_logic;
  inPort        : out std_logic;
  outPort       : out std_logic;
  interrupt     : out std_logic;                           -- interrupt signal to the mux in the fetch stage --
 ---- read 32 or 16 signals----
  do_32_memory  : out std_logic;                           -- signal to the memory to decide if it will read 32 bits or 16 bits --
  do_32_fetch   : out std_logic;                           -- signal to the fetch to decide if it will read 32 bits or 16 bits --
  -- flushing signals ----------
  fetch_flush   : out std_logic;                           -- flush signal to fetch/decode buffer incase of reset = 1 and the following cycle also because 
                                                           --  if reset = 1 reading the new value of the PC will be done in 2 cycles --
  decode_flush  : out std_logic;                           -- flush signal to decode/exec buffer incase of reset = 1 --
  memory_flush  : out std_logic;                           -- flush signal to exec/memory buffer incase of reset = 1 --
  WB_flush      : out std_logic;                           -- flush signal to memory/WB buffer incase of reset = 1 --
  
  regFileWrite_en  : out std_logic;                      -- register file write enable --
  imm_value        : out std_logic;                      -- 1 bit signals outs to fetch buffer --
  PC_mux1          : out std_logic_vector (1 downto 0);  -- selector of the mux that determine the value of PC (from stack , from ALU , memory out , default) ---
  PC_mux2          : out std_logic_vector (1 downto 0);  -- selector of the mux that determine the value of PC (M(0) "reset" , M(2) exp1 , M(4) exp2 , index+6 interrupt )---
                                                         -- third mux selector will be the signal do_32_fetch --
  stack_memory     : out std_logic;                      -- if 1 stack operations if 0 memory operations --
  alu_selector     : out std_logic_vector (3 DOWNTO 0);  -- for selecting alu operation --

  exception_selector : out std_logic                      -- for the selector of the mux of the exception depend on exception number from exception flag input --



        );               
end control_unit;

architecture contolUnit of control_unit is

    signal operation   : integer range 0 to 24;
    signal temp_R,temp_I,temp_E    : std_logic := '0';       -- temp counter for reset  , interrupt , exception that count 2 cycles --
    signal temp_RET, temp_RI       : integer range 0 to 4 := 0;   -- temp counter for return , return interrupt that count 4 cycles --
    signal temp_J,temp_C           : integer range 0 to 3 := 0;   -- temp counter for JMP    , CALL  that count 3 cycles --
    signal temp_load_use           : std_logic := '0';       -- temp counter , to count one cycle for stalling only , then stall will return to 0 --
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
    process(clk)
    begin
        if falling_edge(clk) then
            ---- reset ---------
            if reset_in = '1' and temp_R ='0' then
                 temp_R <= '1';
            else temp_R <= '0';
            end if;
            ---- Interrupt -----
            if operation = INT and temp_I ='0' then
                temp_I <= '1';
           else temp_I <= '0';
           end if;
            --- Exception ------
            if exception_flag /= "00" and temp_E ='0' then
                temp_E <= '1';
           else temp_E <= '0';
           end if;
            ---- Return --------
            if operation = RET and temp_RET = 0  then
                temp_RET <= 1;
            elsif temp_RET /= 4 and temp_RET /= 0 then
                temp_RET <= temp_RET + 1;
            else temp_RET <= 0;
            end if;
            ---- Return Interrupt --------
            if operation = RTI and temp_RI = 0  then
                temp_RI <= 1;
            elsif temp_RI /= 4 and temp_RI /= 0 then
                temp_RI <= temp_RI + 1;
            else temp_RI <= 0;
            end if;
            ----- JMP ---------------
            if operation = JMP and temp_J = 0  then
                temp_J <= 1;
            elsif temp_J /= 3 and temp_J /= 0 then
                temp_J <= temp_J + 1;
            else temp_J <= 0;
            end if;
            ----- CALL ---------------
            if operation = CALL and temp_C = 0  then
                temp_C <= 1;
            elsif temp_C /= 3 and temp_C /= 0 then
                temp_C <= temp_C + 1;
            else temp_C <= 0;
            end if;
            --- load use case ----
            if load_use = '1' and temp_load_use = '0' then
                 temp_load_use <= '1';
            else temp_load_use <= '0';
            end if;
        end if;
    end process;
    

    reset_out <= '1' when (reset_in = '1') else '0';

    memRead  <= '1' when (operation = LDD or operation = POP or operation = RET or operation = RTI ) else '0' ;
    memWrite <= '1' when (operation = PUSH or operation = STD or operation = CALL or operation = INT) else '0' ;
    inPort   <= '1' when (operation = IN_OP)  else '0';
    outPort  <= '1' when (operation = OUT_OP) else '0';

    regFileWrite_en <= '1' when (operation = NOT_OP or operation = INC or operation = IN_OP or operation = MOV or operation = ADD
     or operation = SUB or operation = AND_OP or operation = IADD or operation = LDM or operation = POP or operation = LDD) else '0';

    imm_value   <= '1' when (operation = LDD or operation = STD or operation = LDM or operation = IADD) else '0';

    PC_mux1     <= "01"  when (temp_R = '1' or temp_E = '1' or temp_I = '1') else
        "10"  when (temp_RET = 3 or temp_RI = 3)  else
        "11"  when (temp_J = 2   or temp_C = 2 or branch_signal='1' )  else
        "00";

    PC_mux2     <= "00"  when (reset_in = '1') else
        "01"  when (exception_flag = "01")  else
        "10"  when (exception_flag = "10")  else
        "11";  -- when interrupt happens and 11 is the default also because this mux won't be activated unless do 32 = 1--              
                
                    

    -- if 1 stack operation , if 0 memory operation --
    stack_memory   <= '1' when (operation = RET or operation = RTI or operation= CALL or operation = INT or operation = POP or operation= PUSH) else 
    '0'  when (operation = LDD or operation = LDM or operation = STD);



    alu_selector <= "1110" when (operation = SETC) else
        "0001" when (operation = NOT_OP) else
        "0010" when (operation = INC)    else
        "0011" when (operation = ADD)    else
        "0100" when (operation = LDD or operation = STD) else
        "0101" when (operation = SUB)    else
        "0110" when (operation = AND_OP) else
        "0111" when (operation = IADD)   else
        "1000" when (operation = IN_OP)  else
        "1001" when (operation = JC)     else
        "1010" when (operation = JZ)     else
        "1011" when (operation = JN)     else
        "1100" when (operation = RET or operation = RTI) else
        "1101";

        exception_selector <= '0' when (exception_flag = "01") else
            '1' when (exception_flag = "10") else '0'; -- else could be 0 or 1 since the next mux will not choose the value if the exception flag = 00 --
        

        pc_freeze    <= '1' when ((load_use = '1' and temp_load_use /= '1') or operation = HLT) else '0';
        stall        <= '1' when (load_use = '1' and temp_load_use /= '1') else '0';
        -- registers_en <= '0' when (load_use = '1' and temp_load_use /= '1') else '1';
        registers_en <= '1';
        --
        load_flag    <= '1' when (operation = POP ) else '0';
        do_32_memory <= '1' when (operation = CALL or operation = INT or operation = RET or operation = RTI) else '0';
        do_32_fetch  <= '1' when (operation = INT or exception_flag = "01" or exception_flag = "10" or reset_in = '1') else '0';
        fetch_flush  <= '1' when (reset_in = '1' or operation = INT or exception_flag /= "00" or temp_R = '1'or temp_I = '1' or 
                         temp_E='1' or temp_RI /= 0 or temp_RET /= 0 or temp_C /= 0 or temp_J /= 0 or  operation = HLT or branch_signal='1') else '0';
        decode_flush <= '1' when (reset_in = '1' or  branch_signal='1' or immediate_value = '1') else '0';
        memory_flush <= '1' when (reset_in = '1')  else '0';
        WB_flush     <= '1' when (reset_in = '1')  else '0';
        interrupt    <= '1' when (operation = INT) else '0';
            
end architecture;
