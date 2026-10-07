.global exception_vector_table

.align 11 // padd out 2^11 (2048)  
exception_vector_table:

    b handle_curr_sp0_sync
    .align 7

    b handle_curr_sp0_irq
    .align 7

    b handle_curr_sp0_fiq
    .align 7

    b handle_curr_sp0_sys_err
    .align 7


    b handle_curr_spx_sync
    .align 7

    b handle_curr_spx_irq
    .align 7

    b handle_curr_spx_fiq
    .align 7

    b handle_curr_spx_sys_err
    .align 7


    b handle_lower_64_sync
    .align 7

    b handle_lower_64_irq
    .align 7

    b handle_lower_64_fiq
    .align 7

    b handle_lower_64_sys_err
    .align 7


    b handle_lower_32_sync
    .align 7

    b handle_lower_32_irq
    .align 7

    b handle_lower_32_fiq
    .align 7

    b handle_lower_32_sys_err
    .align 7
