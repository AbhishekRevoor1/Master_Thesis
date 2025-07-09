#include <stdint.h>

#define DMEM_BASE   0x00000000UL
#define GPIO_BASE   0x00010000UL

#define DMEM_RESULT_OFFSET  16
#define GPIO_OUTPUT_OFFSET  4
int main(void)
{
    volatile uint64_t *dmem_result = (volatile uint64_t *)(DMEM_BASE + DMEM_RESULT_OFFSET);
    volatile uint8_t  *gpio_output = (volatile uint8_t *)(GPIO_BASE + GPIO_OUTPUT_OFFSET);

    uint64_t sum = 0;

    for (uint64_t i = 1; i <= 10; ++i) {
        sum += i;
    }

    *dmem_result = sum;       
    *gpio_output = (uint8_t)sum; 
    

    while (1);  // Infinite loop to halt
}

