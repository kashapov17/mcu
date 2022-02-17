;
; work3.asm
;
; Created: 17.02.2022 14:58:55
; Author : Yaroslav
; task: b1=increment, b2=lshift, b3=rshift, b4=decrement, bit_str=0b00001111

.def bit_str=r20
.def tmp=r21
.def dly=r22
.equ bit_svalue=0x0F
.equ btn1=0x04
.equ btn2=0x03
.equ btn3=0x02
.equ btn4=0x01
.def loop_count=r18
.def iLoopRl=r24
.def iLoopRh=r25
.equ iVal=39998


init:
	ldi r16, LOW(RAMEND)
	out SPL, r16
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi bit_str, bit_svalue
	ser tmp
	out DDRC, tmp
	clr tmp
	out DDRB, tmp

check_loop:
	out PORTC, bit_str
	sbis PINB, btn1
	inc bit_str
	sbis PINB, btn2
	rol bit_str
	sbis PINB, btn3
	rol bit_str
	sbis PINB, btn4
	dec bit_str
	ldi loop_count, 50 // 50*10 = 500ms delay
	rcall delay
	rjmp check_loop

delay:
	ldi	iLoopRl,LOW(iVal)
	ldi	iLoopRh,HIGH(iVal)

inner_loop:	
	sbiw iLoopRl,1
	brne inner_loop
	dec	loop_count
	brne delay
	nop
	ret
	