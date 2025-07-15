#include <stdint.h>

#define DMEM_BASE   0x00000000UL
#define GPIO_BASE   0x00010000UL

#define DMEM_RESULT_OFFSET  16
#define GPIO_OUTPUT_OFFSET  0

int main(void)
{
    volatile uint64_t *dmem_result = (volatile uint64_t *)(DMEM_BASE + DMEM_RESULT_OFFSET);
    volatile uint8_t  *gpio_output = (volatile uint8_t *)(GPIO_BASE + GPIO_OUTPUT_OFFSET);

    uint64_t sum;
    
    for (uint64_t i=0; i<1000; i++){
    *dmem_result = i * 5;
    }
    
    sum = *dmem_result;
    
    *gpio_output = (uint8_t)sum; 
    

    while (1);  // Infinite loop to halt
}

