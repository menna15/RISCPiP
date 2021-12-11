vsim work.alustage
add wave -position insertpoint \
/*

force -freeze sim:/alustage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/alustage/IN_port 16#0000
force -freeze sim:/alustage/R_src1 16#0001
force -freeze sim:/alustage/R_src2 16#1230
force -freeze sim:/alustage/ALU_TO_ALU 16#0000
force -freeze sim:/alustage/MEM_TO_ALU 16#0000
force -freeze sim:/alustage/IMM_value 16#0000
force -freeze sim:/alustage/EX 0011 
force -freeze sim:/alustage/M 000 
force -freeze sim:/alustage/WR 000 
force -freeze sim:/alustage/PC 16#01010101
force -freeze sim:/alustage/R_src1_address 000 
force -freeze sim:/alustage/R_src2_address 000 
force -freeze sim:/alustage/R_dest_address 000 
force -freeze sim:/alustage/forwarding_unit_selector 00 
force -freeze sim:/alustage/reset 0 
force -freeze sim:/alustage/en 1 
force -freeze sim:/alustage/C_Z_N_flags_from_stack 000 
run


