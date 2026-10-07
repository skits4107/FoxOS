.global _start

.text

_start:
    mrs x0, mpidr_el1
    and x0, x0, #0x3ff ; only get the affinity/ID bits
    cbz x0, is_core_zero
not_core_zero:
    wfe
    b not_core_zero

is_core_zero:
    mov sp, _start ; init stack pointer

    ; TODO: clear .bss section 