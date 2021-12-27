LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.ALL;

ENTITY processor IS
        PORT (
                clk :IN STD_LOGIC;
                reset   :IN STD_LOGIC;
                inPort  :IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                outPort : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
END processor;

ARCHITECTURE processor_a OF processor IS

        ----------------------------------- Components --------------------------------
        COMPONENT control_unit IS
                PORT (
                        ----- inputs ---------
                        clk : IN STD_LOGIC;
                        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
                        immediate_value : IN STD_LOGIC; -- 1 bit signal comes from fetch stage --
                        exception_flag : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
                        -- reset --
                        reset_in : IN STD_LOGIC; -- from Processor --
                        reset_out : OUT STD_LOGIC; -- to the buffers in all stages --
                        ---- outputs ---------
                        memRead : OUT STD_LOGIC;
                        memWrite : OUT STD_LOGIC;
                        inPort : OUT STD_LOGIC;
                        outPort : OUT STD_LOGIC;
                        interrupt : OUT STD_LOGIC; -- interrupt signal to the mux in the fetch stage --
                        do_32_memory : OUT STD_LOGIC; -- signal to the memory to decide if it will read 32 bits or 16 bits --
                        do_32_fetch : OUT STD_LOGIC; -- signal to the fetch to decide if it will read 32 bits or 16 bits --
                        fetch_flush : OUT STD_LOGIC;
                        decode_flush : OUT STD_LOGIC;
                        memory_flush : OUT STD_LOGIC;
                        WB_flush : OUT STD_LOGIC;
                        regFileWrite : OUT STD_LOGIC; -- register file write enable --
                        imm_value : OUT STD_LOGIC; -- 1 bit signals outs to fetch buffer --
                        PC_selector : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                        stack_memory : OUT STD_LOGIC; -- if 1 stack operations if 0 memory operations --
                        alu_selector : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- for selecting alu operation --

                        exception_selector : OUT STD_LOGIC);

        END COMPONENT;
        ----Fetch stage component
        COMPONENT FetchStage IS
                PORT (
                        clk, reset : IN STD_LOGIC;
                        instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
        END COMPONENT;
        -------------------------
        ----Decode stage component
        COMPONENT DecodeStage IS
                PORT (
                        reset, clk, flush_signal, stall_signal, immediate_signal, write_signal : IN STD_LOGIC;
                        inst : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                        write_back_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                        output_src_1, output_src_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                        opcode : OUT STD_LOGIC_VECTOR(4 DOWNTO 0); --opcode to controle unit
                        reg_src_1_address, reg_src_2_address, reg_dst_address : OUT STD_LOGIC_VECTOR(2 DOWNTO 0); --registers address
                        int_index : OUT STD_LOGIC_VECTOR(10 DOWNTO 0); --index for interrupt instruction
                        out_instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- immediate value
                        out_immediate_signal : OUT STD_LOGIC);
        END COMPONENT;
        -------------------------
        ----ALU stage component
        COMPONENT ALUStage IS
                PORT (
                        -------------------------------INPUTS-------------------------

                        --Muxes inputs

                        IN_port, R_src1, R_src2, ALU_TO_ALU, MEM_TO_ALU, IMM_value : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

                        --EX & M & WR signals

                        EX : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
                        M : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                        WR : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
                        PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

                        --additional buffers for hazard detection unit

                        R_src1_address, R_src2_address, R_dest_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

                        --input from forwarding unit

                        forwarding_unit_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

                        --for registers in this stage

                        clk, reset, en : IN STD_LOGIC;

                        --flags from stack in case ret operation 
                        C_Z_N_flags_from_stack : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

                        -------------------------------OUTPUTS-------------------------

                        M_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
                        WR_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
                        R_dest_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
                        ALU_out, R_src1_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                        PC_flages : OUT STD_LOGIC_VECTOR(34 DOWNTO 0);
                        branch_signal : OUT STD_LOGIC);
        END COMPONENT;
        -------------------------
        -- Memory buffer --------
        COMPONENT alu_memory_buffer IS
        PORT (  clk,stall_signal,flush_signal: IN std_logic;
	M_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_IN : IN STD_LOGIC;
        R_dest_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_in, R_src1_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_flags_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);            --pc & flags to be pushed into memory.
        branch_signal : IN STD_LOGIC;

	M_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_OUT : OUT STD_LOGIC;
	R_dest_address_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_src1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_flags_OUT,ALU_OUT : OUT std_logic_vector(31 downto 0));    --DataIn1 carries data to be read if it is a 16-bit operation , DataIn1&DataIn2 when it is a 32-bi.
        END COMPONENT;
        -- Memory component -----
        COMPONENT MEMStage is 
        port(
        MEM_Read,MEM_Write,                                    --Read& write enables
        Reset,                                                 --Reset Signal to make SP = 2^20-1
        Do32,                                                  --Signal to determine if the operation reads/writes 16 or 32 bits
        clk,
        StackSignal: in std_logic;                             --Signal to determine is it a stack operation or memory
        ALU_out :in std_logic_vector(31 downto 0); 
        R_src1_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_flags_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  --DataOut1 carries data to be written if it is a 16-bit operation ,DataOut1&DataOut2 when it is a 32-bi.
        ExceptionFlag : out std_logic_vector(1 downto 0); 
        DO1,DO2 : OUT std_logic_vector(15 downto 0));     
        end COMPONENT ;
        ----Write Back stage component
        COMPONENT memory_write_back_buffer IS
                GENERIC (n : INTEGER := 16);
                PORT (
                        ALU_out, memory_out : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0); -- data out from alu and memory 16 bit
                        clk, write_back_signal, load_from_memory_signal : IN STD_LOGIC; --load_from_memory_signal => is signal that if the instruction load data from memory or not
                        reg_dst_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
                        reg_dst_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
                        write_back_data_out : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
                        write_back_signal_out : OUT STD_LOGIC);
        END COMPONENT;
        -------------------------

        -------------------------------------------------- signals --------------------
        -- control unit --
        SIGNAL reset_out_signal : STD_LOGIC; -- to the buffers in all stages --
        SIGNAL memRead_signal : STD_LOGIC;
        SIGNAL memWrite_signal : STD_LOGIC;
        SIGNAL inPort_signal : STD_LOGIC;
        SIGNAL outPort_signal : STD_LOGIC;
        SIGNAL interrupt_signal : STD_LOGIC; -- interrupt signal to the mux in the fetch stage --
        SIGNAL do_32_memory_signal : STD_LOGIC; -- signal to the memory to decide if it will read 32 bits or 16 bits --
        SIGNAL do_32_fetch_signal : STD_LOGIC; -- signal to the fetch to decide if it will read 32 bits or 16 bits --
        SIGNAL fetch_flush_signal : STD_LOGIC;
        SIGNAL decode_flush_signal : STD_LOGIC;
        SIGNAL memory_flush_signal : STD_LOGIC;
        SIGNAL WB_flush_signal : STD_LOGIC;
        SIGNAL regFileWrite_signal : STD_LOGIC; -- register file write enable --
        SIGNAL regFileWrite_signal_alu :STD_LOGIC_VECTOR (0 DOWNTO 0); -- register file write enable --
        SIGNAL imm_value_signal : STD_LOGIC; -- 1 bit signals outs to fetch buffer --
        SIGNAL PC_selector_signal : STD_LOGIC_VECTOR (2 DOWNTO 0);
        SIGNAL stack_memory_signal : STD_LOGIC; -- if 0 stack operations if 1 memory operations --
        SIGNAL alu_selector_signal : STD_LOGIC_VECTOR (3 DOWNTO 0); -- for selecting alu operation --
        SIGNAL exception_selector : STD_LOGIC;

        -- Fetch --

        SIGNAL instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- buffer --

        SIGNAL Fetch_stall_signal : STD_LOGIC; -- it should come from CU
        SIGNAL opcode : STD_LOGIC_VECTOR(4 DOWNTO 0); --opcode to controle unit
        SIGNAL R_src1_address, R_src2_address, R_dest_address : STD_LOGIC_VECTOR(2 DOWNTO 0); --registers address out from fetch buffer
        SIGNAL int_index : STD_LOGIC_VECTOR(10 DOWNTO 0); --index for interrupt instruction
        SIGNAL IMM_value : STD_LOGIC_VECTOR(15 DOWNTO 0); -- immediate value
        SIGNAL immediate : STD_LOGIC;

        -- Decode --

        SIGNAL R_src1, R_src2 : STD_LOGIC_VECTOR(15 DOWNTO 0); -- data come from reg file 

        -- ALU ---

        SIGNAL R_dest_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL memory_signals : STD_LOGIC_VECTOR (2 DOWNTO 0);
        SIGNAL C_Z_N_flags_from_stack : STD_LOGIC_VECTOR (2 DOWNTO 0);
        SIGNAL Mout : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL WR_out : STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL ALU_out , R_src1_out: STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL PC_flages : STD_LOGIC_VECTOR(34 DOWNTO 0);
        SIGNAL branch_signal : STD_LOGIC;

        -- Memory --
        -- Memory buffer signals -------
        SIGNAL M_OUT  : STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL WB_OUT : STD_LOGIC;
        SIGNAL R_dest_address_OUT_memory : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL R_src1_OUT_memory : STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL PC_flags_OUT, ALU_OUT_memory : std_logic_vector(31 downto 0);
        ----- Memory stage ----------------------
        SIGNAL exception_flag : STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL DO1,DO2 : std_logic_vector(15 downto 0);
        -------------------------------------------------
        -- WB ------
        SIGNAL reg_dst_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL write_back_data_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL write_back_signal_out : STD_LOGIC;
        ------------

