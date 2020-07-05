#include "soc/rtc_cntl_reg.h"
#include "soc/rtc_io_reg.h"
#include "soc/soc_ulp.h"
//#include "stack.s"


.bss
i2c_started:
  .long 0
i2c_didInit:
  .long 0

.text

.macro pop rx
  //add r3,r3,1
  //ld \rx,r3,0
.endm

.macro ret 
   pop r1
   jump r1
.endm


.global i2c_start_cond


i2c_start_cond:  
//  move r0,1
 // st r0,r2,0
  //pop r1
  //jump r1
   ret
 
