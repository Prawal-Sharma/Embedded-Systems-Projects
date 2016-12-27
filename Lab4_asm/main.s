;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 4
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 3, with three changes:
;1-  initialize SysTick with RELOAD 0x00FFFFFF 
;2-  add a heartbeat to PF2 that toggles every time through loop 
;3-  add debugging dump of input, output, and time
; Operation
;	1) Make PE0 an output and make PE1 an input. 
;	2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over


SWITCH                  EQU 0x40024008  ;PE1
LED                     EQU 0x40024004  ;PE0
SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_RCGC2_GPIOE      EQU 0x00000010   ; port E Clock Gating Control
SYSCTL_RCGC2_GPIOF      EQU 0x00000020   ; port F Clock Gating Control
GPIO_PORTE_DATA_R       EQU 0x400243FC
GPIO_PORTE_DIR_R        EQU 0x40024400
GPIO_PORTE_AFSEL_R      EQU 0x40024420
GPIO_PORTE_PUR_R        EQU 0x40024510
GPIO_PORTE_DEN_R        EQU 0x4002451C
GPIO_PORTF_DATA_R       EQU 0x400253FC
GPIO_PORTF_DIR_R        EQU 0x40025400
GPIO_PORTF_AFSEL_R      EQU 0x40025420
GPIO_PORTF_DEN_R        EQU 0x4002551C
NVIC_ST_CTRL_R          EQU 0xE000E010
NVIC_ST_RELOAD_R        EQU 0xE000E014
NVIC_ST_CURRENT_R       EQU 0xE000E018
NVIC_ST_RELOAD_M      	EQU 0x00FFFFFF  ; Counter load valuere
STORE_R0				EQU 0x20000010  ; for storing register values in subroutines
STORE_R1				EQU 0X20000020
STORE_R2				EQU 0X20000030
STORE_R3				EQU 0X20000040
           THUMB
           AREA    DATA, ALIGN=4
SIZE       EQU    50
;You MUST use these two buffers and two variables
;You MUST not change their names
;These names MUST be exported
           EXPORT DataBuffer  
           EXPORT TimeBuffer  
           EXPORT DataPt [DATA,SIZE=4] 
           EXPORT TimePt [DATA,SIZE=4]
DataBuffer SPACE  SIZE*4
TimeBuffer SPACE  SIZE*4
DataPt     SPACE  4
TimePt     SPACE  4

    
      ALIGN          
      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
      IMPORT  TExaS_Init
	  IMPORT  SysTick_Init


Start BL   TExaS_Init  ; running at 80 MHz, scope voltmeter on PD3

		LDR R0, =SYSCTL_RCGCGPIO_R;  enable clock for Ports E and F
		LDR R1, [R0]
		ORR R1, R1, #0x30
		STR R1, [R0]
		NOP
		NOP

;initialize Port E
		LDR R0, =GPIO_PORTE_DIR_R;	set PE0 to output and PE1 to input
		LDR R1, [R0]
		BIC R1, #0x2
		ORR R1, #0x1
		STR R1, [R0]
	
		LDR R0, =GPIO_PORTE_DEN_R;	enable digital for all pins being used
		LDR R1, [R0]
		ORR R1, #0x3
		STR R1, [R0]
		
; initialize Port F
		LDR R0, =GPIO_PORTF_DIR_R;	set PF2 to output
		LDR R1, [R0]
		ORR R1, #0x4
		STR R1, [R0]
	
		LDR R0, =GPIO_PORTF_DEN_R;	enable digital for all pins being used
		LDR R1, [R0]
		ORR R1, #0x4
		STR R1, [R0]

      CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
	  	
		LDR R0, =GPIO_PORTE_DATA_R; turning LED on
		LDR R1, [R0]
		ORR R1, #0x1
		STR R1, [R0]
		
		BL Debug_Init; initialize debugging dump, including SysTick
		
loop    BL Debug_Capture
hbeat	LDR R0, =GPIO_PORTF_DATA_R; heartbeat
		LDR R1, [R0]
		EOR R1, #0x4
		STR R1, [R0]
		
