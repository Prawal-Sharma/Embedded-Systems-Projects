;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 *****
; Last Modified: 1/22/2016 *******
; Section: Tuesday 3-4
; Instructor: Vijay Janapa Reddi
; Lab number: 2
; Brief description of the program
; The overall objective of this system an interactive alarm
; Hardware connections
;  PF4 is switch input  (1 means SW1 is not pressed, 0 means SW1 is pressed)
;  PF3 is LED output (1 activates green LED) 
; The specific operation of this system 
;    1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;    2) The system starts with the LED OFF (make PF3 =0). 
;    3) Delay for about 100 ms
;    4) If the switch is pressed (PF4 is 0), then toggle the LED once, else turn the LED OFF. 
;    5) Repeat steps 3 and 4 over and over

GPIO_PORTF_DATA_R       EQU   0x400253FC
GPIO_PORTF_DIR_R        EQU   0x40025400
GPIO_PORTF_AFSEL_R      EQU   0x40025420
GPIO_PORTF_PUR_R        EQU   0x40025510
GPIO_PORTF_DEN_R        EQU   0x4002551C
GPIO_PORTF_AMSEL_R      EQU   0x40025528
GPIO_PORTF_PCTL_R       EQU   0x4002552C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
		LDR R0, =SYSCTL_RCGCGPIO_R;  enable clock
		LDR R1, [R0]
		ORR R1, R1, #0x20
		STR R1, [R0]
		NOP
		NOP
		
		LDR R0, =GPIO_PORTF_PUR_R
		LDR R1, [R0]
		ORR R1, #0x10; enabling PUR on PF4
		STR R1, [R0]
		
		LDR R0, =GPIO_PORTF_DIR_R;	set PE3 to output and others to input
		LDR R1, [R0]
		ORR R1, #0x8
		AND R1, #0xEF
		STR R1, [R0]
	
		LDR R0, =GPIO_PORTF_DEN_R;	enable digital for all pins being used
		LDR R1, [R0]
		ORR R1, #0x18
		
		STR R1, [R0]
	

loop  
poll	LDR R0, =GPIO_PORTF_DATA_R
		LDR R1, [R0]
		CMP R1, #0xF; determining if the switch is being pressed
		BPL clear
		EOR R1, #0x8
		STR R1, [R0]
		BL delay; goes to delay subroutine if switch is pressed
		
		B   poll
clear	BIC R1, #0x8; clears output (turns LED off) if the button is not being pressed
		STR R1, [R0]
		B   poll
		
delay	MOV R3, #100; creating timer with SUBS operation
more	MOV R2, #4000
again	SUBS R2, R2, #1
		BNE again
		SUBS R3, R3, #1
		BNE more
		BX LR;
	
       B    loop


       ALIGN      ; make sure the end of this section is aligned
       END        ; end of file