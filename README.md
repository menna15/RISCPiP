# RISCPiP
RISC Piplined Processor
# Notes To be consederd : 
# control unit should send selector of 2 bits as follows : 
``` done , named pc_mux2_selector ```

1-00  Reset \
2-01  Exp1 \
3-10  Exp2 \
4-11  Interupt
# control unit should send selector of 1 bit as follows : 
``` done , named pc_mux1_selector ```

1-0     by defoult \
2-1     if Reset or Exp1 or  Exp2 or Interupt happen