BEGIN

        CU : control_unit PORT MAP(
                clk, opcode, immediate, exception_flag, reset, reset_out_signal, memRead_signal, memWrite_signal, inPort_signal,
                outPort_signal, interrupt_signal, do_32_memory_signal, do_32_fetch_signal, fetch_flush_signal, decode_flush_signal,
                memory_flush_signal, WB_flush_signal, regFileWrite_signal, imm_value_signal, PC_selector_signal, stack_memory_signal,
                alu_selector_signal, exception_selector);
        
        regFileWrite_signal_alu(0) <= regFileWrite_signal;
        memory_signals <= do_32_memory_signal&memRead_signal&memWrite_signal;
        Fetch : FetchStage PORT MAP(clk, reset, instruction);
        Decode : DecodeStage PORT MAP(
                reset, clk, fetch_flush_signal, '0', imm_value_signal, write_back_signal_out, instruction,
                write_back_data_out, R_src1, R_src2, opcode, R_src1_address, R_src2_address,
                R_dest_address, int_index, IMM_value, immediate);

        ALU : ALUStage  PORT MAP(inPort,R_src1,R_src2,ALU_OUT_memory(15 downto 0),DO1,IMM_value,alu_selector_signal,memory_signals,regFileWrite_signal_alu,"00000000000000000000000000000000",
        R_src1_address,R_src2_address,R_dest_address,"00",clk,reset_out_signal,'1',C_Z_N_flags_from_stack,Mout,WR_out,R_dest_address_out,ALU_out,R_src1_out,PC_flages,branch_signal);
        
        Memory_buffer : alu_memory_buffer PORT MAP (clk,'0',memory_flush_signal,Mout(1 downto 0),WR_out(0),R_dest_address_out ,ALU_out, R_src1_out, 
        PC_flages(31 downto 0), branch_signal,M_OUT ,WB_OUT,R_dest_address_OUT_memory,R_src1_OUT_memory,PC_flags_OUT,ALU_OUT_memory);
        
        Memory_stage  : MEMStage  PORT MAP(M_OUT(1),M_OUT(0),reset_out_signal,Mout(2),clk,stack_memory_signal,ALU_OUT_memory,R_src1_OUT_memory,PC_flags_OUT ,exception_flag,DO1,DO2);
        WB : memory_write_back_buffer PORT MAP(ALU_OUT_memory(15 DOWNTO 0), DO1, clk, WB_OUT, M_OUT(0), R_dest_address_OUT_memory, reg_dst_address_out, write_back_data_out, write_back_signal_out);


        outPort <= R_src1 when outPort_signal = '1' else (OTHERS =>'Z');
        END ARCHITECTURE;
