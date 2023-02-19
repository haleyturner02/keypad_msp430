;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
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

	bis.b	#BIT0, &P1DIR				; Initialize LED1 as output
	bic.b	#BIT0, &P1OUT				; Start LED1 off

	bis.b	#BIT6, &P6DIR				; Initialize LED2 as output
	bic.b	#BIT6, &P6OUT				; Start LED2 off

	bic.b	#BIT1, &P4DIR
	bis.b	#BIT1, &P4REN
	bic.b	#BIT1, &P4OUT

	mov.b	#0, R7						; Setup R7 to hold bit corresponding to column
	mov.b	#0, R8						; Setup R8 to hold bit corresponding to row


	bic.b	#LOCKLPM5, &PM5CTL0			; Disable GPIO power-on default high_Z mode

main:


	bit.b	#BIT1, &P4IN
	jz		CheckKeypad


	cmp.b	#0087h, R7					; Check if '1' was pressed
	cmp.b	#0083h, R7					; Check if '2' was pressed
	cmp.b	#0081h, R7					; Check if '3' was pressed
	cmp.b	#0080h, R7					; Check if 'A' was pressed
	cmp.b	#0047h, R7					; Check if '4' was pressed
	cmp.b	#0043h, R7					; Check if '5' was pressed
	cmp.b	#0041h, R7					; Check if '6' was pressed
	cmp.b	#0040h, R7					; Check if 'B' was pressed
	cmp.b	#0027h, R7					; Check if '7' was pressed
	cmp.b	#0023h, R7					; Check if '8' was pressed
	cmp.b	#0021h, R7					; Check if '9' was pressed
	cmp.b	#0020h, R7					; Check if 'C' was pressed
	cmp.b	#0017h, R7					; Check if '*' was pressed
	cmp.b	#0013h, R7					; Check if '0' was pressed
	cmp.b	#0011h, R7					; Check if '#' was pressed
	cmp.b	#0010h, R7					; Check if 'D' was pressed

	jmp		main


;-------------------------------------------------------------------------------
; Subroutine: CheckKeypad
;-------------------------------------------------------------------------------

CheckKeypad:

	call	#ColumnInput

	cmp.b	#00F8h, R7						; Check if column 1 pressed
	jz		CheckRow
	cmp.b	#00F4h, R7						; Check if column 2 pressed
	jz		CheckRow
	cmp.b	#00F2h, R7						; Check if column 3 pressed
	jz		CheckRow
	cmp.b	#00F1h, R7						; Check if column 4 pressed
	jz		CheckRow
	ret

;-------------------------- END CheckKeypad ------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: CheckRow
;-------------------------------------------------------------------------------

CheckRow:

	call	#RowInput

	cmp.b	#008Fh, R8						; Check if row 1 pressed
	jz		ButtonFound
	cmp.b	#004Fh, R8						; Check if row 2 pressed
	jz		ButtonFound
	cmp.b	#002Fh, R8						; Check if row 3 pressed
	jz		ButtonFound
	cmp.b	#001Fh, R8						; Check if row 4 pressed
	jz		ButtonFound
	ret

;-------------------------- END CheckRow ---------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ButtonFound
;-------------------------------------------------------------------------------

ButtonFound:

	xor.b	#BIT0, &P1OUT					; Toggle LED1
	xor.b	#BIT6, &P6OUT					; Toggle LED2

	add.b	R8, R7							; Concatenate column and row bits and put into R7
	ret

;-------------------------- END ButtonFound ------------------------------------

;-------------------------------------------------------------------------------
; Subroutine: ColumnInput
;-------------------------------------------------------------------------------

ColumnInput: 								; Initialize pins to determine the column

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
	bic.b	#BIT4, &P3OUT					; Set P3.4 to be off

	bis.b	#BIT5, &P3DIR					; Initialize P3.5 as output
	bic.b	#BIT5, &P3OUT					; Set P3.5 to be off

	bis.b	#BIT6, &P3DIR					; Initialize P3.6 as output
	bic.b	#BIT6, &P3OUT					; Set P3.6 to be off

	bis.b	#BIT7, &P3DIR					; Initialize P3.7 as output
	bic.b	#BIT7, &P3OUT					; Set P3.7 to be off


	bit.b	#BIT0, &P3IN					; Test if column 1 pressed
	jnz		Column1

	bit.b	#BIT1, &P3IN					; Test if column 2 pressed
	jnz		Column2

	bit.b	#BIT2, &P3IN					; Test if column 3 pressed
	jnz		Column3

	bit.b	#BIT3, &P3IN					; Test if column 4 pressed
	jnz		Column4


	ret

;-------------------------- END ColumnInput ------------------------------------

Column1:

	mov.b	#00F8h, R7
	ret

Column2:

	mov.b	#00F4h, R7
	ret

Column3:

	mov.b	#00F2h, R7
	ret

Column4:

	mov.b	#00F1h, R7
	ret

;-------------------------------------------------------------------------------
; Subroutine: RowInput
;-------------------------------------------------------------------------------

RowInput:									; Initialize pins to determine the row

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
	bic.b	#BIT0, &P3OUT					; Set P3.0 to be off

	bis.b	#BIT1, &P3DIR					; Initialize P3.1 as output
	bic.b	#BIT1, &P3OUT					; Set P3.1 to be off

	bis.b	#BIT2, &P3DIR					; Initialize P3.2 as output
	bic.b	#BIT2, &P3OUT					; Set P3.2 to be off

	bis.b	#BIT3, &P3DIR					; Initialize P3.3 as output
	bic.b	#BIT3, &P3OUT					; Set P3.3 to be off

	mov.w	#512, R5
	call 	#Delay

	bit.b	#BIT4, &P3IN					; Test if row 1 pressed
	jnz 		Row1

	bit.b	#BIT5, &P3IN					; Test if row 2 pressed
	jnz		Row2

	bit.b	#BIT6, &P3IN					; Test if row 3 pressed
	jnz		Row3

	bit.b	#BIT7, &P3IN					; Test if row 4 pressed
	jnz		Row4

	ret


;-------------------------- END RowInput ---------------------------------------

Row1:

	mov.b	#008Fh, R8
	ret

Row2:

	mov.b	#004Fh, R8
	ret

Row3:

	mov.b	#00F2h, R8
	ret

Row4:

	mov.b	#00F1h, R8
	ret

;-------------------------------------------------------------------------------
; Subroutine: Delay
;-------------------------------------------------------------------------------

Delay:

	mov.w	#1, R4

InnerDelay:

	dec.w 	R4							; Decrement R4, the inner delay loop
	jnz 	InnerDelay					; Iterate inner delay loop until R4 holds a value of 0
	dec.w	R5							; Decrement R5, the outer delay loop
	jnz		Delay						; Reiterate inner loop until R5 holds a value of 0
 	ret

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
