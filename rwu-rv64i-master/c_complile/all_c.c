#include <stdint.h>

#define DMEM_BASE     0x00000000UL
#define GPIO_BASE     0x00010000UL
#define GPIO_OFFSET   4
#define DMEM_OFFSET   16  // store all results from here

#define GPIO_REG (*(volatile uint8_t *)(GPIO_BASE + GPIO_OFFSET))
#define DMEM ((volatile uint64_t *)(DMEM_BASE + DMEM_OFFSET))

static inline void print(uint8_t val) {
    GPIO_REG = val;
}

int main(void) {
    int a = 5, b = 10, c = 0, d = 0x100;
    int tmp = 0;
    int aw = 0;
    int idx = 0;

    // LUI
    uint64_t lui_val = 0xdeadb000UL;
    DMEM[idx++] = lui_val;
    print(233);

    // AUIPC
    uint64_t pc_here = (uint64_t)&&auipc_label;
    pc_here += 0x1000;
    DMEM[idx++] = pc_here;
    print(196);
auipc_label:

    // ADDI
    c = a + 12; DMEM[idx++] = c; print(251);
    // SLLI
    c = a << 2; DMEM[idx++] = c; print(250);
    // SLTI
    c = (a < 20) ? 1 : 0; DMEM[idx++] = c; print(249);
    // SLTIU
    c = ((uint32_t)a < (uint32_t)b) ? 1 : 0; DMEM[idx++] = c; print(248);
    // XORI
    c = a ^ 0xF; DMEM[idx++] = c; print(247);
    // SRLI
    c = ((uint32_t)a) >> 1; DMEM[idx++] = c; print(246);
    // SRAI
    c = a >> 1; DMEM[idx++] = c; print(245);
    // ORI
    c = a | 0xF0; DMEM[idx++] = c; print(244);
    // ANDI
    c = a & 0xF0; DMEM[idx++] = c; print(243);

    // SB
    ((volatile uint8_t *)DMEM)[64] = 0x42; print(242);
    // SH
    ((volatile uint16_t *)DMEM)[66] = 0xBEEF; print(241);
    // SW
    ((volatile uint32_t *)DMEM)[68] = 0x12345678; print(240);

    // SD / LD
    DMEM[70] = 0xCAFEBABEDEADBEEF;
    c = DMEM[70];
    DMEM[idx++] = c; print(17); // also covers ADDI, LD, SD, JALR, JAL

    // SUB
    c = b - a; DMEM[idx++] = c; print(7);
    // LB MSB=0
    ((volatile uint8_t *)DMEM)[80] = 0x05;
    c = (int8_t)((volatile uint8_t *)DMEM)[80]; DMEM[idx++] = c; print(5);
    // LB MSB=1
    ((volatile uint8_t *)DMEM)[81] = 0x85;
    c = (int8_t)((volatile uint8_t *)DMEM)[81]; DMEM[idx++] = c; print(133);
    // LH
    ((volatile uint16_t *)DMEM)[82] = 0xFFFF;
    c = (int16_t)((volatile uint16_t *)DMEM)[82]; DMEM[idx++] = c; print(255);
    // LW
    ((volatile uint32_t *)DMEM)[84] = 0xDEADBEEF;
    c = (int32_t)((volatile uint32_t *)DMEM)[84]; DMEM[idx++] = c; print(254);
    // LBU
    ((volatile uint8_t *)DMEM)[86] = 0xFF;
    c = ((volatile uint8_t *)DMEM)[86]; DMEM[idx++] = c; print(253);
    // LHU
    ((volatile uint16_t *)DMEM)[87] = 0xFFFF;
    c = ((volatile uint16_t *)DMEM)[87]; DMEM[idx++] = c; print(252);

    // SLL
    c = a << 1; DMEM[idx++] = c; print(238);
    // SLT
    c = (a < b) ? 1 : 0; DMEM[idx++] = c; print(239);
    // SLTU
    c = ((uint32_t)a < (uint32_t)b) ? 1 : 0; DMEM[idx++] = c; print(237);
    // XOR
    c = a ^ b; DMEM[idx++] = c; print(236);
    // SRL
    c = ((uint32_t)b) >> 2; DMEM[idx++] = c; print(235);
    // SRA
    c = b >> 2; DMEM[idx++] = c; print(234);

    // BEQ
    if (a == 5) { DMEM[idx++] = 1; print(232); }
    else DMEM[idx++] = 0;
    // BNE
    if (a != b) { DMEM[idx++] = 1; print(231); }
    else DMEM[idx++] = 0;
    // BLT
    if (a < b) { DMEM[idx++] = 1; print(230); }
    else DMEM[idx++] = 0;
    // BGE
    if (b >= a) { DMEM[idx++] = 1; print(229); }
    else DMEM[idx++] = 0;
    // BLTU
    if ((uint32_t)a < (uint32_t)b) { DMEM[idx++] = 1; print(228); }
    else DMEM[idx++] = 0;
    // BGEU
    if ((uint32_t)b >= (uint32_t)a) { DMEM[idx++] = 1; print(227); }
    else DMEM[idx++] = 0;

    // LWU
    ((volatile uint32_t *)DMEM)[20] = 0xABCDEF12;
    c = ((volatile uint32_t *)DMEM)[20]; DMEM[idx++] = c; print(226);

    // ADDIW
    aw = (int32_t)a + 1; DMEM[idx++] = aw; print(225);
    // SLLIW
    aw = (int32_t)a << 1; DMEM[idx++] = aw; print(224);
    // SRLIW
    aw = ((uint32_t)a) >> 1; DMEM[idx++] = aw; print(223);
    // SRAIW
    aw = ((int32_t)a) >> 1; DMEM[idx++] = aw; print(222);
    // ADDW
    aw = (int32_t)a + (int32_t)b; DMEM[idx++] = aw; print(221);

    // OR
    c = a | b; DMEM[idx++] = c; print(14);
    // AND
    c = a & b; DMEM[idx++] = c; print(8); // End of test

    while (1);
}

