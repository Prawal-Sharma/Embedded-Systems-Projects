// Lab6.c
// Runs on LM4F120 or TM4C123
// Use SysTick interrupts to implement a 4-key digital piano
// MOOC lab 13 or EE319K lab6 starter
// Program written by: Prawal Sharma and Eric Frank 
// Date Created: 1/24/2015 
// Last Modified: 3/6/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections

// Port B bits 3-0 have the 4-bit DAC
// Port E bits 3-0 have 4 piano keys


#include <stdint.h>
#include "tm4c123gh6pm.h"
#include "Sound.h"
#include "Piano.h"
#include "TExaS.h"

//define period for the four needed tones
//Points per 1 wave length = 32
//Bus clock frequency = 80 MHz
//Bus clock frequency = 1/80 MHz = 12.5ns
//Fruequency of wave = 1/Period of wave = 1/(12.5ns*period(values defined below)*32)
#define C_0 4778 // 523.3 Hz
#define D  4257 // 587.3 Hz
#define E  3792 // 659.3 Hz
#define G  3189 // 784 Hz
#define A    2841   // 880 Hz
#define C    2389   // 1046.5 Hz
#define F   3579   // 698.5 Hz

// 2.Global Declarations Section
//Function prototypes
void delay(unsigned long msec);
// basic functions defined at end of startup.s
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

int main(void){ 
	//unsigned long input,previous;	
	DisableInterrupts(); 
  TExaS_Init(SW_PIN_PE3210, DAC_PIN_PB3210,ScopeOn); // activate grader and set system clock to 80 MHz
 // PortE used for piano keys, PortB used for DAC        
  Sound_Init(); // initialize SysTick timer and DAC
	GPIO_PORTF_DATA_R ^= 0x02;
  //Piano_Init();
	EnableInterrupts();
	GPIO_PORTF_DATA_R ^= 0x08;
	//Sound_Off();
	//previous = Piano_In()&0x1F;
	
	//GPIO_PORTF_DATA_R ^= 0x02;
	//GPIO_PORTF_DATA_R ^= 0x04;
  while(1){ 
	
	delay(100);		
/*   
		input = Piano_In()&0x1F; // bit 4 means SW1 pressed
    if(input&&(previous!=input)){ // just pressed     
			 switch(input){
				case 0x01:
					 Sound_Noise(A);      // Play note A wave
					 break; 
				case 0x02:   
					 Sound_Noise(G);      // Play note G wave
					 break; 
			
				case 0x04:  
					Sound_Noise(F);      // Play note F wave
					break;
				case 0x08:
					Sound_Noise(C);      // Play note C wave
					break;
				case 0x10:
				Play_Song(); 
				  break; 
				default:
					break;
			} 
    }
    if((input==0) && previous){ // just released    
			Sound_Off();;    // stop sound
    }
    previous = input; 
  */     
  } 
	
}



