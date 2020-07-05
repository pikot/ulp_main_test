#include "soc/rtc_cntl_reg.h"
#include "soc/rtc_io_reg.h"
#include "soc/soc_ulp.h"
//#include "stack.s"

.bss
   .global error_state
error_state:
   .long 0
   
   .global sample_counter
sample_counter:
   .long 0

   .global result
result:
   .long 0
   
.text

   .global entry
entry:
   move r1, sample_counter // store result
   move r0, 2  // 
   st r0,r1,0
   //psr
   //ret
   halt

  // ret 
