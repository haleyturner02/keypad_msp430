;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
; Zach Becker, Haley Turner, EELE 465, Project 03
; Keypad Polling and Routines
;
; Feb 2023
;
; REGISTER USE LEGEND
; R4- Register for column number
; R5- Register for row number
; R6- Register for input data from keypad
; R7- Register for inner delay loop counter
; R8- Register for outer delay loop counter
; R9- Register for PressB binary counter
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

init:

	bis.b	#BIT0, &P1DIR					; Initialize LED1 as output
	bic.b	#BIT0, &P1OUT					; Start LED1 off

	bis.b	#BIT6, &P6DIR					; Initialize LED2 as output
	bic.b	#BIT6, &P6OUT					; Start LED2 off

; LED1 and LED2 on MSP430 used for temporary testing

	bis.b	#BIT0, &P6DIR					; Initialize P6.0 as output (LED 0)
	bic.b	#BIT0, &P6OUT					; Start P6.0 off

	bis.b	#BIT1, &P6DIR					; Initialize P6.1 as output (LED 1)
	bic.b	#BIT1, &P6OUT					; Start P6.1 off

	bis.b	#BIT2, &P6DIR					; Initialize P6.2 as output (LED 2)
	bic.b	#BIT2, &P6OUT					; Start P6.2 off

	bis.b	#BIT3, &P6DIR					; Initialize P6.3 as output (LED 3)
	bic.b	#BIT3, &P6OUT					; Start P6.3 off

	bis.b	#BIT4, &P6DIR					; Initialize P6.4 as output (LED 4)
	bic.b	#BIT4, &P6OUT					; Start P6.4 off

	bis.b	#BIT0, &P2DIR					; Initialize P2.0 as output (LED 5)
	bic.b	#BIT0, &P2OUT					; Start P2.0 off

	bis.b	#BIT1, &P2DIR					; Initialize P2.1 as output (LED 6)
	bic.b	#BIT1, &P2OUT					; Start P2.1 off

	bis.b	#BIT2, &P2DIR					; Initialize P2.2 as output (LED 7)
	bic.b	#BIT2, &P2OUT					; Start P2.2 off

	mov.w	#0, R4							; Clear register data for column
	mov.w	#0, R5							; Clear register data for row
	mov.w	#0, R6							; Clear register data for keypad input
	mov.w	#0, R9							; Clear register data for PressB binary counter

	bic.b	#LOCKLPM5, &PM5CTL0				; Disable GPIO power-on default high_Z mode


main:

	mov.w	#0777h, R8					; Initialize outer delay loop counter (small delay for button response time)
	call	#Delay

	call 	#ColumnInput				; Change columns to be inputs, rows to be outputs
	call	#CheckKeypad				; Check if/what key is pressed

FindButton:

	cmp.b	#0087h, R4					; Check if '1' was pressed
	cmp.b	#0083h, R4					; Check if '2' was pressed
	cmp.b	#0081h, R4					; Check if '3' was pressed
	cmp.b	#0080h, R4					; Check if 'A' was pressed
	jz		PressA
	cmp.b	#0047h, R4					; Check if '4' was pressed
	cmp.b	#0043h, R4					; Check if '5' was pressed
	cmp.b	#0041h, R4					; Check if '6' was pressed
	cmp.b	#0040h, R4					; Check if 'B' was pressed
	jz		PressB
	cmp.b	#0027h, R4					; Check if '7' was pressed
	cmp.b	#0023h, R4					; Check if '8' was pressed
	cmp.b	#0021h, R4					; Check if '9' was pressed
	cmp.b	#0020h, R4					; Check if 'C' was pressed
	jz		PressC
	cmp.b	#0017h, R4					; Check if '*' was pressed
	cmp.b	#0013h, R4					; Check if '0' was pressed
	cmp.b	#0011h, R4					; Check if '#' was pressed
	cmp.b	#0010h, R4					; Check if 'D' was pressed

	mov.w	#0, R4						; Clear register data for column
	mov.w	#0, R5						; Clear register data for row

	jmp		main

;-------------------------------------------------------------------------------
; Subroutine: PressA
;-------------------------------------------------------------------------------