; Delay 
loop1	MOV R3, #372; creating timer with SUBS operation, maybe 413 here?
more1	MOV R2, #4000
again1	SUBS R2, R2, #1
		BNE again1
		SUBS R3, R3, #1
		BNE more1

;poll switch and toggle if needed
		LDR R0, =GPIO_PORTE_DATA_R
		LDR R1, [R0]
		CMP R1, #0x2
		BHS toggle
		ORR R1, #1
		STR R1, [R0]
		B loop
toggle	EOR R1, #1
		STR R1, [R0]
		B loop


;------------Debug_Init------------
; Initializes the debugging instrument
; Input: none
; Output: none
; Modifies: none
; Note: push/pop an even number of registers so C compiler is happy
Debug_Init
		LDR R4, =STORE_R0; store register values in memory
		STR R0, [R4]
		STR R1, [R4, #1]
		STR R2, [R4, #2]
		STR R3, [R4, #3]
		
		LDR R0, =DataPt; initialize data
		LDR R1, =DataBuffer
		STR R1, [R0]
		MOV R3, #0
clear1	MOV R2, #0xFFFFFFFF		
		LDR R0, =DataPt
		LDR R1, [R0]
		STR R2, [R1]
		ADD R1, #4
		STR R1, [R0]
		ADD R3, #1
		CMP R3, #50
		BNE clear1
		LDR R0, =DataPt
		LDR R1, =DataBuffer
		STR R1, [R0]
			
		LDR R0, =TimePt; initialize time
		LDR R1, =TimeBuffer
		STR R1, [R0]
		MOV R3, #0
clear2	MOV R2, #0xFFFFFFFF		
		LDR R0, =TimePt
		LDR R1, [R0]
		STR R2, [R1]
		ADD R1, #4
		STR R1, [R0]
		ADD R3, #1
		CMP R3, #50
		BNE clear2
		LDR R0, =TimePt
		LDR R1, =TimeBuffer
		STR R1, [R0]
      
		B SysTick_Init; init SysTick
		
		LDR R4, =STORE_R0; restore registers
		LDR R0, [R4]
		LDR R1, [R4, #1]
		LDR R2, [R4, #2]
		LDR R3, [R4, #3]
		
      BX LR

;------------Debug_Capture------------
; Dump Port E and time into buffers
; Input: none
; Output: none
; Modifies: none
; Note: push/pop an even number of registers so C compiler is happy
Debug_Capture
		LDR R4, =STORE_R0; store register values in memory
		STR R0, [R4]
		STR R1, [R4, #1]
		STR R2, [R4, #2]
		STR R3, [R4, #3]
		
		LDR R0, =DataPt; check if buffers are full
		LDR R0, [R0]
		LDR R1, =DataBuffer
		ADD R1, #200
		CMP R1, R0
		BLS exit
		LDR R0, =TimePt
		LDR R0, [R0]
		LDR R1, =TimeBuffer
		ADD R1, #200
		CMP R1, R0
		BLS exit
		
		LDR R0, =GPIO_PORTE_DATA_R
		LDR R0, [R0]
		AND R1, R0, #0x1; mask all but bit 0
		AND R2, R0, #0x2; mask all but bit 1
		LSL R2, R2, #3; shift bit 1 over to bit 4
		ADD R0, R1, R2; add bit 0 and new bit 4
		LDR R1, =DataPt
		LDR R2, [R1]
		STR R0, [R2]; store data into current memory location in buffer
		ADD R2, #4; increment pointer
		STR R2, [R1]; store new pointer value
		
		LDR R0, =NVIC_ST_CURRENT_R
		LDR R0,[R0]
		LDR R1, =TimePt
		LDR R2, [R1]
		STR R0, [R2]
		ADD R2, #4
		STR R2, [R1]

exit	LDR R4, =STORE_R0; restore registers
		LDR R0, [R4]
		LDR R1, [R4, #1]
		LDR R2, [R4, #2]
		LDR R3, [R4, #3]

		BX LR


    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
        