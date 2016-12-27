// Lab9.c
// Runs on LM4F120 or TM4C123
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly
// Last Modified: 4/12/2016 

// Analog Input connected to PE2=ADC1
// displays on Sitronox ST7735
// PF3, PF2, PF1 are heartbeats
// UART1 on PC4-5
// * Start with where you left off in Lab8. 
// * Get Lab8 code working in this project.
// * Understand what parts of your main have to move into the UART1_Handler ISR
// * Rewrite the SysTickHandler
// * Implement the s/w FiFo on the receiver end 
//    (we suggest implementing and testing this first)

#include <stdint.h>

#include "ST7735.h"
#include "TExaS.h"
#include "ADC.h"
#include "print.h"
#include "tm4c123gh6pm.h"
#include "UART.h"
#include "FiFo.h"

//*****the first three main programs are for debugging *****
// main1 tests just the ADC and slide pot, use debugger to see data
// main2 adds the LCD to the ADC and slide pot, ADC data is on Nokia
// main3 adds your convert function, position data is no Nokia

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

#define PF1       (*((volatile uint32_t *)0x40025008))
#define PF2       (*((volatile uint32_t *)0x40025010))
#define PF3       (*((volatile uint32_t *)0x40025020))
uint32_t Data;      // 12-bit ADC
uint32_t Position;  // 32-bit fixed-point 0.001 cm
int32_t TxCounter = 0;


void PortF_Init(void){unsigned long volatile delay;
  SYSCTL_RCGCGPIO_R |= 0x00000020;				//SYSCTL_RCGC2_GPIOF;
   while((SYSCTL_PRGPIO_R&0x20) == 0){};
 GPIO_PORTF_AMSEL_R &= ~0x00;     
 GPIO_PORTF_PCTL_R &= ~0xFF; // regular GPIO function
 GPIO_PORTF_DIR_R |= 0x0E;					// make PF1-3 input
 GPIO_PORTF_AFSEL_R &= ~0x0E;   // disable alt funct on PF1-3
 GPIO_PORTF_DEN_R |= 0x0E;      // enable digital I/O on PF1-3	// Intialize PortF for hearbeat
}

// Get fit from excel and code the convert routine with the constants
// from the curve-fit
uint32_t Convert(uint32_t input){
  return ((56*(input))+27891)/128;
}


// final main program for bidirectional communication
// Sender sends using SysTick Interrupt
// Receiver receives using RX
void SysTick_Init(uint32_t period)
{
  NVIC_ST_CTRL_R = 0;         									// disable SysTick during setup
  NVIC_ST_RELOAD_R = period-1;									// reload value
  NVIC_ST_CURRENT_R = 0;     									  // any write to current clears it
  NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R & 0x00FFFFFF) | 0x20000000
	; // priority 1
  NVIC_ST_CTRL_R = 0x0007; 											// enable SysTick with core clock and interrupts

}
char datav;
int main_fifo(void);

int main(void){ 
	
	int delay;
  TExaS_Init();       // Bus clock is 80 MHz 
  ST7735_InitR(INITR_REDTAB);
	SysTick_Init(2000000);
  ADC_Init();    // initialize to sample ADC1
	  delay=0x5000;
	while(delay){
		delay--;
	}
  PortF_Init();
		  delay=0x5000;
	while(delay){
		delay--;
	}
  UART_Init();       // initialize UART
		  delay=0x5000;
	while(delay){
		delay--;
	}

	//SysTick_Init();			//Enable SysTick Interrupt by calling SysTick_Init()
  EnableInterrupts();

  while(1){
	
		
			ST7735_SetCursor(0,0);

			FiFo_Get(&datav);
		if(datav==0x02){
//			ST7735_FillScreen(0);
			ST7735_SetCursor(0,0);
			FiFo_Get(&datav);
		ST7735_OutChar(datav);		//dig1
				FiFo_Get(&datav);
		ST7735_OutChar(datav);		//"."
				FiFo_Get(&datav);
		ST7735_OutChar(datav);		//dig2
				FiFo_Get(&datav);
		ST7735_OutChar(datav);		//dig3
				FiFo_Get(&datav);
		ST7735_OutChar(datav);		//dig4


					ST7735_OutString("     cm");

				FiFo_Get(&datav);
	ST7735_SetCursor(0,1);
			ST7735_OutString("                 ");

				FiFo_Init();
		
		
		
		
		
		
		}
}
}
void SysTick_Handler(void){ // every 25 ms
					
											//        format message and transmit 
	GPIO_PORTF_DATA_R ^= 0x02;
	int holder;
	int holder1;
	Data=ADC_In();
	Data=Convert(Data);
	GPIO_PORTF_DATA_R ^= 0x02;
	UART_OutChar(0x02);
	holder=Data/1000;
	holder1=holder+0x30;
	UART_OutChar(holder1);
	UART_OutChar(0x2E);
	Data=Data-(holder*1000);
	holder=Data/100;
	holder1=holder+0x30;
	UART_OutChar(holder1);
	Data=Data-(holder*100);
	holder=Data/10;
	holder1=holder+0x30;
	UART_OutChar(holder1);
	Data=Data-(holder*10);
	holder1=holder+0x30;
	UART_OutChar(holder1);
	
	
	


	UART_OutChar(0x0D);
	UART_OutChar(0x03);
	TxCounter++;
	GPIO_PORTF_DATA_R ^= 0x02;

	
	
}


uint32_t Status[20];             // entries 0,7,12,19 should be false, others true
char GetData[10];  // entries 1 2 3 4 5 6 7 8 should be 1 2 3 4 5 6 7 8
int main_fifo(void){ // Make this main to test FiFo
  FiFo_Init();
  for(;;){
    Status[0]  = FiFo_Get(&GetData[0]);  // should fail,    empty
    Status[1]  = FiFo_Put(1);            // should succeed, 1 
    Status[2]  = FiFo_Put(2);            // should succeed, 1 2
    Status[3]  = FiFo_Put(3);            // should succeed, 1 2 3
    Status[4]  = FiFo_Put(4);            // should succeed, 1 2 3 4
    Status[5]  = FiFo_Put(5);            // should succeed, 1 2 3 4 5
    Status[6]  = FiFo_Put(6);            // should succeed, 1 2 3 4 5 6
    Status[7]  = FiFo_Put(7);            // should fail,    1 2 3 4 5 6 
    Status[8]  = FiFo_Get(&GetData[1]);  // should succeed, 2 3 4 5 6
    Status[9]  = FiFo_Get(&GetData[2]);  // should succeed, 3 4 5 6
    Status[10] = FiFo_Put(7);            // should succeed, 3 4 5 6 7
    Status[11] = FiFo_Put(8);            // should succeed, 3 4 5 6 7 8
    Status[12] = FiFo_Put(9);            // should fail,    3 4 5 6 7 8 
    Status[13] = FiFo_Get(&GetData[3]);  // should succeed, 4 5 6 7 8
    Status[14] = FiFo_Get(&GetData[4]);  // should succeed, 5 6 7 8
    Status[15] = FiFo_Get(&GetData[5]);  // should succeed, 6 7 8
    Status[16] = FiFo_Get(&GetData[6]);  // should succeed, 7 8
    Status[17] = FiFo_Get(&GetData[7]);  // should succeed, 8
    Status[18] = FiFo_Get(&GetData[8]);  // should succeed, empty
    Status[19] = FiFo_Get(&GetData[9]);  // should fail,    empty
  }
}


	
