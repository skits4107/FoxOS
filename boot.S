.global _start

.text

_start:
    mrs x0, mpidr_el1
    and x0, x0, #0x3ff //only get the affinity/ID bits
    cbz x0, is_core_zero
not_core_zero:
    wfe
    b not_core_zero

is_core_zero:
    adr     x0, _start
    mov     sp, x0 //init stack pointer

    adr     x0, __bss_start
    adr     x1, __bss_end

clear_bss_loop:
    strb wzr, [x0], #8 //store 1 byte zero in memory increament address in x0 by one byte
    cmp x0, x1
    b.hs clear_bss_loop 

    
    adr x0, exception_vector_table
    msr x0, vbar_el1 //set the excpetion table up

    dsb sy //ensure all memory operations are finished system wide
    isb // ensures no instruction in pipeline use stale excpetion vector table
    