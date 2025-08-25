/* linker.ld — Harvard-safe minimal linker script for RWU-RV64I */

OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 32K   /* instruction memory */
    DMEM (rw) : ORIGIN = 0x00000000, LENGTH = 64K   /* data memory */
}

/* Reserve some space at start of DMEM for runtime/linker bookkeeping */
__dmem_reserved = 0x100;

/* Provide stack pointer (stack grows down) */
__stack_top = ORIGIN(DMEM) + LENGTH(DMEM);

SECTIONS
{
    /* ---- CODE ---- */
    .text :
    {
        *(.text*)
        *(.rodata*)
    } > IMEM

    /* ---- DATA ---- */
    /* Only uninitialised data (bss) is supported. 
       We place .bss in DMEM after reserved space. */
    . = ORIGIN(DMEM) + __dmem_reserved;

    .bss (NOLOAD) :
    {
        __bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        __bss_end = .;
    } > DMEM

    /* Symbol exported for user programs: safe start of DMEM */
    _user_dmem_start = ORIGIN(DMEM) + __dmem_reserved;
    
    /* Define global pointer in middle of DMEM so GCC is happy */
    __global_pointer$ = ORIGIN(DMEM) + LENGTH(DMEM) / 2;
}

