// Sound.c
// This module contains the SysTick ISR that plays sound
// Runs on LM4F120 or TM4C123
// Program written by: Prawal Sharma & Eric Frank 
// Date Created: 8/25/2014 
// Last Modified: 3/6/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "dac.h"
#include "tm4c123gh6pm.h"
#include "Sound.h"
#include "music.h" 
unsigned long Index;  
unsigned long int Index_2; 
unsigned short Sound_On_Flag;


// 4-bit 32-element sine wave
/*const unsigned short SineWave[32] = {
  8,9,11,12,13,14,14,15,15,15,14,
  14,13,12,11,9,8,7,5,4,3,2,
  2,1,1,1,2,2,3,4,5,7}; */ 

#define G  3189 // 784 Hz
#define A    2841   // 880 Hz
#define C    2389   // 1046.5 Hz
#define F   3579   // 698.5 Hz
#define D  4257 // 587.3 Hz

const unsigned short Song[28] = {A, G, F, G, A, A, A, G, G, G, A, C, C, A, G, F, G, A, A, A, A, G, G, A, G, F, D };

int off;
	
// **************Sound_Init*********************
// Initialize Systick periodic interrupts
// Also calls DAC_Init() to initialize DAC
// Input: none
// Output: none
void Sound_Init(void){
  DAC_Init();          // Port B is DAC
	Index = 0;
	off = 1;
	NVIC_ST_CTRL_R = 0;         // disable SysTick during setup
  NVIC_ST_RELOAD_R = 10000-1;// reload value with A
  NVIC_ST_CURRENT_R = 0;      // any write to current clears it
  NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R&0x00FFFFFF)|0x20000000; // priority 1   
  NVIC_ST_CTRL_R = 0x0007;  // enable SysTick with core clock and interrupts 	
	//******** Initialize Heartbeat 
	volatile unsigned long  delay;
	SYSCTL_RCGCGPIO_R |= 0x20;
	while((SYSCTL_PRGPIO_R & 0x20) == 0);
	/*SYSCTL_RCGC2_R |= 0x20;     // 1) activate clock for Port F
	delay = SYSCTL_RCGC2_R;           // allow time for clock to start	
	delay = SYSCTL_RCGC2_R; 
	delay = SYSCTL_RCGC2_R; 
	delay = SYSCTL_RCGC2_R; 
	delay = SYSCTL_RCGC2_R;
	delay = SYSCTL_RCGC2_R;
	delay = SYSCTL_RCGC2_R;
	delay = SYSCTL_RCGC2_R;
	*/
	GPIO_PORTF_AMSEL_R &= ~0x0E;      
  GPIO_PORTF_PCTL_R &= ~0x0000FFFF; // regular function
  GPIO_PORTF_AFSEL_R &= ~0x0E;   	
	GPIO_PORTF_DIR_R  |= 0x0E;				// set PF2 as ouput
	GPIO_PORTF_DEN_R  |= 0x0E;				// enable digital for PF2
	GPIO_PORTF_DATA_R |= 0x0E;				// set LED on PF2 on

}

//***************Play_Song**********************
void Play_Song(void){
unsigned long Index_2 = 0;
unsigned long number1 = 0; 
while(number1 < 2) {
	for(Index_2 =0; Index_2 < 27; Index_2= Index_2 + 1) {
Sound_Noise(Song[Index_2]); 
delay(500); 
}
number1++; 

}
}


//**************Delay********************
void delay(unsigned long msec)
	{ 
	//GPIO_PORTF_DATA_R ^= 0x04;
  unsigned long count;
  while(msec > 0 ) {  // repeat while there are still delay
    count = 16000;    // about 1ms
    while (count > 0) { 
      count--;
    } // This while loop takes approximately 3 cycles
    msec--;
  }
}


// **************Sound_Noise*********************
// Change Systick periodic interrupts to start sound output
// Input: interrupt period
//           Units of period are 12.5ns
//           Maximum is 2^24-1
//           Minimum is determined by length of ISR
// Output: none
void Sound_Noise(unsigned long period){
// this routine sets the RELOAD and starts SysTick
	Sound_On_Flag = 1;
	NVIC_ST_RELOAD_R = period - 1; //reload value
  NVIC_ST_CURRENT_R = 0;// any write to current clears it
}


// **************Sound_Off*********************
// stop outputing to DAC
// Output: none
void Sound_Off(void){
// this routine stops the sound output
	Sound_On_Flag = 0;
	//GPIO_PORTB_DATA_R = 0;
}


// Interrupt service routine
// Executed every 12.5ns*period(where period is input to Sound_Tone method)
//Period of Sound wave = interrupt period * size of sine table (size of SineWave array)
//size of sine table = 32
//interrupt period = 12.5ns*period(where period is input to Sound_Tone method)
int count = 0;
void SysTick_Handler(void){
		//Index = (Index+1)&0x1F;  //index increments from 0 to 31 and then starts back at 0 again
	if (count++ % 800 == 0)    
		GPIO_PORTF_DATA_R ^= 0x04;	// heartbeat (toggle PF2 LED)
		Sound_On_Flag = 1; 
		
		if(Sound_On_Flag){
			DAC_Out(huh_wav[Index++%240078]);
		
			//DAC_Out(Gal_wav[Index++%40078] >> 4);
			
		}
		else{
			GPIO_PORTB_DATA_R = 0;
		}
	
	
}

