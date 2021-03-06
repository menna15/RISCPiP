
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY
	Reg_file IS
	PORT (
		src_1_selector, src_2_selector, dst_selector : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		dst_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		write_signal, clk, reset : IN STD_LOGIC;
		output_src_1, output_src_2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END ENTITY Reg_file;

ARCHITECTURE
	Reg_file_a OF Reg_file IS
	-----------------------------------------------components-----------------------------------------
	COMPONENT reg_in_regfile IS
		PORT (
			input : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			en, clk, reset : IN STD_LOGIC;
			output : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	END COMPONENT;

	COMPONENT decoder IS
		PORT (
			selector : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- select register R0:R7
			reset : IN STD_LOGIC;
			output : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
	-----------------------------------------------components-----------------------------------------

	SIGNAL reg0_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg1_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg2_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg3_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg4_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg5_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg6_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL reg7_data : STD_LOGIC_VECTOR(15 DOWNTO 0);

	SIGNAL destination_decode : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL destination_decode_and_write_signal : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL src_1_decode : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL src_2_decode : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
	reg0 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(0), clk, reset, reg0_data);
	reg1 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(1), clk, reset, reg1_data);
	reg2 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(2), clk, reset, reg2_data);
	reg3 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(3), clk, reset, reg3_data);
	reg4 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(4), clk, reset, reg4_data);
	reg5 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(5), clk, reset, reg5_data);
	reg6 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(6), clk, reset, reg6_data);
	reg7 : reg_in_regfile PORT MAP(dst_data, destination_decode_and_write_signal(7), clk, reset, reg7_data);
	src_1_decoder : decoder PORT MAP(src_1_selector, reset, src_1_decode);
	src_2_decoder : decoder PORT MAP(src_2_selector, reset, src_2_decode);
	dst_decoder : decoder PORT MAP(dst_selector, reset, destination_decode);

	destination_decode_and_write_signal <= destination_decode AND (destination_decode'RANGE => write_signal);

	output_src_1 <= reg0_data WHEN src_1_decode(0) = '1'
		ELSE
		reg1_data WHEN src_1_decode(1) = '1'
		ELSE
		reg2_data WHEN src_1_decode(2) = '1'
		ELSE
		reg3_data WHEN src_1_decode(3) = '1'
		ELSE
		reg4_data WHEN src_1_decode(4) = '1'
		ELSE
		reg5_data WHEN src_1_decode(5) = '1'
		ELSE
		reg6_data WHEN src_1_decode(6) = '1'
		ELSE
		reg7_data WHEN src_1_decode(7) = '1'
		ELSE
		(OTHERS => 'Z');

	output_src_2 <= reg0_data WHEN src_2_decode(0) = '1'
		ELSE
		reg1_data WHEN src_2_decode(1) = '1'
		ELSE
		reg2_data WHEN src_2_decode(2) = '1'
		ELSE
		reg3_data WHEN src_2_decode(3) = '1'
		ELSE
		reg4_data WHEN src_2_decode(4) = '1'
		ELSE
		reg5_data WHEN src_2_decode(5) = '1'
		ELSE
		reg6_data WHEN src_2_decode(6) = '1'
		ELSE
		reg7_data WHEN src_2_decode(7) = '1'
		ELSE
		(OTHERS => 'Z');

END Reg_file_a;