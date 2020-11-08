;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;LTC counter for PDP QBUS cotrol panel
;
; j.c.lang 02/22/2019
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Divide clock by 59659 to produce 60Hz. (QBUS LTC)
; CPU clock is provided by a color burst crystal
; pulled 5Hz. low (3.579540Mhz.)
;
; timer counter 1 is setup to compare with 59658
; and toggle OC1 (PB3) and reset the counter
;
; The timer IRQ service routine sets PB0
; if the LTC switch (PD2) is high
; main polls PB0 and if set delays to
; generate a wide pulse then clears PB0
;
;Port B:
;BIT 0	LTC output
;BIT 3	timer OC1 output
;
;Port D:
;BIT 2	LTC switch input
;
	.org 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	rjmp reset	;
	rjmp DUMMY	;IRQ0
	rjmp DUMMY	;IRQ1
	rjmp DUMMY	;IC1
	rjmp timer	;OC1
	rjmp DUMMY	;OV1
	rjmp DUMMY	;OV0
	rjmp DUMMY	;RXC
	rjmp DUMMY	;DRE
	rjmp DUMMY	;TXC
	rjmp DUMMY	;ANA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;TIMER IRQ Service routine
;
timer:
	sbis PIND,2	;LTC enable high?
	rjmp setbit
;
	reti
;
setbit:
	sbi PORTB,0	;set flag
	reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;unexpected IRQ comes here
;
DUMMY:
	cbi,SREG,7	;
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;initialize hardware
;Power on comes here
;
reset:
;
;initialize stack
	ldi R16,low(RAMEND)
	out SPL,R16	;
;
;set B outputs high (pullups on)
	ldi R16,0xff	;
	out PORTB,R16
;
;set port b bits 0,3 to outputs
	ldi R16,0x09	;
	out DDRB,R16
;
;set D outputs high (pullups on)
	ldi R16,0xff	;
	out PORTD,R16
;
;set port D to input
	ldi R16,0x00	;
	out DDRD,R16
;
;initialize timer 1
;
;TCCR1A to 0x80 (toggle OC1)
	ldi R16,0x80	;
	out TCCR1A,R16
;
;OCR1AH to 0xE9 (compare to 59658)
;OCR1AL to 0x0b
	ldi R16,0xE9	;
	out OCR1AH,R16
	ldi R16,0x0A	;
	out OCR1AL,R16
;
;TCCR1B to 0x09 (CK,clear on match)
	ldi R16,0x09	;
	out TCCR1B,R16
;
;TIMSK to 0x80 (OC IRQ EN)
	ldi R16,0x80	;
	out TIMSK,R16
;
;enable global IRQ
	sbi SREG,7	;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
main:	sbis PORTB,0	;
	rjmp main	;loop till pin sets
;
;delay to generate pulse
;
delay:
	ldi R16,0x00
delay1:
	call short
	dec R16
	brne delay1
delay2:
	call short
	dec R16
	brne delay2
;
;clear LTC output bit
;
	cbi PORTB,0
	rjmp main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;short delay
;
short:
	nop
	nop
	nop
	nop
	nop
	nop
	ret
;
