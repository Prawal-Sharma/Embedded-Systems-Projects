;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 3
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 2, with six changes:
;1-  the pin to which we connect the switch is moved to PE1, 
;2-  you will have to remove the PUR initialization because pull up is no longer needed. 
;3-  the pin to which we connect the LED is moved to PE0, 
;4-  the switch is changed from negative to positive logic, and 
;5-  you should increase the delay so it flashes about 8 Hz.
;6-  the LED should be on when the switch is not pressed
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over


GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
       IMPORT  TExaS_Init
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
 ; TExaS_Init sets bus clock at 80 MHz
      BL  TExaS_Init ; voltmeter, scope on PD3
		LDR R0, =SYSCTL_RCGCGPIO_R;  enable clock
		LDR R1, [R0]
		ORR R1, R1, #0x10
		STR R1, [R0]
		NOP
		NOP
		

		LDR R0, =GPIO_PORTE_DIR_R;	set PE0 to output and PE1 to input
		LDR R1, [R0]
		AND R1, #0x0 ; Why clear r1? 
		ORR R1, #0x1 ; Didn't make PE1 an input AND R1, #0xFD
		STR R1, [R0]
	
		LDR R0, =GPIO_PORTE_DEN_R;	enable digital for all pins being used
		LDR R1, [R0]
		ORR R1, #0x3
		STR R1, [R0]; you initialize PE1 PE0


      CPSIE  I    ; TExaS voltmeter, scope runs on interrupts

		LDR R0, =GPIO_PORTE_DATA_R
		LDR R1, [R0]
		ORR R1, #0x1
		STR R1, [R0]
		MOV R3, #1

		BL loop2
		
poll	LDR R0, =GPIO_PORTE_DATA_R
		LDR R1, [R0]
		CMP R1, #0x2
		BHS loop1
		ORR R1, #1
		STR R1, [R0]
		B poll
  
loop1	MOV R3, #413; creating timer with SUBS operation
more1	MOV R2, #4000
again1	SUBS R2, R2, #1
		BNE again1
		SUBS R3, R3, #1
		BNE more1		
		LDR R0, =GPIO_PORTE_DATA_R
		LDR R1, [R0]
		EOR R1, #1
		STR R1, [R0]
		BX LR;; your input output delay
		
loop2	MOV R3, #413; creating timer with SUBS operation
more2	MOV R2, #4000
again2	SUBS R2, R2, #1
		BNE again2
		SUBS R3, R3, #1
		BNE more2
		BX LR;; your input output delay




      ALIGN      ; make sure the end of this section is aligned
      END        ; end of file
       