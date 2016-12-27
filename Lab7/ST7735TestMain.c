// ST7735TestMain.c
// Runs on LM4F120/TM4C123
// Test the functions in ST7735.c by printing basic
// patterns to the LCD.
//    16-bit color, 128 wide by 160 high LCD
// Daniel Valvano
// Last Modified: 3/6/2015 

/* This example accompanies the book
   "Embedded Systems: Real Time Interfacing to Arm Cortex M Microcontrollers",
   ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2014

 Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */

// Backlight (pin 10) connected to +3.3 V
// MISO (pin 9) unconnected 
// SCK (pin 8) connected to PA2 (SSI0Clk)
// MOSI (pin 7) connected to PA5 (SSI0Tx)
// TFT_CS (pin 6) connected to PA3 (SSI0Fss)
// CARD_CS (pin 5) unconnected
// Data/Command (pin 4) connected to PA6 (GPIO), high for data, low for command
// RESET (pin 3) connected to PA7 (GPIO)
// VCC (pin 2) connected to +3.3 V
// Gnd (pin 1) connected to ground
#include <stdio.h>
#include <stdint.h>
#include "ST7735.h"
#include "PLL.h"
#include "tm4c123gh6pm.h"
#include "image1.h"

void DelayWait10ms(uint32_t n);

// test image
// [blue] [green]
// [red ] [white]
const uint16_t Test[] = {
  0x001F, 0xFFFF, 0xF800, 0x07E0
};
// test image2
// [red]   [yellow]  [green]   [blue]    [black]
// [red]   [yellow]  [green]   [blue]    [white]
// [red]   [yellow]  [green]   [blue]    [black]
// [red]   [yellow]  [green]   [blue]    [white]
// [red]   [yellow]  [green]   [blue]    [black]
// [black] [75%grey] [50%grey] [25%grey] [white]





uint32_t const TestData[16] ={
  0,7,34,199,321,654,4789,9999,10000,21896,65535,
  123456,1234567,12345678,123456789,0xFFFFFFFF};
void IO_Init(void);
void IO_HeartBeat(void);
void IO_Touch(void);
void LCD_OutDec(uint32_t num);
void LCD_OutFix(uint32_t num);  
int main(void){  
 // uint32_t i;
//  uint8_t red, green, blue;
  PLL_Init();                           // set system clock to 80 MHz
  IO_Init();
  
  // test DrawChar() and DrawCharS()
  ST7735_InitR(INITR_REDTAB);
  
  
  //ST7735_OutString("Lab 7!\nWelcome to EE319K");
	ST7735_SetCursor(1,1);
	ST7735_OutString("Welcome\n To a random Game");
	
  IO_Touch();
	
	ST7735_FillScreen(0xFFFF);            // set screen to white
	int k = 159; 
	int z = 0; 
	while(k != 0){
	
	ST7735_DrawBitmap(z, k, image2, 20, 20);
	int j = 533333; 
	while(j-- > 0){}; 
	k = k - 1;
  z = z + 1 ; 		
	Output_Clear(); 
	
	}
	
	

 /* ST7735_FillScreen(0xFFFF);            // set screen to white
  ST7735_DrawBitmap(44, 159, Logo, 40, 160);
	IO_Touch(); 
	
  i = 0;
  IO_Touch();
  ST7735_FillScreen(0);            // set screen to black
  while(1){
		IO_Touch(); 
    IO_HeartBeat();
    ST7735_SetCursor(0,i);
    LCD_OutDec(TestData[i]);
    ST7735_SetCursor(11,i);
    LCD_OutFix(TestData[i]);
    i++; 
    if(i==16){
      ST7735_FillScreen(0);            // set screen to black
      i=0;
      IO_Touch();
    }
		//Testing
		
	
		
		
  } */ 
}

