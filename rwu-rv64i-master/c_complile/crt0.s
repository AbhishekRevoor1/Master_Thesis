/* start.S — minimal startup for RWU-RV64I (rv64i, lp64)
   - Set SP to __stack_top
   - Set GP (optional)
   - Zero .bss
   - Call main()
   No attempt to copy .data (forbidden on Harvard setup).
*/

    .section .init, "ax"
    .globl _start
    .align  2

    .option push
    .option norelax
    .option norvc
    .attribute arch, "rv64i"

_start:
    /* set stack pointer to top of DMEM, keep 16-byte alignment */
    la      sp, __stack_top
    andi    sp, sp, -16

    /* set gp for small-data usage (harmless if unused) */
    la      gp, __global_pointer$

    /* clear .bss region (8-byte stores) */
    la      t0, __bss_start
    la      t1, __bss_end
1:
    beq     t0, t1, 2f
    sd      zero, 0(t0)
    addi    t0, t0, 8
    blt     t0, t1, 1b
2:
    /* jump to C main */
    call    main

/* if main returns, loop forever */
hang:
    j       hang

    .option pop

