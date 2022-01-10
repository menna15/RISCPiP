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
                clk             : in std_logic;
                opcode          : in std_logic_vector(4 downto 0); 
                immediate_value : in std_logic ;                    -- 1 bit signal comes from fetch stage --
                exception_flag  : in std_logic_vector(1 downto 0) ; -- input from memory to seclect if exception 1 or exception 2 or no exception happened --
                load_use        : in std_logic ;                    -- 1 bit signal comes from hazard detection unit to decide if stalling would happen or not --
                branch_signal : in std_logic;
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
                alu_selector     : out std_logic_vector (4 DOWNTO 0);  -- for selecting alu operation --

                exception_selector : out std_logic  );                    -- for the selector of the mux of the exception depend on exception number from exception flag input --

        END COMPONENT;
        --- Hazard Unit component ---
        COMPONENT HazardUnit IS
        port (
        Rsrc1,Rsrc2   : in std_logic_vector (2 downto 0);   -- Rsrc1,Rsrc2 from decode/ex buffer --
        memory_signals: in std_logic_vector(3 downto 0);    --  from decode/ex buffer was pop operation or not --
        Rdest_address : in std_logic_vector(2 downto 0);    -- Rdest address from Execute/Mmemory  buffer --
        load_use      : out std_logic                       -- if 1 load use case detected else 0 --
        
            );
        END COMPONENT;
        ----Fetch stage component ---
        COMPONENT FetchStage IS
                PORT (
               -------------INPUTS--------------
              clk, reset,Do32 : IN STD_LOGIC;
              freeze_pc:IN STD_LOGIC;
	      Int_signal :IN STD_LOGIC;
              pc_selector: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
              index: IN STD_LOGIC_vECTOR(15 DOWNTO 0);
              pc_from_stack: IN STD_LOGIC_vECTOR(31 DOWNTO 0);
              pc_from_alu: IN STD_LOGIC_vECTOR(31 DOWNTO 0);
              --Signal if there is a Exp1 or Exp2 or Interupt or Reset
              Address_signal : IN STD_LOGIC_vECTOR(1 DOWNTO 0);
              ------------OUTPUTS--------------
	      pc_to_alu: OUT STD_LOGIC_vECTOR(31 DOWNTO 0);
              instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
        END COMPONENT;
        -------------------------
        ----Decode stage component
        COMPONENT DecodeStage IS
                PORT (
                        reset, clk, flush_signal, stall_signal, immediate_signal, write_signal : IN STD_LOGIC;
                        inst : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
                        write_back_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			write_back_selector:IN STD_LOGIC_VECTOR(2 DOWNTO 0);
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

                        EX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
                        M : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
                        WR : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
                        PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

                        --additional buffers for hazard detection unit

                        R_src1_address, R_src2_address, R_dest_address : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

                        --input from forwarding unit

                        forwarding_unit_selector1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
                        forwarding_unit_selector2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
                        forwarding_unit_selector3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

                        --for registers in this stage

                        clk, reset, en : IN STD_LOGIC;

                        --flags from stack in case ret operation 
                        C_Z_N_flags_from_stack : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

                        -------------------------------OUTPUTS-------------------------

                        M_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
                        WR_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
                        R_dest_address_out,R_src1_address_out,R_src2_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
                        ALU_out, R_src1_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                        PC_flages : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                        branch_signal : OUT STD_LOGIC;
                        Out_port: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
        END COMPONENT;
        -------------------------
        -- Memory buffer --------
        COMPONENT alu_memory_buffer IS
        PORT (  clk,stall_signal,flush_signal: IN std_logic;
	M_IN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        WB_IN : IN STD_LOGIC;
        R_dest_address_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_in, R_src1_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_flags_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);            --pc & flags to be pushed into memory.
        branch_signal : IN STD_LOGIC;

	M_OUT : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        WB_OUT : OUT STD_LOGIC;
	R_dest_address_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_src1_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_flags_OUT,ALU_OUT : OUT std_logic_vector(31 downto 0));    --DataIn1 carries data to be read if it is a 16-bit operation , DataIn1&DataIn2 when it is a 32-bi.
        END COMPONENT;
        -------Forwarding unit ----------
        COMPONENT FU IS
        PORT (
            R_src1_addr,R_scr2_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            clk, Imm_Signal: IN STD_LOGIC;
            WR_Mem_WB, WR_Ex_Mem: IN STD_LOGIC;
            R_dest_Mem_WB,R_dest_Ex_Mem : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            Sel1,Sel2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
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
        SIGNAL pc_mux1 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL pc_mux2 : STD_LOGIC_VECTOR (1 DOWNTO 0);
        SIGNAL stack_memory_signal : STD_LOGIC; -- if 0 stack operations if 1 memory operations --
        SIGNAL alu_selector_signal : STD_LOGIC_VECTOR (4 DOWNTO 0); -- for selecting alu operation --
        SIGNAL exception_selector : STD_LOGIC;
        SIGNAL load_use_flag : STD_LOGIC;
	SIGNAL load_use_out  : STD_LOGIC;
	SIGNAL regs_en : STD_LOGIC;
	SIGNAL pc_freeze : STD_LOGIC;
	SIGNAL stall :STD_LOGIC;

        -- Fetch --

        SIGNAL instruction: STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL pc_from_stack, pc_from_alu_extended: STD_LOGIC_vECTOR(31 DOWNTO 0);
	SIGNAL index_extended : STD_LOGIC_vECTOR(15 DOWNTO 0);
	SIGNAL pc_to_alu: STD_LOGIC_VECTOR(31 DOWNTO 0);

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

        SIGNAL R_dest_address_out,R_src1_address_out,R_src2_address_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
        SIGNAL memory_signals : STD_LOGIC_VECTOR (3 DOWNTO 0);
        SIGNAL C_Z_N_flags_from_stack : STD_LOGIC_VECTOR (2 DOWNTO 0);
        SIGNAL Mout : STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL WR_out : STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL ALU_out , R_src1_out: STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL PC_flages : STD_LOGIC_VECTOR(31 DOWNTO 0);
        SIGNAL branch_signal : STD_LOGIC;

        -- Memory --
        -- Memory buffer signals -------
        SIGNAL M_OUT  : STD_LOGIC_VECTOR(3 DOWNTO 0);
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
        SIGNAL FU_select1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL FU_select2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL FU_select3 : STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL FU_select4 : STD_LOGIC_VECTOR(1 DOWNTO 0);
        Signal Exalu_selector_signal: STD_LOGIC_VECTOR(4 DOWNTO 0);
        ------------
        -----------------------------------TEMP VARIABLIES---------------------------
        SIGNAL Temp_index : STD_LOGIC_VECTOR(15 DOWNTO 0);
        -----------------------------------TEMP VARIABLIES---------------------------

BEGIN
        index_extended<="00000" & int_index;
         Exalu_selector_signal<= "01101" when decode_flush_signal='1' else
         alu_selector_signal;
         
        pc_from_alu_extended <="0000000000000000"&R_src1_OUT_memory;
        pc_from_stack<= "000" & DO2(12 downto 0)& DO1;
        CU : control_unit PORT MAP(
                clk, opcode, immediate, exception_flag,load_use_flag,branch_signal , reset, reset_out_signal,load_use_out,regs_en,stall,
		pc_freeze, memRead_signal, memWrite_signal, inPort_signal,
                outPort_signal, interrupt_signal, do_32_memory_signal, do_32_fetch_signal, fetch_flush_signal, decode_flush_signal,
                memory_flush_signal, WB_flush_signal, regFileWrite_signal, imm_value_signal,pc_mux1,pc_mux2, stack_memory_signal,
                alu_selector_signal, exception_selector);
        
        
        regFileWrite_signal_alu(0) <= regFileWrite_signal;
        memory_signals <= stack_memory_signal&do_32_memory_signal&memRead_signal&memWrite_signal;
        
        -- will take the first two bits in PC_selector_signal  should be changed to be 2 bits
        --"00" -->  Address_signal should be 2 bits from the CU
        --"1" -->  PC_signal should be 1 bit from the CU to determine if i will take the pc or apcific address
        Fetch : FetchStage PORT MAP(clk, reset, do_32_fetch_signal,pc_freeze,interrupt_signal,pc_mux1,index_extended,pc_from_stack,pc_from_alu_extended,pc_mux2,
                                   pc_to_alu,instruction);

        hazard : HazardUnit PORT MAP(R_src1_address_out,R_src2_address_out,M_OUT, R_dest_address_OUT_memory , load_use_flag);

        Decode : DecodeStage PORT MAP(
                reset, clk, fetch_flush_signal, stall, imm_value_signal, write_back_signal_out,instruction,
                 write_back_data_out, reg_dst_address_out,R_src1, R_src2, opcode, R_src1_address, R_src2_address,
                R_dest_address, int_index, IMM_value, immediate);

        ALU : ALUStage  PORT MAP(inPort,R_src1,R_src2,ALU_OUT_memory(15 downto 0),write_back_data_out,IMM_value,Exalu_selector_signal,memory_signals,regFileWrite_signal_alu,pc_to_alu,
        R_src1_address,R_src2_address,R_dest_address,FU_select1,FU_select2,FU_select4,clk,reset_out_signal,regs_en,DO2(15 downto 13),Mout,WR_out,R_dest_address_out,R_src1_address_out,R_src2_address_out,ALU_out,R_src1_out,PC_flages,branch_signal,outPort);
        
        Memory_buffer : alu_memory_buffer PORT MAP (clk,'0',memory_flush_signal,Mout,WR_out(0),R_dest_address_out ,ALU_out, R_src1_out, 
        PC_flages, branch_signal,M_OUT,WB_OUT,R_dest_address_OUT_memory,R_src1_OUT_memory,PC_flags_OUT,ALU_OUT_memory);
        
        Memory_stage  : MEMStage  PORT MAP(M_OUT(1),M_OUT(0),reset_out_signal,M_OUT(2),clk,M_OUT(3),ALU_OUT_memory,R_src1_OUT_memory,PC_flags_OUT ,exception_flag,DO1,DO2);
        WB : memory_write_back_buffer PORT MAP(ALU_OUT_memory(15 DOWNTO 0), DO1, clk, WB_OUT, M_OUT(1), R_dest_address_OUT_memory, reg_dst_address_out, write_back_data_out, write_back_signal_out);
        Forwarding_Unit: FU PORT MAP(R_src1_address, R_src2_address, clk, imm_value_signal, WB_OUT, WR_out(0), R_dest_address_OUT_memory, R_dest_address_out, FU_select1,FU_select2);
        Forwarding_Unit_Rsrc1: FU PORT MAP(R_src1_address, R_src2_address, clk, '0', WB_OUT, WR_out(0), R_dest_address_OUT_memory, R_dest_address_out, FU_select3,FU_select4);    
        
        END ARCHITECTURE;
