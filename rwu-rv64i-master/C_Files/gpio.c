#include <stdint.h>

#define DMEM_BASE   0x00000000UL
#define GPIO_BASE   0x00010000UL

int main(void)
{
    volatile uint64_t *dmem = (volatile uint64_t *)(DMEM_BASE + 8);
    volatile uint8_t  *gpio = (volatile uint8_t *)(GPIO_BASE + 4);  // offset chosen based on typical layout

    *dmem = 42;   // Write 42 to data memory at DMEM_BASE + 8
    *gpio = 42;   // Write 42 to GPIO register at GPIO_BASE + 4

    while (1);    // Endless loop
}
