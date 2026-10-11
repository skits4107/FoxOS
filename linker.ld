ENTRY(_start)

PHDRS { none PT_NULL; }

SECTIONS
{
    /* Start at offset 0 relative to where firmware loads the binary */
    . = 0x000000;

    .text : {
        KEEP(*(.text.boot)) /* Ensure _start is placed at the absolute front */
        *(.text .text.*)
    } :none

    .rodata : {
        *(.rodata .rodata.*)
    } :none

    .data : {
        *(.data .data.*)
    } :none

    /* Define BSS section boundaries relative to the loaded binary */
    .bss (NOLOAD) : {
        . = ALIGN(16);
        __bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(16);
        __bss_end = .;
    } :none

    _end = .;
}