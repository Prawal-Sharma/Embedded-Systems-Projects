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

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
	
; *********Binding phase**********
num	EQU 0
depth EQU 4 

    AREA    |.text|, CODE, READONLY, ALIGN=2
	;PRESERVE8 
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	PUSH {LR, R0}
; ******Allocation Phase*******	
	SUB SP, #8 ; Allocate num

; *****Access Phase*******
	CMP R0, #10
	BLO baseOutDec
	MOV R3, #0xa
	UDIV R2, R0, R3
	MLS R1, R2, R3, R0 
	MOV R0, R2
	STR R1, [SP, #num]
	BL LCD_OutDec
	LDR R0, [SP, #num]
	ADD R0, #0x30
	BL ST7735_OutChar
	B returnOutDec
baseOutDec
	ADD R0, #0x30
	BL ST7735_OutChar
returnOutDec


;****Deallocation Phase*****	
	ADD SP, #8
		
	POP {LR, R0}


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
	MOV R1, #0
LCD_OutFix_Wrap
	PUSH {LR, R4, R1, R0}
	
; ******Allocation Phase*******	
	SUB SP, #8 ; Allocate num

; *****Access Phase*******
	MOV R4, #10000
	CMP R0, R4
	BHS stars
	CMP R1, #4
	BEQ returnOutFix
	MOV R3, #0xa
	UDIV R2, R0, R3
	MLS R4, R2, R3, R0 
	MOV R0, R2
	STR R4, [SP, #num]
	STR R1, [SP, #depth]
	ADD R1, #1
	BL LCD_OutFix_Wrap
	LDR R0, [SP, #num]
	ADD R0, #0x30
	BL ST7735_OutChar
	LDR R1, [SP, #depth]
	CMP R1, #3
	BNE returnOutFix
	MOV R0, #0x2E
	BL ST7735_OutChar
	B returnOutFix
stars
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2E
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
returnOutFix

	
;****Deallocation Phase*****	
	ADD SP, #8
	
	
	POP {LR, R4, R1, R0}


     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
