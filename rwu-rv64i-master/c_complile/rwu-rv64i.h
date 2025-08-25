#ifndef RWU_RV64I_H
#define RWU_RV64I_H

#include <stdint.h>

/* --------------------------------------------------------------------
   Memory Map (matches linker.ld)
   -------------------------------------------------------------------- */
#define IMEM_BASE       0x00000000UL
#define IMEM_SIZE       (32 * 1024UL)

#define DMEM_BASE       0x00000000UL
#define DMEM_SIZE       (64 * 1024UL)

/* Reserved first 0x100 bytes for runtime/linker */
#define DMEM_USER_BASE  0x00000100UL  

#define GPIO_BASE       0x00010000UL
#define GPIO_OUT_OFFSET 4

/* --------------------------------------------------------------------
   Linker Symbols (from linker.ld)
   -------------------------------------------------------------------- */
extern uint64_t _user_dmem_start;
extern uint64_t __stack_top;
extern uint64_t __bss_start;
extern uint64_t __bss_end;

/* --------------------------------------------------------------------
   GPIO Macros
   -------------------------------------------------------------------- */
#define GPIO_REG_OUT   (*(volatile uint8_t  *)(GPIO_BASE + GPIO_OUT_OFFSET))

/* --------------------------------------------------------------------
   DMEM Stream Writer (auto-increment)
   -------------------------------------------------------------------- */

/* one per translation unit (static internal linkage) */
static volatile uint64_t* __rwu_dmem_next = (volatile uint64_t*)0;

static inline volatile uint64_t* __rwu_dmem_ptr(void) {
    return (volatile uint64_t*)&_user_dmem_start;
}

/* Reset the auto-increment pointer back to safe DMEM base */
static inline void rwu_dmem_reset(void) {
    __rwu_dmem_next = __rwu_dmem_ptr();
}

/* Store one 64-bit value at the current slot and advance */
static inline void rwu_store64(uint64_t val) {
    if (__rwu_dmem_next == (volatile uint64_t*)0) {
        __rwu_dmem_next = __rwu_dmem_ptr();   // lazy init if reset not called
    }
    *__rwu_dmem_next++ = val;
}

/* --------------------------------------------------------------------
   Debug / Print helper
   -------------------------------------------------------------------- */
static inline void rwu_print(uint8_t val) {
    GPIO_REG_OUT = val;
}

#endif /* RWU_RV64I_H */
