

Library ieee;
use ieee.std_logic_1164.all;

ENTITY
alu_memory_buffer IS
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
END ENTITY alu_memory_buffer;

ARCHITECTURE
alu_memory_buffer_a OF alu_memory_buffer IS
SIGNAL WB_data : std_logic;
SIGNAL M_data : std_logic_vector(1 DOWNTO 0);
SIGNAL R_dest_address_data : std_logic_vector(2 DOWNTO 0);
SIGNAL R_src1_data : std_logic_vector(15 DOWNTO 0);
SIGNAL ALU_data,PC_flags_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
	PROCESS(Clk)
	BEGIN
		IF (falling_edge (Clk) and stall_signal = '1') THEN
			WB_out<=WB_data;
			M_out<= M_data;
			R_dest_address_OUT <=R_dest_address_data;
			R_src1_OUT<=R_src1_data;
			ALU_OUT<=ALU_data;
			PC_flags_OUT<=PC_flags_data;
		ELSIF(falling_edge (Clk) and flush_signal = '1') THEN
			WB_out<='0';
			M_out <= "00";
			R_dest_address_OUT <= "000";
			R_src1_OUT<="0000000000000000";
			ALU_OUT<="00000000000000000000000000000000";
			PC_flags_OUT<="00000000000000000000000000000000";
		ELsIF (falling_edge (Clk)) THEN
			WB_out<=WB_in;
			M_out <= M_in;
			R_dest_address_OUT <=R_dest_address_in;
			R_src1_OUT<=R_src1_in;
			ALU_OUT<="0000000000000000" & ALU_in;
			PC_flags_OUT<=PC_flags_in;
-------------------------------- for save buffer data to use it in stall -------------------------
			WB_data<=WB_in;
			M_data<= M_in;
			R_dest_address_data <=R_dest_address_in;
			R_src1_data<=R_src1_in;
			ALU_data<="0000000000000000" & ALU_in;
			PC_flags_data<=PC_flags_in;
		END IF;
	END PROCESS;
END alu_memory_buffer_a;