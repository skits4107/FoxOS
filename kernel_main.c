#include <stdbool.h>

#define AUX_ENABLES     ((volatile unsigned int*)(0x3F215004))
#define AUX_MU_IER_REG  ((volatile unsigned int*)(0x3F215044))
#define AUX_MU_LCR_REG  ((volatile unsigned int*)(0x3F21504C))
#define AUX_MU_BAUD_REG ((volatile unsigned int*)(0x3F215068))
#define AUX_MU_CNTL_REG ((volatile unsigned int*)(0x3F215060))
#define AUX_MU_LSR_REG  ((volatile unsigned int*)(0x3F215054))
#define AUX_MU_IO_REG   ((volatile unsigned int*)(0x3F215040))
#define AUX_MU_IIR_REG ((volatile unsigned int*)(0x3F215048))
#define AUX_MU_MCR_REG ((volatile unsigned int*)(0x3F215050))

#define GPFSEL1 ((volatile unsigned int*)(0x3F200004))
#define GPPUD ((volatile unsigned int*)(0x3F200094))
#define GPPUDCLK0 ((volatile unsigned int*)(0x3F200098))


void GPP_wait(){
    asm volatile (
    "mov x0, #150\n\t"
    "1:\n\t"
    "subs x0, x0, #1\n\t"
    "bne 1b\n\t"
    :
    :
    : "x0", "cc"
    );
}

void uart_init() {
    unsigned int gpio = *GPFSEL1;
    gpio &= ~((7 << 12) | (7 << 15));// Clear GPIO 14 and 15 function selection
    gpio |= (2 << 12) | (2 << 15); // Select ALT5 (binary 010) for both pins
    *GPFSEL1 = gpio;


    *GPPUD = 0; //to select the "floating / disable pull-up/down" state

    GPP_wait();

    *GPPUDCLK0 = (1 << 14) | (1 << 15); //locks disabled state.
  
    GPP_wait();

    *GPPUDCLK0 = 0; // no more clock signal so future changes dont affect settings.


    *AUX_ENABLES     = 1;   // Turn on the Mini UART clock system
    *AUX_MU_IER_REG  = 0;   // Disable receiver/transmitter interrupts (until after polling)
    *AUX_MU_CNTL_REG = 0;   // Temporarily turn off auto-flow control / Tx / Rx
    *AUX_MU_LCR_REG  = 3;   // Set data size to standard 8-bit mode
    *AUX_MU_MCR_REG  = 0;   // Set RTS line to high (inactive)
    *AUX_MU_BAUD_REG = 270; // Set the speed divider to 115200 Baud
    *AUX_MU_IIR_REG = 0xC6; // clears FIFO buffers
    
    *AUX_MU_CNTL_REG = 3;   // Turn Tx and Rx back on now that it's configured!

}


void uart_print(char message[], int message_len){
    int index = 0;

    while (index < message_len){
        while (!((*AUX_MU_LSR_REG) & 0b100000)){} //wait for transmitter to be ready
        char c = message[index];
        *AUX_MU_IO_REG = c;
        index++;
    }
}

void kernel_main(){
    uart_init();



   
    while(true){
        char message[] = "Hello from FoxOS!\n";
        uart_print(message, 18);
    }; //placeholder loop until I get other stuff going.
}