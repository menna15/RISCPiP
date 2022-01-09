--------------------------------------------------------DECLARE ENTITIES---------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--ALU stage entity
ENTITY ALUStage IS
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

        forwarding_unit_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        --for registers in this stage

        clk, reset, en : IN STD_LOGIC;

        --flags from stack in case ret operation 
        C_Z_N_flags_from_stack : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -------------------------------OUTPUTS-------------------------

        M_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        WR_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        R_dest_address_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        ALU_out, R_src1_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        PC_flages : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_signal : OUT STD_LOGIC;
        Out_port: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY;

--------------------------------------------------------DECLARE ARCHETECTURE--------------------------------------
ARCHITECTURE ALUStage_arc OF ALUStage IS

    --declare components

    --ID/EX buffers
    COMPONENT ID_EX IS
        PORT (
            -------------declare inputs-------------

            WR : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            M : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
	    R_src1_address, R_src2_address, R_dest_address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            EX : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            in_port, R_src1, R_src2 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            PC : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            clk, reset, en : IN STD_LOGIC;
            -------------declare outputs-------------

            WR_out : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
            M_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	    R_src1_address_out, R_src2_address_out, R_dest_address_out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            EX_out : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
            in_port_out, R_src1_out, R_src2_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            PC_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
    END COMPONENT;

    --MUX4 components
    COMPONENT mux4 IS
        GENERIC (size : INTEGER := 32);
        PORT (
            in0, in1, in2, in3 : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
            sel0, sel1 : IN STD_LOGIC;
            out1 : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0));
    END COMPONENT;

    --Mux2 component
    COMPONENT mux2 IS
        GENERIC (size : INTEGER := 10);
        PORT (
            in0, in1 : IN STD_LOGIC_VECTOR(size - 1 DOWNTO 0);
            sel : IN STD_LOGIC;
            out1 : OUT STD_LOGIC_VECTOR(size - 1 DOWNTO 0));
    END COMPONENT;

    --ALU component
    COMPONENT ALUProject IS
        PORT (
            a, b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            EX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            F : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            C_Z_N_flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            flags_register_enable : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
    END COMPONENT;

    COMPONENT reg_fall_edge IS
        PORT (
            d : IN STD_LOGIC;
            clk, reset, en : IN STD_LOGIC;
            q : OUT STD_LOGIC);
    END COMPONENT;
    --declare signals

    ---------------------------------------SMALL HINT !!!-----------------------------------
    --R_scr1_address_wire,R_scr2_address_wire should be inputs for the data hazards and aoutputs from ID/FI
    --MUX_op4_wire---->is a useless wire
    ----------------------------------------------------------------------------------------

    SIGNAL IN_port_wire, R_src1_wire, R_src2_wire, ALU_TO_ALU_wire, MEM_TO_ALU_wire : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL MUX_2_out_wire, ALU_1_OP_wire, ALU_2_OP_wire : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL WR_wire : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL M_wire : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL R_src1_address_wire, R_src2_address_wire, R_dest_address_wire : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL EX_wire : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL ret_signal, inport_signal,outport_signal : STD_LOGIC;
    SIGNAL PC_wire : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL C_Z_N_flags_IN_wire, C_Z_N_flags_OUT_wire, flags_reg_enable_wire, OUT_from_flags_reg_wire : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ALU_out_or_port: STD_LOGIC_VECTOR(15 DOWNTO 0);

    ------------------------------START COMBINE THE COMPONENTS------------------
BEGIN
    ID_FI : ID_EX PORT MAP(
        WR, M, R_src1_address, R_src2_address, R_dest_address, EX, in_port, R_src1, R_src2, PC, clk, reset, en,
        WR_wire, M_wire, R_src1_address_wire, R_src2_address_wire, R_dest_address_wire, EX_wire, IN_port_wire, R_src1_wire, R_src2_wire, PC_wire);

    outport_signal <= '1' WHEN EX_wire = "01111" ELSE
        '0';
    --set ret_signal and inport depend on the EX code
    inport_signal <= '0' WHEN EX_wire = "01000" ELSE
        '1';
    ret_signal <= '0' WHEN EX_wire = "01100" ELSE
        '1';
    Mux2_ALU_OP_1 : mux2 GENERIC MAP(size => 16) PORT MAP(IN_port, R_src1_wire, inport_signal, MUX_2_out_wire);
    Mux2_flags : mux2 GENERIC MAP(size => 3) PORT MAP(C_Z_N_flags_from_stack, C_Z_N_flags_IN_wire, ret_signal, C_Z_N_flags_OUT_wire);
    Mux4_OP_1 : mux4 GENERIC MAP(size => 16) PORT MAP(MUX_2_out_wire, MEM_TO_ALU, ALU_TO_ALU, MUX_2_out_wire, forwarding_unit_selector(0), forwarding_unit_selector(1), ALU_1_OP_wire);
    Mux4_OP_2 : mux4 GENERIC MAP(size => 16) PORT MAP(R_src2_wire, MEM_TO_ALU, ALU_TO_ALU, IMM_value, forwarding_unit_selector(0), forwarding_unit_selector(1), ALU_2_OP_wire);

    ALU : ALUProject PORT MAP(ALU_1_OP_wire, ALU_2_OP_wire, EX_wire, ALU_out_or_port, C_Z_N_flags_IN_wire, flags_reg_enable_wire);

    --flag registers
    carry_reg : reg_fall_edge PORT MAP(C_Z_N_flags_OUT_wire(0), clk, reset, flags_reg_enable_wire(0), OUT_from_flags_reg_wire(0));
    zero_reg : reg_fall_edge PORT MAP(C_Z_N_flags_OUT_wire(1), clk, reset, flags_reg_enable_wire(1), OUT_from_flags_reg_wire(1));
    negative_reg : reg_fall_edge PORT MAP(C_Z_N_flags_OUT_wire(2), clk, reset, flags_reg_enable_wire(2), OUT_from_flags_reg_wire(2));

    --handle branching
    branch_signal <= '1' WHEN (EX_wire = "01001" AND OUT_from_flags_reg_wire(0) = '1') OR (EX_wire = "01010" AND OUT_from_flags_reg_wire(1) = '1') OR (EX_wire = "01011" AND OUT_from_flags_reg_wire(2) = '1') ELSE
        '0';

    --concatenate PC with Flages for the next stage

    PC_flages <= OUT_from_flags_reg_wire & PC_wire(28 downto 0);
    M_out <= M_wire;
    WR_out <= WR_wire;
    R_dest_address_out <= R_dest_address_wire;
    R_src1_out <= R_src1_wire;
    ALU_out<= ALU_out_or_port;
    Out_port<= ALU_out_or_port when  EX_wire = "01111" else
    (others=>'Z');

END ARCHITECTURE;