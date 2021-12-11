# RISCPiP
RISC Piplined Processor
# ALU STAGE IMPORTANT NOTES !!! 
M-->Memory signal from the control unit is 3 bits (can be modified)\
WR-->Writeback signal from the control unit is 3 bits (can be modified)\
Ex-->Execution signal from the control unit is 4 bits (can be modified)
# Execution Signals excpected to be as follow:
SETC     -->0\
NOT      -->1\
INC      -->2\
ADD      -->3\
LDD,STD  -->4\
AND      -->5\
IADD     -->6\
IN       -->7\
JC       -->8\
JZ       -->9\
JN       -->10\
RET      -->11\
others   -->12

# other important signals
branch_signal --> will send to the control unit in case of branching

# side notes
i consider that INC affect carry flag but the TA doesn't say that exceplicitly in the document 
# INPUTS
IN_port,R_src1,R_src2,ALU_TO_ALU,MEM_TO_ALU,IMM_value:in std_logic_vector(15 downto 0)

--EX & M & WR signals

EX :in std_logic_vector(3 downto 0)
M,WR:in std_logic_vector(2 downto 0)
PC :in std_logic_vector(31 downto 0)

--additional buffers for hazard detection unit

R_src1_address,R_src2_address,R_dest_address :in std_logic_vector(2 downto 0)

--input from forwarding unit

forwarding_unit_selector:in std_logic_vector(1 downto 0)

--for registers in this stage

clk,reset,en:in std_logic

--flags from stack in case ret operation 
C_Z_N_flags_from_stack:in std_logic_vector(2 downto 0)

# OUTPUTS\

M_out,WR_out,R_dest_address_out:out std_logic_vector(2 downto 0)\
ALU_out,R_src1_out: out std_logic_vector(15 downto 0)\
PC_flages: out std_logic_vector(34 downto 0)\
branch_signal:out std_logic)






