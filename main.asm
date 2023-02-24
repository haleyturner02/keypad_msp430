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
; R10- Register for PressC rotating counter
; R11- Register for PressA toggle counter
; R12- Register for PressD sequence counter
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
	mov.w	#0, R10							; Clear register data for PressC rotating counter
	mov.w	#0, R11							; Clear register data for PressA toggle counter
	mov.w	#0, R12							; Clear register data for PressD sequence counter

	bic.b	#LOCKLPM5, &PM5CTL0				; Disable GPIO power-on default high_Z mode


main:

	mov.w	#0777h, R8					; Initialize outer delay loop counter (small delay for button response time)
	call	#Delay

	call 	#ColumnInput				; Change columns to be inputs, rows to be outputs
	call	#CheckKeypad				; Check if/what key is pressed

FindButton:

	call	#ResetLED

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
	jz		PressD

	mov.w	#0, R4						; Clear register data for column
	mov.w	#0, R5						; Clear register data for row

	jmp		main

;-------------------------------------------------------------------------------
; Subroutine: PressA
;-------------------------------------------------------------------------------

PressA:									; Use LED bar to make XOXOXOXO pattern

	inc.b	R11							; Increase toggle counter in R11
	cmp.b	#2, R11						; Check if toggle counter is 1 or 2
	jz		ResetA						; Reset counter and turn off LEDs if R11 holds 2
	call	#SetLED0					; Set LED 0 if R11 holds 1
	call	#SetLED2					; Set LED 2 if R11 holds 1
	call 	#SetLED4					; Set LED 4 if R11 holds 1
	call	#SetLED6					; Set LED 6 if R11 holds 1

StaticCont:

	mov.w	#0, R4						; Clear register data for column
	mov.w	#0, R5						; Clear register data for row

	mov.w	#0FFFh, R8					; Delay for binary counter display
	call	#Delay

	call 	#ColumnInput				; Change columns to be inputs, rows to be outputs
	call	#CheckKeypad				; Check if another key has been pressed

	cmp.b	#0, R4
	jz		StaticCont					; Jump to StaticCont if no new key pressed

	cmp.b	#0080h, R4
	jz		PressA						; Jump back to PressA if 'A' pressed again

	jmp		FindButton					; Return to FindButton if new key pressed

	jmp		main

;-------------------------- END PressA -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ResetA
;-------------------------------------------------------------------------------

ResetA:

	call	#ResetLED
	mov.w	#0, R11
	jmp		StaticCont

;-------------------------- END ResetA -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: PressB
;-------------------------------------------------------------------------------

PressB:

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

	bic.b	#BIT0, &P6OUT
	bit.b	#BIT0, R9					; Check if BIT0 is set in binary counter
	jz		BC_LED1
	call	#SetLED0


BC_LED1:

	bic.b	#BIT1, &P6OUT
	bit.b	#BIT1, R9					; Check if BIT1 is set in binary counter
	jz	 	BC_LED2
	call	#SetLED1


BC_LED2:

	bic.b	#BIT2, &P6OUT
	bit.b	#BIT2, R9 					; Check if BIT2 is set in binary counter
	jz	 	BC_LED3
	call	#SetLED2


BC_LED3:

	bic.b	#BIT3, &P6OUT
	bit.b	#BIT3, R9					; Check if BIT3 is set in binary counter
	jz		BC_LED4
	call	#SetLED3


BC_LED4:

	bic.b	#BIT4, &P6OUT
	bit.b	#BIT4, R9					; Check if BIT4 is set in binary counter
	jz		BC_LED5
	call	#SetLED4


BC_LED5:

	bic.b	#BIT0, &P2OUT
	bit.b	#BIT5, R9					; Check if BIT5 is set in binary counter
	jz		BC_LED6
	call	#SetLED5


BC_LED6:

	bic.b	#BIT1, &P2OUT
	bit.b	#BIT6, R9					; Check if BIT6 is set in binary counter
	jz		BC_LED7
	call	#SetLED6

BC_LED7:

	bic.b	#BIT2, &P2OUT
	bit.b	#BIT7, R9					; Check if BIT7 is set in binary counter
	jz		ReturnToPressB
	call	#SetLED7

ReturnToPressB:

	ret									; Return to PressB subroutine


;-------------------------- END BinaryCounter ----------------------------------

;-------------------------------------------------------------------------------
; Subroutine: PressC
;-------------------------------------------------------------------------------

