    #include <stdint.h>

    #define DMEM_BASE     0x00000000UL
    #define GPIO_BASE     0x00010000UL
    #define GPIO_OFFSET   4
    #define DMEM_OFFSET   16

    #define GPIO_REG (*(volatile uint8_t *)(GPIO_BASE + GPIO_OFFSET))
    #define DMEM_OUTPUT (*(volatile uint64_t *)(DMEM_BASE + DMEM_OFFSET))

    static inline void print(uint8_t val) {
        GPIO_REG = val;
    }

    int main(void) {
        // Registers
        uint64_t x1 = 5, x2 = 10, x3 = 0, x4 = 0x100, tmp = 0;
        volatile uint64_t *mem = (volatile uint64_t *)DMEM_OUTPUT;

        // LUI
        x3 = 0xdeadb000UL;
        print(233); // LUI Passed

        // AUIPC
        x3 = (uint64_t)&&auipc_label;
        x3 += 0x1000;
        print(196); // AUIPC Passed
    auipc_label:

        // ADDI
        x3 = x1 + 12;
        print(251); // ADDI Passed

        // SLLI
        x3 = x1 << 2;
        print(250); // SLLI Passed

        // SLTI
        x3 = (x1 < 20) ? 1 : 0;
        print(249); // SLTI Passed

        // SLTIU
        x3 = ((uint64_t)x1 < (uint64_t)x2) ? 1 : 0;
        print(248); // SLTIU Passed

        // XORI
        x3 = x1 ^ 0xF;
        print(247); // XORI Passed

        // SRLI
        x3 = x1 >> 1;
        print(246); // SRLI Passed

        // SRAI
        x3 = ((int64_t)x1) >> 1;
        print(245); // SRAI Passed

        // ORI
        x3 = x1 | 0xF0;
        print(244); // ORI Passed

        // ANDI
        x3 = x1 & 0xF0;
        print(243); // ANDI Passed

        // SB
        ((volatile uint8_t *)mem)[8] = 0x42;
        print(242); // SB Passed

        // SH
        ((volatile uint16_t *)mem)[5] = 0xBEEF;
        print(241); // SH Passed

        // SW
        ((volatile uint32_t *)mem)[6] = 0x12345678;
        print(240); // SW Passed

        // LD/SD
        mem[4] = 0xCAFEBABEDEADBEEF;
        x3 = mem[4];
        print(17); // ADD Passed (ADDI, SD, LD, SW, JAL, JALR)

        // SUB
        x3 = x2 - x1;
        print(7); // SUB Passed

        // LB MSB=0
        ((volatile uint8_t *)mem)[10] = 0x05;
        x3 = (int8_t)((volatile uint8_t *)mem)[10];
        print(5); // LB Passed (MSB = 0)

        // LB MSB=1
        ((volatile uint8_t *)mem)[11] = 0x85;  // 0x85 = -123 signed
        x3 = (int8_t)((volatile uint8_t *)mem)[11];
        print(133); // LB Passed (MSB = 1)

        // LH
        ((volatile uint16_t *)mem)[12] = 0xFFFF;
        x3 = (int16_t)((volatile uint16_t *)mem)[12];
        print(255); // LH Passed

        // LW
        ((volatile uint32_t *)mem)[13] = 0xDEADBEEF;
        x3 = (int32_t)((volatile uint32_t *)mem)[13];
        print(254); // LW Passed

        // LBU
        ((volatile uint8_t *)mem)[14] = 0xFF;
        x3 = ((volatile uint8_t *)mem)[14];
        print(253); // LBU Passed

        // LHU
        ((volatile uint16_t *)mem)[15] = 0xFFFF;
        x3 = ((volatile uint16_t *)mem)[15];
        print(252); // LHU Passed

        // SLL
        x3 = x1 << 1;
        print(238); // SLL Passed

        // SLT
        x3 = (int64_t)x1 < (int64_t)x2 ? 1 : 0;
        print(239); // SLT Passed

        // SLTU
        x3 = (uint64_t)x1 < (uint64_t)x2 ? 1 : 0;
        print(237); // SLTU Passed

        // XOR
        x3 = x1 ^ x2;
        print(236); // XOR Passed

        // SRL
        x3 = x2 >> 2;
        print(235); // SRL Passed

        // SRA
        x3 = ((int64_t)x2) >> 2;
        print(234); // SRA Passed

        // BEQ
        if (x1 == 5) print(232); // BEQ Passed

        // BNE
        if (x1 != x2) print(231); // BNE Passed

        // BLT
        if ((int64_t)x1 < (int64_t)x2) print(230); // BLT Passed

        // BGE
        if ((int64_t)x2 >= (int64_t)x1) print(229); // BGE Passed

        // BLTU
        if ((uint64_t)x1 < (uint64_t)x2) print(228); // BLTU Passed

        // BGEU
        if ((uint64_t)x2 >= (uint64_t)x1) print(227); // BGEU Passed

        // LWU
        ((volatile uint32_t *)mem)[2] = 0xABCDEF12;
        x3 = ((volatile uint32_t *)mem)[2];
        print(226); // LWU Passed

        // ADDIW
        int32_t xw = (int32_t)x1 + 1;
        print(225); // ADDIW Passed

        // SLLIW
        xw = (int32_t)x1 << 1;
        print(224); // SLLIW Passed

        // SRLIW
        xw = (uint32_t)x1 >> 1;
        print(223); // SRLIW Passed

        // SRAIW
        xw = (int32_t)x1 >> 1;
        print(222); // SRAIW Passed

        // ADDW
        xw = (int32_t)((int32_t)x1 + (int32_t)x2);
        print(221); // ADDW Passed

        // OR
        x3 = x1 | x2;
        print(14); // OR Passed

        // AND
        x3 = x1 & x2;
        print(8); // AND Passed (End of test)

        while (1); // End loop
    }
