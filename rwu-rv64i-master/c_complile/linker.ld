/* Minimal linker script for RWU-RV64I */

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 32K
    DMEM (rw) : ORIGIN = 0x01000000, LENGTH = 8K
}

_stack_top = ORIGIN(DMEM) + LENGTH(DMEM);

SECTIONS
{
    .text :
    {
        *(.text*)
        *(.rodata*)
    } > IMEM

    .data :
    {
        *(.data*)
        *(.sdata*)
    } > DMEM

    .bss :
    {
        *(.bss*)
        *(COMMON)
    } > DMEM
}
