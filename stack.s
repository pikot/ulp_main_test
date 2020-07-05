/* ULP Example: Read temperautre in deep sleep

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.

   This file contains assembly code which runs on the ULP.

*/

/* ULP assembly files are passed through C preprocessor first, so include directives
   and C macros may be used in these files 
 */

.macro push rx
  st \rx,r3,0
  sub r3,r3,1
.endm

.macro pop rx
  add r3,r3,1
  ld \rx,r3,0
.endm

// Prepare subroutine jump
.macro psr 
  .set addr,(.+16)
  move r1,addr
  push r1
.endm

// Return from subroutine
.macro ret 
  pop r1
  jump r1
.endm

.macro store _addr val 
   move r1,\_addr // store result
   move r0,\val  // 
   st r0,r1,0
.endm

.macro store_mem addr_src addr_dst 
   move r2, \addr_src
   move r1, \addr_dst
   ld r0, r2, 0
   st r0, r1, 0               // Save data in memory 
.endm

.macro set_flag addr val
   move r2, \addr
   ld r0, r2, 0
   or r0, r0, \val
   st r0, r2, 0 
.endm

.macro del_flag addr val
   move r2, \addr
   ld r0, r2, 0
   and r0, r0, \val
   st r0, r2, 0 
.endm

.macro inc addr 
   move r2, \addr
   ld r0, r2, 0
   add r0, r0, 1              // Increment 
   st r0, r2, 0               // Save data in memory  1
.endm

.macro dec addr 
   move r2, \addr
   ld r0, r2, 0
   sub r0, r0, 1              // Increment 
   st r0, r2, 0               // Save data in memory  1
.endm
   
// Prepare subroutine jump, uses scratch register sr
.macro psrOlx sr=r1 pos=.
  .set _next2,(\pos+16)
  move \sr,_next2
  push \sr
.endm

// Return from subroutine
.macro retOlx sr=r1
  pop \sr
  jump \sr
.endm

// don't use r1 in DATA argumemt!!! =)
.macro read_i2c ADDR REG fail
   move r1, \ADDR
   push r1
   move r1,\REG
   push r1
   psr
   jump read8 
   add r3,r3,2 // remove call parameters from stack
   move r1,r0 // save result
   move r0,r2 // test for error
   jumpr \fail,1,ge
.endm

// don't use r1 in DATA argumemt!!! =)
.macro write_i2c ADDR REG DATA fail
   move r1,\ADDR
   push r1
   move r1,\REG
   push r1
   move r1,\DATA
   push r1
   psr
   jump write8
   add r3,r3,3 // remove call parameters from stack
   move r0, r2 // test for error in r2
   jumpr \fail,1,ge
.endm


.macro update_i2c_register ADDR REG fail mask value
    read_i2c \ADDR \REG \fail
    and r0, r1, \mask // take result from r1
    or r0, r0, \value
    write_i2c \ADDR \REG r0 \fail
.endm
