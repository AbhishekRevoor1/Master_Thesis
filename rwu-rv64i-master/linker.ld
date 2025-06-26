/* linker.ld */
ENTRY(_start)
SECTIONS {
  . = 0x00000000; /* Set start address explicitly to zero */
  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : { *(.bss COMMON) }
}

