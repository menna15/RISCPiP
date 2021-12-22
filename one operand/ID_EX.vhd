Library ieee;
use ieee.std_logic_1164.all;

--Declare ID_EX entity
entity ID_EX is
port (
-------------declare inputs-------------

M,R_src1_address,R_src2_address,R_dest_address:in std_logic_vector (2 downto 0);
WR:in std_logic_vector(0 downto 0);
EX:in std_logic_vector (3 downto 0);
in_port,R_src1,R_src2:in std_logic_vector (15 downto 0);
PC:in std_logic_vector (31 downto 0);
clk,reset,en:in std_logic;

-------------declare outputs-------------

M_out,R_src1_address_out,R_src2_address_out,R_dest_address_out:out std_logic_vector (2 downto 0);
WR_out:out std_logic_vector(0 downto 0);
EX_out:out std_logic_vector (3 downto 0);
in_port_out,R_src1_out,R_src2_out:out std_logic_vector (15 downto 0);
PC_out:out std_logic_vector (31 downto 0));

end entity ;

--ID_EX Architecture 

architecture ID_EX_arc of ID_EX is 

--declare components

component reg is 
generic (word_length : integer := 10); 
port (d:in std_logic_vector (word_length-1 downto 0);
clk,reset,en:in std_logic;
q:out std_logic_vector (word_length-1 downto 0));
end component ;


begin 

reg_WR: reg generic map(word_length => 1) port map(WR,clk,reset, en,WR_out);
reg_M: reg generic map(word_length => 3) port map(M,clk,reset, en,M_out);
reg_EX: reg generic map (word_length => 4) port map(EX,clk,reset, en,EX_out);
reg_IN_port: reg generic map (word_length => 16) port map(IN_port,clk,reset, en,IN_port_out);
reg_R_scr1: reg generic map (word_length => 16) port map(R_src1,clk,reset,en,R_src1_out);
reg_R_scr2: reg generic map (word_length => 16) port map(R_src2,clk,reset, en,R_src2_out);
reg_R_scr1_address: reg generic map (word_length => 3) port map(R_src1_address,clk,reset, en,R_src1_address_out);
reg_R_scr2_address: reg generic map (word_length => 3) port map(R_src2_address,clk,reset, en,R_src2_address_out);
reg_R_dest_address: reg generic map (word_length => 3) port map(R_dest_address,clk,reset, en,R_dest_address_out);
reg_PC: reg generic map (word_length => 32) port map(PC,clk,reset, en,PC_out);

end architecture ;
