; IO.s
; Student names: Prawal Sharma 
; Last modification date: 10/22/16
; Runs on LM4F120/TM4C123

; EE319K lab 7 device driver for the switch and LED.
; You are allowed to use any switch and any LED,
; although the Lab suggests the SW1 switch PF4 and Red LED PF1

; As part of Lab 7, students need to implement these three functions

; negative logic SW2 connected to PF0 on the Launchpad
; red LED connected to PF1 on the Launchpad
; blue LED connected to PF2 on the Launchpad
; green LED connected to PF3 on the Launchpad
; negative logic SW1 connected to PF4 on the Launchpad

        EXPORT   IO_Init
        EXPORT   IO_Touch
        EXPORT   IO_HeartBeat
		IMPORT   Delay1ms

GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
PF0       EQU 0x40025004
PF1       EQU 0x40025008
PF2       EQU 0x40025010
PF3       EQU 0x40025020
PF4       EQU 0x40025040
LEDS      EQU 0x40025038
RED       EQU 0x02
BLUE      EQU 0x04
GREEN     EQU 0x08
SWITCHES  EQU 0x40025044
SW1       EQU 0x10                 ; on the left side of the Launchpad board
SW2       EQU 0x01                 ; on the right side of the Launchpad board
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
    
        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
		PRESERVE8



;------------IO_Init------------
; Initialize GPIO Port for a switch and an LED
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Init
; Save Registers R4-R11 and LR on stack
	PUSH {R4-R11, LR}
; Turn Clock on for Port F	
	LDR R0, =SYSCTL_RCGCGPIO_R 
	LDR R1, [R0]
	ORR R1, #0x20
	STR R1, [R0]
	NOP
	NOP
	
   LDR R1, =GPIO_PORTF_AFSEL_R
   LDR R0, [R1]
   BIC R0, R0, #0x12
   STR R0, [R1]
   
; Initialize Port F

	LDR R0, =GPIO_PORTF_PUR_R
	LDR R1, [R0]
	ORR R1, #0x10; enabling PUR on PF4
	STR R1, [R0]

; Set PF4 as input and PF1 (red LED) to output
	LDR R0, =GPIO_PORTF_DIR_R 
	LDR R1, [R0] 
	ORR R1, #0x02 ; Make PF1 an output
	BIC R1, #0x10 ; Make PF4 an input
	STR R1, [R0] ; Update State
	
; Enable the used pins for Port-F 

	LDR R0, =GPIO_PORTF_DEN_R
	LDR R1, [R0]
	ORR R1, #0x12 ; Set Bits 1 and 4 high to enable
	STR R1, [R0] ; Update status 

; Restore registers before exiting 
	POP {R4-R11, LR}   
   BX  LR
	
;* * * * * * * * End of IO_Init * * * * * * * *

;------------IO_HeartBeat------------
; Toggle the output state of the LED.
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_HeartBeat

; Store Potential Registers on Stack 
	PUSH {R4-R11, LR}

; Toggle the Heartbeat 
	LDR R0, =GPIO_PORTF_DATA_R
	LDR R1, [R0] 
    EOR R1, #0x02 ; Toggle PF1 
	STR R1, [R0] ; Update Status 

; Restore Registers 
	POP {R4-R11, LR}
	BX  LR                          ; return
;* * * * * * * * End of IO_HeartBeat * * * * * * * *

;------------IO_Touch------------
; First: wait for the release of the switch
; and then: wait for the touch of the switch
; Input: none
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Touch
	PUSH {R4-R11, LR}
	
Again		LDR R0, =GPIO_PORTF_DATA_R
			LDR R1, [R0] 
			AND R1, #0x10 ; Mask PF4 (switch) 
			CMP R1, #0x10 ; Check to see if switch is released, release means (1) 
			BNE Again  
			B Next
		
Delay_1		MOV R3, #10
Delay_11	BL Delay1ms
			SUBS R3, #1
			BNE Delay_11
			B Again 

Next		LDR R0, =GPIO_PORTF_DATA_R
			LDR R1, [R0]
			AND R1, #0x10 ; Mask PF4 (switch) 
			CMP R1, #0x10 ; Check to see if switch has been pressed (pressed means 0)
			BEQ Next
			B Next_2

Delay_2		MOV R3, #10
Delay_22	BL Delay1ms
			SUBS R3, #1
			BNE Delay_22
			B Next



		
Next_2
	POP {R4-R11, LR}
    BX  LR                          ; return









                         ; return
;* * * * * * * * End of IO_Touch * * * * * * * *

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file