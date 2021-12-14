vsim work.control_unit
# vsim work.control_unit 
# Start time: 21:15:08 on Dec 14,2021
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.control_unit(contolunit)
add wave -position insertpoint  \
sim:/control_unit/clk \
sim:/control_unit/opcode \
sim:/control_unit/immediate_value \
sim:/control_unit/exception_flag \
sim:/control_unit/reset_in \
sim:/control_unit/reset_out \
sim:/control_unit/memRead \
sim:/control_unit/memWrite \
sim:/control_unit/inPort \
sim:/control_unit/outPort \
sim:/control_unit/interrupt \
sim:/control_unit/do_32_memory \
sim:/control_unit/do_32_fetch \
sim:/control_unit/fetch_flush \
sim:/control_unit/decode_flush \
sim:/control_unit/memory_flush \
sim:/control_unit/WB_flush \
sim:/control_unit/regFileWrite \
sim:/control_unit/imm_value \
sim:/control_unit/PC_selector \
sim:/control_unit/stack_memory \
sim:/control_unit/alu_selector \
sim:/control_unit/exception_selector
force -freeze sim:/control_unit/clk 1 0, 0 {50 ps} -r 100
add wave -position insertpoint  \
sim:/control_unit/temp_counter
force -freeze sim:/control_unit/reset_in 1 0
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /control_unit
force -freeze sim:/control_unit/reset_in 0 0
run
force -freeze sim:/control_unit/opcode 10101 0
force -freeze sim:/control_unit/immediate_value 0 0
force -freeze sim:/control_unit/exception_flag 00 0
force -freeze sim:/control_unit/reset_in 0 0
run
force -freeze sim:/control_unit/opcode 01110 0
force -freeze sim:/control_unit/immediate_value 1 0
force -freeze sim:/control_unit/exception_flag 00 0
force -freeze sim:/control_unit/reset_in 0 0
run
force -freeze sim:/control_unit/opcode 00110 0
force -freeze sim:/control_unit/immediate_value 0 0
force -freeze sim:/control_unit/exception_flag 00 0
force -freeze sim:/control_unit/reset_in 0 0
run