.global _start

.text

_start:
    mrs x0, CurrentEL
    lsr x0, x0, #2

    cmp x0, #1
    b.eq el1_start        // If already in EL1, jump directly to kernel init
    cmp x0, #2
    b.eq drop_from_el2

drop_from_el2:
    // Set HCR_EL2.RW = 1 to force EL1 to run in 64-bit (AArch64) mode
    mov x1, #(1 << 31)
    msr hcr_el2, x1

    // This defines the target state we are "returning" to.
    // 0x3C5 = DAIF masked (Interrupts disabled), M[3:0] = 0101 (EL1h mode using SP_EL1)
    mov x1, #0x3C5
    msr spsr_el2, x1

    //Set the Exception Link Register (ELR_EL2) to your target EL1 entry point
    adr x1, el1_start
    msr elr_el2, x1

    //Clear pipeline and execute the return
    isb
    eret


el1_start:
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
    msr vbar_el1, x0 //set the excpetion table up

    dsb sy //ensure all memory operations are finished system wide
    isb // ensures no instruction in pipeline use stale excpetion vector table

    msr daifclr, #0 //enable all interrupts

    b kernel_main

kernel_main_messed_up:
    wfe
    b kernel_main_messed_up

    