PressC:

	call	#ResetLED

	inc.b	R10							; Increase rotating counter in R10
	cmp.b	#9, R10						; Check if rotating counter has reached 9
	jz		ResetC						; Reset counter to 0 if R10 holds 9
	call	#RotatingCounter


	mov.w	#0, R4						; Clear register data for column
	mov.w	#0, R5						; Clear register data for row

	mov.w	#0FFFh, R8					; Delay for rotating counter display
	call	#Delay

	call 	#ColumnInput				; Change columns to be inputs, rows to be outputs
	call	#CheckKeypad				; Check if another key has been pressed

	cmp.b	#0, R4
	jz		PressC						; Continue PressC subroutine if no new key pressed

	cmp.b	#0020h, R4
	jz		ResetC						; Reset counter if 'C' pressed again

	jmp		FindButton					; Return to FindButton if new key pressed

;-------------------------- END PressC -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ResetC
;-------------------------------------------------------------------------------

ResetC:

	mov.w	#0, R10
	jmp		PressC

;-------------------------- END ResetC -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: RotatingCounter
;-------------------------------------------------------------------------------

RotatingCounter:

	cmp.b	#1, R10
	jz		SetLED0

	cmp.b	#2, R10
	jz		SetLED1

	cmp.b	#3, R10
	jz		SetLED2

	cmp.b	#4, R10
	jz		SetLED3

	cmp.b	#5, R10
	jz		SetLED4

	cmp.b	#6, R10
	jz		SetLED5

	cmp.b	#7, R10
	jz		SetLED6

	cmp.b	#8, R10
	jz		SetLED7

	ret


;-------------------------- END RotatingCounter --------------------------------

;-------------------------------------------------------------------------------
; Subroutine: PressD
;-------------------------------------------------------------------------------

PressD:

	call	#ResetLED

	inc.b	R12							; Increase rotating counter in R12
	cmp.b	#7, R12						; Check if sequence counter has reached 7
	jz		ResetD						; Reset counter to 0 if R10 holds 9
	call	#SequenceCounter


	mov.w	#0, R4						; Clear register data for column
	mov.w	#0, R5						; Clear register data for row

	mov.w	#0FFFh, R8					; Delay for rotating counter display
	call	#Delay

	call 	#ColumnInput				; Change columns to be inputs, rows to be outputs
	call	#CheckKeypad				; Check if another key has been pressed

	cmp.b	#0, R4
	jz		PressD						; Continue PressC subroutine if no new key pressed

	cmp.b	#0010h, R4
	jz		ResetD						; Reset counter if 'C' pressed again

	jmp		FindButton					; Return to FindButton if new key pressed


;-------------------------- END PressD -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ResetD
;-------------------------------------------------------------------------------

ResetD:

	mov.w	#0, R12
	jmp		PressD

;-------------------------- END ResetD -----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: SequenceCounter
;-------------------------------------------------------------------------------

SequenceCounter:

	cmp.b	#1, R12
	jz		SC_Pattern1

	cmp.b	#2, R12
	jz		SC_Pattern2

	cmp.b	#3, R12
	jz		SC_Pattern3

	cmp.b	#4, R12
	jz		SC_Pattern4

	cmp.b	#5, R12
	jz		SC_Pattern3

	cmp.b	#6, R12
	jz		SC_Pattern2


SC_Pattern1:

	call	#SetLED3
	call	#SetLED4
	ret

SC_Pattern2:

	call	#SetLED2
	call	#SetLED5
	ret

SC_Pattern3:

	call	#SetLED1
	call	#SetLED6
	ret

SC_Pattern4:

	call	#SetLED0
	call	#SetLED7
	ret


;-------------------------- END SequenceCounter --------------------------------

;-------------------------------------------------------------------------------
; Subroutine: SetLEDX
;-------------------------------------------------------------------------------

SetLED0:

	bis.b	#BIT0, &P6OUT
	ret

SetLED1:

	bis.b	#BIT1, &P6OUT
	ret

SetLED2:

	bis.b	#BIT2, &P6OUT
	ret

SetLED3:

	bis.b	#BIT3, &P6OUT
	ret

SetLED4:

	bis.b	#BIT4, &P6OUT
	ret

SetLED5:

	bis.b	#BIT0, &P2OUT
	ret

SetLED6:

	bis.b	#BIT1, &P2OUT
	ret

SetLED7:

	bis.b	#BIT2, &P2OUT
	ret

;-------------------------- END SetLEDX ----------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ResetLED
;-------------------------------------------------------------------------------

ResetLED:

	bic.b	#BIT0, &P6OUT
	bic.b	#BIT1, &P6OUT
	bic.b	#BIT2, &P6OUT
	bic.b	#BIT3, &P6OUT
	bic.b	#BIT4, &P6OUT
	bic.b	#BIT0, &P2OUT
	bic.b	#BIT1, &P2OUT
	bic.b	#BIT2, &P2OUT

	ret

;-------------------------- END ResetLED ---------------------------------------

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

