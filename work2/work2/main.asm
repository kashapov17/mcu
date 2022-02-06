;
; work2.asm
;
; Created: 05.02.2022 17:58:37
; Author: Yaroslav
; Task: op=diff, C_size=16, A_size=B_size=8, 
;		C_start_addr=0x75, item=max, 
;		item_addr=0x8B, sort=desc  
;

.dseg
.equ C_size=16
.equ A_size=8
.equ B_size=8
.org 0x60
arr_A_mem: .byte A_size
arr_B_mem: .byte B_size
.org 0x75
arr_C_mem: .byte C_size
.org 0x8B
item: .byte 1

.cseg
arr_A_raw: .db 5,1,8,2,1,6,8,3
arr_B_raw: .db 6,1,8,9,1,0,3,5

.macro LOAD_ARR_TO_MEM
	.def rsize=r22
	.def ridx=r23
	.def ritem=r24
	ldi ZL, LOW(@0)
	ldi ZH, HIGH(@0)
	ldi XL, LOW(@1)
	ldi XH, HIGH(@1)
	ldi rsize, @2
	ldi ritem, 0
	mov ridx, rsize
load_loop:
	lpm ritem, Z+
	st X+, ritem
	dec ridx
	brne load_loop
end:
	.undef rsize
	.undef ridx
	.undef ritem
.endm

.macro MAX_FROM_ARRAY
	.def rsize=r22
	.def rmax=r23
	.def ridx=r24
	.def ritem=r25
	ldi ZL, LOW(@0)
	ldi ZH, HIGH(@0)
	ldi XL, LOW(@2)
	ldi XH, HIGH(@2)
	ldi rsize, @1
	mov ridx, rsize 
	ldi ritem, 0
	ld rmax, Z
find_loop:
	ld ritem, Z+
	cp rmax, ritem
	brlo set_max
after_max_setting:
	dec ridx
	brne find_loop
	rjmp end
set_max:
	mov rmax,ritem
	rjmp after_max_setting
end:
	st X, rmax
	.undef rsize
	.undef rmax
	.undef ridx
	.undef ritem
.endm	

load_arrays:
	LOAD_ARR_TO_MEM arr_A_raw, arr_A_mem, A_size
	LOAD_ARR_TO_MEM arr_B_raw, arr_B_mem, B_size
	MAX_FROM_ARRAY arr_B_mem, B_size, item
	nop
	nop