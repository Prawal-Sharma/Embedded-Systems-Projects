;****************** main.s ***************
; Program written by: ***Prawal Sharma**
; Date Created: 9/5/2016
; Last Modified: 9/5/2016
; Section ***Tuesday 3-4
; Instructor: ***Vijay Janappa Reddi
; Lab number: 1
; Brief description of the program:
; The overall objective of this system is a digital lock
; Hardware connections
;  PE3 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE4 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE5 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE2 is LED output (0 means door is locked, 1 means door is unlocked) 
; The specific operation of this system is to 
;   unlock if all three switches are pressed

GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
	    ; Start Clock for Port E
Start	LDR R0, =SYSCTL_RCGCGPIO_R
		LDR R1, [R0]
		ORR R1, #0x10
		STR R1, [R0]
		NOP
		NOP
		; Disable alternate function (pins 2,3,4,5)
		
		LDR R1, =GPIO_PORTE_AFSEL_R 
		LDR R0, [R1]
		BIC R0, #0x3C
		STR R0, [R1]
		; Disable Analog Functions 
		LDR R1, =GPIO_PORTE_AMSEL_R     ; 3) disable analog functionality
		MOV R0, #0                      ; 0 means analog is off
		STR R0, [R1]                    
		LDR R1, =GPIO_PORTE_PCTL_R      ; 4) configure as GPIO
		MOV R0, #0x00000000             ; 0 means configure Port F as GPIO
		STR R0, [R1]                  

		; Initialize Port E
		
		LDR R0, =GPIO_PORTE_DIR_R
		LDR R1, [R0]
		AND R1, R1, #0xC7
		ORR R1, R1, #0x04	; PE2 Output, PE3,4,5 Input
		STR R1, [R0] 
		
		
		
		; Enable Pins
		LDR R0, =GPIO_PORTE_DEN_R 
		LDR R1, [R0]
		
		ORR R1, R1, #0x3C
		
		
		STR R1, [R0]
		
		; Main task portion
		LDR R0, =GPIO_PORTE_DATA_R
		
loop	LDR R1, [R0] 
		AND R1, #0xFFFFFFFB  ;  Initially Clear Pin 2
		AND R1, #0x38	; Isolate pins 3,4,5
		AND R3, #0
		AND R4, #0
		AND R5, #0
		ADD R3, R3, R1	; R3 for pin 3
		ADD R4, R4, R1
		ADD R5, R5, R1
		
		AND R3, #0x08	; Pin 3 isolation
		AND R4, #0x10	; Pin 4 isolation
		AND R5, #0x20 	; Pin 5 isolation
		LSR R4, #1
		LSR R5, #2	; Shift bits to pin 3 position 
		EOR R3, #0x08
		EOR R4, #0x08
		EOR R5, #0x08 ; Not all of the pin bits 
		AND R6, R3, R4
		AND R6, R6, R5
		LSR R6, #1
		LDR R9, [R0] 
		; Store New Lock Status 
		AND R8, #0 
		ADD R8, R8, R9 
		AND R8, #0xFFFFFFFB 
		ORR R6, R6, R8
		
		STR R6, [R0] 
		
		B   loop


      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file