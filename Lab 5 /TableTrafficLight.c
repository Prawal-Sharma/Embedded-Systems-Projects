// ***** 0. Documentation Section *****
// TableTrafficLight.c for (Lab 10 edX), Lab 5 EE319K
// Runs on LM4F120/TM4C123
// Program written by: Prawal Sharma & Eric Frank 
// Date Created: 1/24/2015 
// Last Modified: 3/2/2016 

// Lab number: 5
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********
// east/west red light connected to PB5
// east/west yellow light connected to PB4
// east/west green light connected to PB3
// north/south facing red light connected to PB2
// north/south facing yellow light connected to PB1
// north/south facing green light connected to PB0
// pedestrian detector connected to PE2 (1=pedestrian present)
// north/south car detector connected to PE1 (1=car present)
// east/west car detector connected to PE0 (1=car present)
// "walk" light connected to PF3 (built-in green LED)
// "don't walk" light connected to PF1 (built-in red LED)

// ***** 1. Pre-processor Directives Section *****
#include <stdint.h>
#include "TExaS.h"
#include "tm4c123gh6pm.h"
#include "SysTick.h"

// ***** 2. Global Declarations Section *****

#define goS0  0
#define goW0  1
#define wk0   2
#define goS1  3
#define stS1  4
#define goW1  5
#define stW1  6
#define wk1   7
#define dwk1  8
#define dwk1a 9
#define goS2  10
#define stS2  11
#define goW2  12
#define stW2  13
#define wk2   14
#define dwk2  15
#define dwk2a 16

struct state{
	uint32_t outB;
	uint8_t outF;
	uint32_t wait;
	uint8_t next[8];
};

typedef struct state state_t;

const state_t FSM[17] = {
	{0x21, 0x2, 20, {goS0, stS1, goS0, stS1, stS2, stS1, stS2, stS2}},//goS0
	{0x0C, 0x2, 20, {goW0, goW0, stW1, stW1, stW2, stW2, stW2, stW2}},//goW0
	{0x24, 0x8, 20, {wk0, dwk2, dwk1, dwk1, wk0, dwk2, dwk1, dwk1}},//wk0
	{0x21, 0x2, 20, {stS1, stS1, stS1, stS1, stS1, stS1, stS1, stS1}},//goS1
	{0x22, 0x2, 20, {goW0, goW0, goW1, goW1, goW2, goW2, goW2, goW2}},//stS1
	{0x0C, 0x2, 20, {stW1, stW1, stW1, stW1, stW1, stW1, stW1, stW1}},//goW1
	{0x14, 0x2, 20, {goS0, goS1, goS0, goS1, goS2, goS1, goS2, goS2}},//stW1
	{0x24, 0x8, 20, {dwk1, dwk1, dwk1, dwk1, dwk1, dwk1, dwk1, dwk1}},//wk1
	{0x24, 0x2, 10, {dwk1a, dwk1a, dwk1a, dwk1a, dwk1a, dwk1a, dwk1a, dwk1a}},//dwk1
	{0x24, 0x0, 10, {goS0, goS1, goS0, goS1, goS2, goS2, goS2, goS2}},//dwk1a
	{0x21, 0x2, 20, {stS2, stS2, stS2, stS2, stS2, stS2, stS2, stS2}},//goS2
	{0x22, 0x2, 20, {wk0, wk2, wk1, wk2, wk0, wk2, wk1, wk2}},//stS2
	{0x0C, 0x2, 20, {stW2, stW2, stW2, stW2, stW2, stW2, stW2, stW2}},//goW2
	{0x14, 0x2, 20, {wk0, wk2, wk1, wk1, wk0, wk2, wk1, wk1}},//stW2
	{0x24, 0x8, 20, {dwk2, dwk2, dwk2, dwk2, dwk2, dwk2, dwk2, dwk2}},//wk2
	{0x24, 0x2, 10, {dwk2a, dwk2a, dwk2a, dwk2a, dwk2a, dwk2a, dwk2a, dwk2a}},//dwk2
	{0x24, 0x0, 10, {goW0, goW0, goW1, goW1, goW2, goW2, goW1, goW1}},//dwk2a
	
};

// FUNCTION PROTOTYPES: Each subroutine defined
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

// ***** 3. Subroutines Section *****
	

int main(void){
	SYSCTL_RCGC2_R |= 0x32;
  TExaS_Init(SW_PIN_PE210, LED_PIN_PB543210); // activate grader and set system clock to 80 MHz
	GPIO_PORTB_DIR_R |= 0x3F;
	GPIO_PORTE_DIR_R &= 0xF8;
	GPIO_PORTF_DIR_R |= 0x0A;
	GPIO_PORTB_DEN_R |= 0x3F;
	GPIO_PORTE_DEN_R |= 0x07;
	GPIO_PORTF_DEN_R |= 0x0A;
	GPIO_PORTB_AFSEL_R &= 0xC0;
	GPIO_PORTE_AFSEL_R &= 0xF8;
	GPIO_PORTF_AFSEL_R &= 0xF5;
	GPIO_PORTB_AMSEL_R = 0x00;
	GPIO_PORTE_AMSEL_R = 0x00;
	GPIO_PORTF_AMSEL_R = 0x00;
	
	SysTick_Init();
	 
  DisableInterrupts();
  EnableInterrupts();
	uint32_t input; 
	uint8_t S = goS0;
	
  while(1){
		GPIO_PORTB_DATA_R = FSM[S].outB;
		GPIO_PORTF_DATA_R = FSM[S].outF;
		SysTick_Wait10ms(FSM[S].wait);
		input = GPIO_PORTE_DATA_R;
		S = FSM[S].next[input];  
	
  }
}