PressA:									; Use LED bar to make XOXOXOXO pattern

	xor.b	#BIT0, &P6OUT				; Toggle LED 0 if 'A' pressed
	xor.b	#BIT2, &P6OUT				; Toggle LED 2 if 'A' pressed
	xor.b	#BIT4, &P6OUT				; Toggle LED 4 if 'A' pressed
	xor.b	#BIT1, &P2OUT				; Toggle LED 6 if 'A' pressed
	jmp		main

;-------------------------- END PressA -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: PressB
;-------------------------------------------------------------------------------

PressB:

	xor.b	#BIT0, &P1OUT				; Toggle LED1 if 'B' pressed
	bic.b	#BIT0, &P6OUT				; Turn off LED 0
	bic.b	#BIT2, &P6OUT				; Turn off LED 2
	bic.b	#BIT4, &P6OUT				; Turn off LED 4
	bic.b	#BIT1, &P2OUT				; Turn off LED 6

	inc.b	R9							; Increase binary counter in R9
	cmp.b	#256, R9					; Check if binary counter has reached 256
	jz		ResetB						; Reset counter to 0 if R9 holds 256
	call	#BinaryCounter				; Display binary counter value on LED bar

	mov.w	#0, R4						; Clear register data for column
	mov.w	#0, R5						; Clear register data for row

	mov.w	#0FFFh, R8					; Delay for binary counter display
	call	#Delay

	call 	#ColumnInput				; Change columns to be inputs, rows to be outputs
	call	#CheckKeypad				; Check if another key has been pressed

	cmp.b	#0, R4
	jz		PressB						; Continue PressB subroutine if no new key pressed

	cmp.b	#0040h, R4
	jz		ResetB						; Reset counter if 'B' pressed again

	jmp		FindButton					; Return to FindButton if new key pressed

;-------------------------- END PressB -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ResetB
;-------------------------------------------------------------------------------

ResetB:

	mov.b	#0, R9						; Move 0 into R9 to reset binary counter
	jmp		PressB

;-------------------------- END ResetB -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: BinaryCounter
;-------------------------------------------------------------------------------

BinaryCounter:

	bit.b	#BIT0, R9					; Check if BIT0 is set in binary counter
	jnz		SetLED0						; Jump to SetLED0 label if BIT0 is set
	bic.b	#BIT0, &P6OUT				; Clear LED0 if BIT0 is not set

LED1:

	bit.b	#BIT1, R9					; Check if BIT1 is set in binary counter
	jnz		SetLED1						; Jump to SetLED1 label if BIT1 is set
	bic.b	#BIT1, &P6OUT				; Clear LED1 if BIT1 is not set

LED2:

	bit.b	#BIT2, R9 					; Check if BIT2 is set in binary counter
	jnz		SetLED2						; Jump to SetLED2 label if BIT2 is set
	bic.b	#BIT2, &P6OUT				; Clear LED2 if BIT2 is not set

LED3:

	bit.b	#BIT3, R9					; Check if BIT3 is set in binary counter
	jnz		SetLED3						; Jump to SetLED3 label if BIT3 is set
	bic.b	#BIT3, &P6OUT				; Clear LED3 if BIT3 is not set

LED4:

	bit.b	#BIT4, R9					; Check if BIT4 is set in binary counter
	jnz		SetLED4						; Jump to SetLED4 label if BIT4 is set
	bic.b	#BIT4, &P6OUT				; Clear LED4 if BIT4 is not set

LED5:

	bit.b	#BIT5, R9					; Check if BIT5 is set in binary counter
	jnz		SetLED5						; Jump to SetLED5 label if BIT5 is set
	bic.b	#BIT0, &P2OUT				; Clear LED5 if BIT5 is not set

LED6:

	bit.b	#BIT6, R9					; Check if BIT6 is set in binary counter
	jnz		SetLED6						; Jump to SetLED6 label if BIT6 is set
	bic.b	#BIT1, &P2OUT				; Clear LED6 if BIT6 is not set

LED7:

	bit.b	#BIT7, R9					; Check if BIT7 is set in binary counter
	jnz		SetLED7						; Jump to SetLED7 label if BIT7 is set
	bic.b	#BIT2, &P2OUT				; Clear LED7 if BIT7 is not set

	ret									; Return to PressB subroutine

