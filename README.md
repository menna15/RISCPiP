# RISCPiP
RISC Piplined Processor
# control unit send selector of 2 bits as follows : 
``` for pc selector mux 1 :```

1-00  Default \
2-01  Reset /interrupt/exception \
3-10  Ret/RTI \
4-11  call/jmp

``` for pc selector mux 2 :```

1-00  Reset \
2-01  Exception1\
3-10  Exception2\
4-11  Interrupt
# control unit send selector of 1 bit as follows : 
``` for pc selector mux 3 :```

selector of this mux is do_32 signal 

1-1  Reset/interrupt/exception \
2-0  default


