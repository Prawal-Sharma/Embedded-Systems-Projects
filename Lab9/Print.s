; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 
Counter 			EQU 		-4
NumTen  			EQU 		-4
	
    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
	PRESERVE8

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
			PUSH {R11}
			MOV R11, SP
			ADD SP,#Counter
			
			
			
			PUSH {R4-R11}
			MOV R6, R0
			MOV R7, #10
			

			MOV R10, #0			;COUNTER 
			MOV R1, R6
loopOD1		UDIV R1, R1, R7
			CMP R1, #0
			ADD R10, #1
			BNE loopOD1
			STR R10, [R11,#Counter]
			SUBS R10, #1
			BNE loopOD4
			ADD R0, #0x30			;MAKING IT A CHARACTER
			PUSH {LR,r1-r3}
			BL ST7735_OutChar
			POP {LR,r1-r3}
			POP {R4-R11}
			BX LR
loopOD4		MOV R2, R7
loopOD2		SUBS R10, #1
			BEQ loopOD3
			MUL r2,r7
			B loopOD2
loopOD3		UDIV R4, R6, R2
			MUL R5, R4, R2
			SUB R5, R6, R5
			MOV R0, R4
			ADD R0, #0x30			;MAKING IT A CHARACTER
			PUSH {LR,r1-r3}
			BL ST7735_OutChar
			POP {LR,r1-r3}
			MOV R6, R5
			UDIV R2, R7
			CMP R2, #0
			BNE loopOD3
			POP {R4-R11}
			
			MOV SP,R11 
			POP {R11}


      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
			PUSH {R11}
			MOV R11,SP
			ADD SP,#NumTen
			
			PUSH {R4-R11}
			MOV R7, #10
			STR R7,[R11,#NumTen]
			MOV R9, #1000
			MOV R8, #100
			UDIV R1, R0, R8
			UDIV R1, R1, R8
			CMP R1, #0
			BNE loopOF1
			MOV R4, R0
			
			UDIV R2, R4, R9
			MUL R10, R2, R9
			SUB R10, R4, R10
			MOV R0, R2
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2E
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			
			UDIV R9, R7
			MOV R4, R10
			UDIV R2, R4, R9
			MUL R10, R2, R9
			SUB R10, R4, R10
			MOV R0, R2
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			
			UDIV R9, R7
			MOV R4, R10
			UDIV R2, R4, R9
			MUL R10, R2, R9
			SUB R10, R4, R10
			MOV R0, R2
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			
			MOV R0, R10
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			POP {R4-R11}
			
			MOV SP,R11
			POP {R11}
			BX LR
			
			
			
			
			
loopOF1		MOV R0, #0x2A
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2E
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2A
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2A
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2A
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			POP {R4-R11}

     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
