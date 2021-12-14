vsim work.memstage
add wave  \
sim:/memstage/MEM_Read \
sim:/memstage/MEM_Write \
sim:/memstage/Reset \
sim:/memstage/Do32 \
sim:/memstage/clk \
sim:/memstage/StackSignal \
sim:/memstage/DataIn1 \
sim:/memstage/DataIn2 \
sim:/memstage/ALU_out \
sim:/memstage/DataOut1 \
sim:/memstage/DataOut2 \
sim:/memstage/ExceptionFlag \
sim:/memstage/DOut1 \
sim:/memstage/DOut2 \
sim:/memstage/SP_OLD \
sim:/memstage/SP_NEW \
sim:/memstage/Address \
sim:/memstage/AdderIn \
sim:/memstage/AdderOut \
sim:/memstage/AdderSignal \
sim:/memstage/EXP


force -freeze sim:/memstage/Reset 1 0
force -freeze sim:/memstage/clk 0 0, 1 {50 ps} -r 100
run

force -freeze sim:/memstage/MEM_Read 0 0
force -freeze sim:/memstage/MEM_Write 1 0
force -freeze sim:/memstage/Reset 0 0
force -freeze sim:/memstage/Do32 0 0
force -freeze sim:/memstage/StackSignal 1 0
force -freeze sim:/memstage/DataIn1 10#14 0
run

force -freeze sim:/memstage/MEM_Read 1 0
force -freeze sim:/memstage/MEM_Write 0 0
run

force -freeze sim:/memstage/MEM_Read 0 0
force -freeze sim:/memstage/MEM_Write 1 0
force -freeze sim:/memstage/Do32 1 0
force -freeze sim:/memstage/DataIn1 10#28 0
force -freeze sim:/memstage/DataIn2 10#7 0
run

force -freeze sim:/memstage/DataIn1 10#16 0
force -freeze sim:/memstage/DataIn2 10#12 0
run
force -freeze sim:/memstage/MEM_Read 1 0
force -freeze sim:/memstage/MEM_Write 0 0
force -freeze sim:/memstage/ALU_out 10#2000 0
run
force -freeze sim:/memstage/Do32 0 0
run

force -freeze sim:/memstage/StackSignal 0 0
run


