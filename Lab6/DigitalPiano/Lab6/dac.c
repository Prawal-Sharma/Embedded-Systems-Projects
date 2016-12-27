// dac.c
// This software configures DAC output
// Runs on LM4F120 or TM4C123
// Program written by: put your names here
// Date Created: 8/25/2014 
// Last Modified: 3/6/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections
// Port B bits 3-0 have the 4-bit DAC

#include <stdint.h>
#include "tm4c123gh6pm.h"
// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data

// **************DAC_Init*********************
// Initialize 4-bit DAC, called once 
// Input: none
// Output: none
void DAC_Init(void){
	unsigned long volatile delay;
	SYSCTL_RCGCGPIO_R |= 0x02;
	while ((SYSCTL_PRGPIO_R & 0x02) == 0);
  //SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOB; // activate port B
  //delay = SYSCTL_RCGC2_R;    // allow time to finish activating
/* GPIO_PORTB_AMSEL_R &= ~0xFF;
 GPIO_PORTB_PCTL_R &= ~0xFFFFFFFF; // regular function
  GPIO_PORTB_DIR_R |= 0xFF;      // make PB3-0 out
	GPIO_PORTB_DR8R_R |= 0xFF;    // can drive up to 8mA out on PB3-0
  GPIO_PORTB_AFSEL_R &= ~0xFF;   // disable alt funct on PB3-0
  GPIO_PORTB_DEN_R |= 0xFF;      // enable digital I/O on PB3-0
	*/ 
	

	GPIO_PORTB_AMSEL_R &= ~0x0F;      // no analog on PB3-0
  GPIO_PORTB_PCTL_R &= ~0x0000FFFF; // regular function
  GPIO_PORTB_DIR_R |= 0x0F;      // make PB3-0 out
	GPIO_PORTB_DR8R_R |= 0x0F;    // can drive up to 8mA out on PB3-0
  GPIO_PORTB_AFSEL_R &= ~0x0F;   // disable alt funct on PB3-0
  GPIO_PORTB_DEN_R |= 0x0F;      // enable digital I/O on PB3-0
	
}

// **************DAC_Out*********************
// output to DAC
// Input: 4-bit data, 0 to 15 
// Output: none
void DAC_Out(uint32_t data){
GPIO_PORTB_DATA_R = (GPIO_PORTB_DATA_R & ~0xFF) | (data & 0xFF);
}