SetLED0:

	bis.b	#BIT0, &P6OUT				; Set LED0
	jmp		LED1						; Jump to LED1 label to check next bit in counter


SetLED1:

	bis.b	#BIT1, &P6OUT				; Set LED0
	jmp		LED2						; Jump to LED2 label to check next bit in counter


SetLED2:

	bis.b	#BIT2, &P6OUT				; Set LED1
	jmp		LED3						; Jump to LED3 label to check next bit in counter

SetLED3:

	bis.b	#BIT3, &P6OUT				; Set LED2
	jmp		LED4						; Jump to LED4 label to check next bit in counter

SetLED4:

	bis.b	#BIT4, &P6OUT				; Set LED3
	jmp		LED5						; Jump to LED5 label to check next bit in counter

SetLED5:

	bis.b	#BIT0, &P2OUT				; Set LED4
	jmp		LED6						; Jump to LED6 label to check next bit in counter

SetLED6:

	bis.b	#BIT1, &P2OUT				; Set LED5
	jmp		LED7						; Jump to LED7 label to check next bit in counter

SetLED7:

	bis.b	#BIT2, &P2OUT				; Set LED6
	ret									; Return to PressB subroutine

;-------------------------- END BinaryCounter ----------------------------------

;-------------------------------------------------------------------------------
; Subroutine: PressC
;-------------------------------------------------------------------------------

PressC:

	xor.b	#BIT6, &P6OUT				; Toggle LED2 if 'C' pressed
	jmp		main

;-------------------------- END PressC -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: Delay
;-------------------------------------------------------------------------------

Delay:

	mov.w	#50, R7

InnerDelay:

	dec.w	R7
	jnz		InnerDelay
	dec.w	R8
	jnz		Delay

	ret

;-------------------------- END Delay ------------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: CheckKeypad
;-------------------------------------------------------------------------------

CheckKeypad:

	mov.b	&P3IN, R6					; Move keypad input byte from Port 3 to R6
	call	#CheckColumn				; Call subroutine to check which column was pressed

	call	#RowInput					; Change rows to be inputs, columns to be outputs

	mov.b	&P3IN, R6					; Move keypad input byte from Port 3 to R6
	call	#CheckRow					; Call subroutine to check which row was pressed

	call	#ColumnInput				; Change columns back to inputs, rows to be outputs

	add.b	R5, R4						; Concatenate column and row bits and put into R4

	ret

;-------------------------- END CheckKeypad ------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: CheckColumn
;-------------------------------------------------------------------------------

CheckColumn:

	bit.b	#BIT0, R6					; Test if bit 0 is set (column 4)
	jnz		Column4

	bit.b	#BIT1, R6					; Test if bit 1 is set (column 3)
	jnz		Column3

	bit.b	#BIT2, R6					; Test if bit 2 is set (column 2)
	jnz		Column2

	bit.b	#BIT3, R6					; Test if bit 3 is set (column 3)
	jnz		Column1

	cmp.b	#0, R6
	jz		NoColumn

	ret


Column1:

	mov.w	#00F8h, R4					; Move F8h into R4 if column 1 pressed
	ret

Column2:

	mov.w	#00F4h, R4					; Move F4h into R4 if column 2 pressed
	ret

Column3:

	mov.w	#00F2h, R4					; Move F2h into R4 if column 3 pressed
	ret

Column4:

	mov.w	#00F1h, R4					; Move F1h into R4 if column 4 pressed
	ret

NoColumn:

	mov.w	#0, R4						; Clear register data for column
	ret

;-------------------------- END CheckColumn ------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: CheckRow
;-------------------------------------------------------------------------------

CheckRow:

	bit.b	#BIT4, R6					; Test if bit 4 is set (row 4)
	jnz		Row4

	bit.b	#BIT5, R6					; Test if bit 5 is set (row 3)
	jnz		Row3

	bit.b	#BIT6, R6					; Test if bit 6 is set (row 2)
	jnz		Row2

	bit.b	#BIT7, R6					; Test if bit 7 is set (row 1)
	jnz		Row1

	cmp.b	#0, R6
	jz		NoRow

	ret

