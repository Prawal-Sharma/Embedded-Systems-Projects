// Piano.c
// This software configures the off-board piano keys
// Runs on LM4F120 or TM4C123
// Program written by: put your names here
// Date Created: 8/25/2014 
// Last Modified: 3/6/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections
// Port E bits 3-0 have 4 piano keys

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "tm4c123gh6pm.h"

// **************Piano_Init*********************
// Initialize piano key inputs, called once 
// Input: none 
// Output: none
void Piano_Init(void){
	volatile unsigned long  delay;
  SYSCTL_RCGC2_R |= 0x00000010;     // 1) activate clock for Port E
  delay = SYSCTL_RCGC2_R;           // allow time for clock to start
  GPIO_PORTE_AMSEL_R &= ~0x1F;        // 3) disable analog on PE4-0
  GPIO_PORTE_PCTL_R &= ~0x0001FFFF;  // 4) PCTL GPIO on PE4-0
  GPIO_PORTE_DIR_R &= ~0x1F;         // 5) make PE3-0 in
  GPIO_PORTE_AFSEL_R &= ~0x1F;         // 6) disable alt funct on PE4-0
  GPIO_PORTE_DEN_R |= 0x1F;         // 7) enable digital I/O on PE4-0	
}

// **************Piano_In*********************
// Input from piano key inputs 
// Input: none 
// Output: 0 to 7 depending on keys
// 0x01 is just Key0, 0x02 is just Key1, 0x04 is just Key2, 0x08 is Key3
uint32_t Piano_In(void){
 return (GPIO_PORTE_DATA_R&0x1F);
}
