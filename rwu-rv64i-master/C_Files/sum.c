#include <stdint.h>

#define DMEM_BASE   0x00000000UL
#define GPIO_BASE   0x00010000UL

int main(void)
{
    volatile uint64_t *dmem_result = (volatile uint64_t *)(DMEM_BASE + 16);  // where to store the sum
    volatile uint8_t  *gpio_output = (volatile uint8_t *)(GPIO_BASE + 4);    // GPIO output register

    uint64_t a = 20;
    uint64_t b = 90;
    uint64_t sum = a + b;  //output sgould be 110 in hex 6E

    *dmem_result = sum;  // store sum in DMEM
    *gpio_output = (uint8_t)sum;  // output sum to GPIO (truncate to 8-bit if needed)

    while (1);  // infinite loop
}