Row1:

	mov.w	#008Fh, R5					; Move 8Fh into R5 if row 1 pressed
	ret

Row2:

	mov.w	#004Fh, R5					; Move 4Fh into R5 if row 2 pressed
	ret

Row3:

	mov.w	#002Fh, R5					; Move 2Fh into R5 if row 3 pressed
	ret

Row4:

	mov.w	#001Fh, R5					; Move 1Fh into R5 if row 4 pressed
	ret

NoRow:

	mov.w	#0, R5						; Clear register data for row
	ret

;-------------------------- END CheckRow ---------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: RowInput
;-------------------------------------------------------------------------------

RowInput:

	bic.b 	#BIT4, &P3DIR					; Initialize P3.4 as input
	bis.b	#BIT4, &P3REN					; Enable pull up/down resistor for P3.4
	bic.b	#BIT4, &P3OUT					; Configure resistor as pull down

	bic.b	#BIT5, &P3DIR					; Intialize P3.5 as input
	bis.b	#BIT5, &P3REN					; Enable pull up/down resistor for P3.5
	bic.b	#BIT5, &P3OUT					; Configure resistor as pull down

	bic.b	#BIT6, &P3DIR					; Initialize P3.6 as input
	bis.b	#BIT6, &P3REN					; Enable pull up/down resistor for P3.6
	bic.b	#BIT6, &P3OUT					; Configure resistor as pull down

	bic.b	#BIT7, &P3DIR					; Initialize P3.7 as input
	bis.b	#BIT7, &P3REN					; Enable pull up/down resistor for P3.7
	bic.b	#BIT7, &P3OUT					; Configure resistor as pull down

	bis.b	#BIT0, &P3DIR					; Initialize P3.0 as output
	bis.b	#BIT0, &P3OUT					; Set P3.0 to be on

	bis.b	#BIT1, &P3DIR					; Initialize P3.1 as output
	bis.b	#BIT1, &P3OUT					; Set P3.1 to be on

	bis.b	#BIT2, &P3DIR					; Initialize P3.2 as output
	bis.b	#BIT2, &P3OUT					; Set P3.2 to be on

	bis.b	#BIT3, &P3DIR					; Initialize P3.3 as output
	bis.b	#BIT3, &P3OUT					; Set P3.3 to be on

	ret

;-------------------------- END RowInput ---------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ColumnInput
;-------------------------------------------------------------------------------

ColumnInput:

	bic.b 	#BIT0, &P3DIR					; Initialize P3.0 as input
	bis.b	#BIT0, &P3REN					; Enable pull up/down resistor for P3.0
	bic.b	#BIT0, &P3OUT					; Configure resistor as pull down

	bic.b	#BIT1, &P3DIR					; Intialize P3.1 as input
	bis.b	#BIT1, &P3REN					; Enable pull up/down resistor for P3.1
	bic.b	#BIT1, &P3OUT					; Configure resistor as pull down

	bic.b	#BIT2, &P3DIR					; Initialize P3.2 as input
	bis.b	#BIT2, &P3REN					; Enable pull up/down resistor for P3.2
	bic.b	#BIT2, &P3OUT					; Configure resistor as pull down

	bic.b	#BIT3, &P3DIR					; Initialize P3.3 as input
	bis.b	#BIT3, &P3REN					; Enable pull up/down resistor for P3.3
	bic.b	#BIT3, &P3OUT					; Configure resistor as pull down

	bis.b	#BIT4, &P3DIR					; Initialize P3.4 as output
	bis.b	#BIT4, &P3OUT					; Set P3.4 to be on

	bis.b	#BIT5, &P3DIR					; Initialize P3.5 as output
	bis.b	#BIT5, &P3OUT					; Set P3.5 to be on

	bis.b	#BIT6, &P3DIR					; Initialize P3.6 as output
	bis.b	#BIT6, &P3OUT					; Set P3.6 to be on

	bis.b	#BIT7, &P3DIR					; Initialize P3.7 as output
	bis.b	#BIT7, &P3OUT					; Set P3.7 to be on

	ret

;-------------------------- END ColumnInput ------------------------------------


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET

